#!/usr/bin/env python3
"""
Prisma - limpeza de previews expirados.

O Code node do n8n nesta instancia nao consegue apagar ficheiros: `fs` esta
bloqueado no sandbox, o no Read/Write Files so tem operacao read/write (sem
delete), e o no Execute Command nao esta instalado (confirmado nos probes de
capacidade da Fase 0). Por isso a limpeza real corre aqui, a nivel do host,
via crontab (nao dentro do n8n) -- ver crontab -l no servidor.

Substitui o workflow imovel-cron-expiracao-wf, que so reescrevia o .html com
uma pagina generica e marcava estado=expirado, mas nunca libertava disco.

Antes de apagar, regista uma linha de auditoria em _expired_log.jsonl (uma
por landing) para nao perder o registo de que a landing existiu.
"""
import json
import os
import glob
from datetime import datetime, timezone

BUILDS_DIR = "/var/www/prisma-builds"
LOG_PATH = os.path.join(BUILDS_DIR, "_expired_log.jsonl")


def main():
    now = datetime.now(timezone.utc)
    removed = 0

    for state_path in glob.glob(os.path.join(BUILDS_DIR, "*.state.json")):
        try:
            with open(state_path, "r", encoding="utf-8") as f:
                state = json.load(f)
        except (json.JSONDecodeError, OSError):
            continue

        estado = state.get("estado")
        expires_at = state.get("expires_at")
        if estado not in ("preview", "expirado") or not expires_at:
            continue

        try:
            exp_dt = datetime.fromisoformat(str(expires_at).replace("Z", "+00:00"))
        except ValueError:
            continue
        if exp_dt >= now:
            continue

        imovel = state.get("imovel") or {}
        cliente = state.get("cliente") or {}
        html_path = state_path[: -len(".state.json")] + ".html"

        log_entry = {
            "landing_id": state.get("landing_id", ""),
            "titulo": imovel.get("titulo", ""),
            "imobiliaria": cliente.get("imobiliaria", ""),
            "localizacao": imovel.get("localizacao", ""),
            "url": state.get("url", ""),
            "criado": state.get("criado", ""),
            "expires_at": expires_at,
            "apagado_em": now.isoformat(),
        }
        with open(LOG_PATH, "a", encoding="utf-8") as logf:
            logf.write(json.dumps(log_entry, ensure_ascii=False) + "\n")

        for p in (state_path, html_path):
            try:
                os.remove(p)
            except OSError:
                pass

        removed += 1
        print(f"apagado: {log_entry['landing_id']} ({log_entry['titulo']})")

    if removed == 0:
        print("nada a apagar")


if __name__ == "__main__":
    main()
