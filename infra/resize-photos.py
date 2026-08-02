#!/usr/bin/env python3
"""
Prisma - redimensionamento de fotos de imoveis (P1/P2, sessao 2026-08-02).

O Code node do n8n nesta instancia nao consegue redimensionar imagens: `fs`
esta bloqueado no sandbox, nao ha require() de modulos nao nativos (sem
sharp/jimp), e o no Execute Command nao esta instalado (confirmado nos probes
de capacidade da Fase 0 -- ver expire-cleanup.py, mesmo raciocinio). Por isso
o redimensionamento real corre aqui, a nivel do host, via crontab de 1 em 1
minuto (nao dentro do n8n).

Cada foto submetida chega ao disco em bruto (B3 de 'Prepara Payload Diretor',
sem qualquer tratamento -- fotos de telemovel modernas facilmente excedem
6000px de largura e varios MB). Este script:

  P2 -- limite de seguranca: se o maior lado exceder SAFE_CAP_PX, redimensiona
        a propria foto "original" (mesmo nome de ficheiro, in-place) para
        SAFE_CAP_PX antes de gerar seja o que for. Nunca guardamos mais do
        que isto em disco como "original".
  P1 -- gera variantes WebP (qualidade WEBP_QUALITY) + fallback JPEG em cada
        largura de CANDIDATE_WIDTHS que seja menor que a foto (apos P2),
        nomeadas '{stem}-{largura}.webp' / '{stem}-{largura}.jpg', para o
        Compilador Editorial referenciar em srcset real (ver buildSrcsetAttr
        no workflow). Nunca faz upscale -- larguras >= a foto sao ignoradas.

Processa UMA foto de cada vez (droplet de 1 vCPU / 961 MiB RAM, ver STATE.md)
-- nunca em paralelo. Usa draft() do Pillow para JPEGs grandes: o libjpeg
descodifica ja a uma escala reduzida em vez de decodificar o ficheiro
inteiro e so depois encolher, o que poupa memoria e CPU exatamente nos
ficheiros mais pesados (os de 6000px+ que motivaram este script).

Idempotente: grava um marcador '{stem}.resized' depois de processar uma foto
com sucesso; fotos ja marcadas sao ignoradas em corridas seguintes. Uma foto
corrompida ou num formato nao suportado e ignorada (log + continue), nunca
derruba a corrida inteira -- mesma filosofia de "nunca bloqueia" do resto do
pipeline de imagem (ver STATE.md, I1/I2).
"""
import fcntl
import glob
import os
import re
import sys

from PIL import Image, ImageFile

# Ficheiros truncados/parciais (ex.: apanhados a meio de uma escrita) nao
# devem derrubar o processo -- tenta processar o que conseguir decodificar.
ImageFile.LOAD_TRUNCATED_IMAGES = True

BUILDS_DIR = "/var/www/prisma-builds"
LOCK_PATH = "/tmp/prisma-resize-photos.lock"

SAFE_CAP_PX = 2560          # P2 -- nunca guardar "original" maior do que isto
CANDIDATE_WIDTHS = [1920, 1280, 1200, 800, 400]  # P1 -- hero / galeria / thumb
WEBP_QUALITY = 80           # dentro do intervalo pedido (78-82)
JPEG_QUALITY = 82

FOTO_RE = re.compile(r"^[a-z0-9]+-foto-\d+\.(jpe?g|png|webp)$", re.IGNORECASE)


def stem_of(path):
    base = os.path.basename(path)
    return os.path.join(os.path.dirname(path), os.path.splitext(base)[0])


def already_done(path):
    stem = stem_of(path)
    return os.path.exists(stem + ".resized") or os.path.exists(stem + ".resize_failed")


def mark_done(path):
    open(stem_of(path) + ".resized", "w").close()


def mark_failed(path):
    # Sem isto, um ficheiro corrompido (ex.: download truncado de uma sessao
    # de teste antiga) seria retentado a cada corrida do cron, para sempre --
    # 1 vCPU nao tem CPU a desperdicar em retries doomed a cada minuto.
    open(stem_of(path) + ".resize_failed", "w").close()


def cap_original(im, path, fmt):
    """P2 -- redimensiona a propria foto 'original' se exceder SAFE_CAP_PX."""
    w, h = im.size
    maior = max(w, h)
    if maior <= SAFE_CAP_PX:
        return im, w, h
    escala = SAFE_CAP_PX / float(maior)
    novo = (max(1, round(w * escala)), max(1, round(h * escala)))
    im2 = im.resize(novo, Image.LANCZOS)
    save_kwargs = {"quality": JPEG_QUALITY, "optimize": True} if fmt == "JPEG" else {"optimize": True}
    im2.save(path, format=fmt, **save_kwargs)
    print(f"  P2 cap: {w}x{h} -> {novo[0]}x{novo[1]} ({path})")
    return im2, novo[0], novo[1]


def gerar_variantes(im, stem, effective_width):
    """P1 -- WebP + fallback JPEG para cada largura menor que a foto (sem upscale)."""
    w, h = im.size
    for largura in CANDIDATE_WIDTHS:
        if largura >= effective_width:
            continue
        altura = max(1, round(h * (largura / float(w))))
        variante = im.resize((largura, altura), Image.LANCZOS)
        rgb = variante.convert("RGB") if variante.mode in ("RGBA", "P", "LA") else variante
        rgb.save(f"{stem}-{largura}.webp", format="WEBP", quality=WEBP_QUALITY)
        rgb.save(f"{stem}-{largura}.jpg", format="JPEG", quality=JPEG_QUALITY, optimize=True)


def processa(path):
    fmt_original = "PNG" if path.lower().endswith(".png") else (
        "WEBP" if path.lower().endswith(".webp") else "JPEG"
    )
    try:
        with Image.open(path) as im:
            # decodifica ja a uma escala reduzida quando o JPEG e muito maior
            # do que o limite de seguranca -- poupa memoria/CPU no ficheiro
            # inteiro em vez de decodificar em bruto e so depois encolher.
            if fmt_original == "JPEG" and hasattr(im, "draft"):
                im.draft("RGB", (SAFE_CAP_PX * 2, SAFE_CAP_PX * 2))
            im.load()
            im, effective_width, _ = cap_original(im, path, fmt_original)
            stem = stem_of(path)
            gerar_variantes(im, stem, effective_width)
        mark_done(path)
        print(f"processado: {path}")
    except Exception as e:
        mark_failed(path)
        print(f"AVISO: falha a processar {path}: {e}", file=sys.stderr)


def main():
    lock_fd = open(LOCK_PATH, "w")
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        print("outra corrida ja em curso, a sair")
        return

    pendentes = [
        p for p in sorted(glob.glob(os.path.join(BUILDS_DIR, "*")))
        if FOTO_RE.match(os.path.basename(p)) and not already_done(p)
    ]
    if not pendentes:
        print("nada a processar")
        return

    for path in pendentes:
        processa(path)


if __name__ == "__main__":
    main()
