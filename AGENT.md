# AGENT.md — PRISMA STUDIO
### Constituição e Protocolo de Arranque para Agentes de IA

> **Se és um agente de IA a trabalhar neste projeto, este ficheiro é a tua primeira leitura obrigatória.**
> Lê-o na íntegra antes de qualquer ação. Não assumas nada que não esteja aqui ou verificado na máquina.

**Versão:** 1.1 · **Última revisão:** 2026-07-14
**Repositório:** `STUDIO-PRISMA` · **Branch:** `main`
**Ambiente do operador:** Windows · chave SSH em `%USERPROFILE%\.ssh\id_ed25519_prisma`
**Servidor:** `root@161.35.19.139` (DigitalOcean)

---

## PARTE I — PROTOCOLO DE ARRANQUE (executar SEMPRE, por esta ordem)

### Passo 1 — Ler o contexto
```powershell
git pull
# 1. AGENT.md  (este ficheiro) → a constituição. O que o projeto é e o que não pode ser.
# 2. STATE.md                  → o que ALEGAMOS ter feito.
# 3. git log -5 --oneline      → o que mudou desde a última sessão.
```

### Passo 2 — VERIFICAR, não confiar
> ⚠️ **REGRA FUNDAMENTAL: o `STATE.md` pode estar errado.**
> Um agente anterior pode ter escrito "backup configurado" e o backup nunca ter saído do servidor.
> **Nunca ajas com base no que o ficheiro diz. Age com base no que a máquina responde.**

```powershell
.\verify.ps1
```

O `verify.ps1` interroga o servidor real, **dispara um teste end-to-end no webhook**, e reescreve o bloco `[AUTO]` do `STATE.md`. Também escreve `status.json` (legível por máquina).

### Passo 3 — Ver o delta face à realidade
```powershell
git diff STATE.md
```
Mostra **exatamente o que mudou na realidade** desde a última sessão. Se um agente anterior exagerou o progresso, o diff denuncia-o aqui.

### Passo 4 — Reportar divergências ANTES de agir
Se o `[AUTO]` contradisser o `[MANUAL]`, **para e reporta**:
```
⚠️ DIVERGÊNCIA DETETADA
STATE.md [MANUAL] alega: "backup configurado ✅"
verify.ps1 [AUTO] diz:   "Backup replicado FORA do servidor → FALHA"
Ação: aguardo instrução. Não avanço.
```

### Passo 5 — Antes de terminar, atualizar o estado
```powershell
.\verify.ps1                      # reescreve o bloco [AUTO]
git diff STATE.md                 # confirmar o que mudou
# atualizar os blocos [MANUAL]: checklist, onde parámos, PRÓXIMO PASSO (um só)
# se alteraste o workflow: exportá-lo para n8n/tally-onboarding.json
git add -A ; git commit -m "state: <resumo factual>" ; git push
```
**Uma sessão que não corre o `verify.ps1` e não atualiza o `STATE.md` partiu a cadeia.**

---

## 🔴 PARTE I-B — A REGRA DO CRITÉRIO ÚNICO

> **Configuração correta na base de dados NÃO significa pipeline vivo.**

Esta lição custou-nos um sprint. O n8n carrega os workflows em memória e regista as rotas Express **no momento da ativação**. Uma escrita direta no SQLite **não é vista pelo processo em execução** — e pode ser sobrescrita quando alguém gravar o workflow pela UI.

Resultado: o Sprint 0 foi reportado como concluído com seis `[x]`, enquanto o webhook devolvia 404 e o produto estava em baixo.

**O único critério que conta é este:**

```powershell
# Um POST real no webhook produz um HTML correto?
Invoke-WebRequest -Uri "http://161.35.19.139/webhook/tally-onboarding" -Method POST `
  -Body '{"empresa":"Teste","horario":"<script>alert(1)</script> 9h-19h", ...}' `
  -ContentType "application/json"
```

E no HTML gerado:
- `&lt;script&gt;` presente → XSS neutralizado
- `<script>alert(1)` **ausente** → não é vulnerável
- imagem do hero presente → `safeUrl`/`escapeAttr` não rebentaram
- `BEM-VINDO` presente → typo corrigido
- copy ≠ fallback estático → o LLM respondeu

O `verify.ps1` faz isto automaticamente e limpa o artefacto de teste. **Nenhuma tarefa se marca como feita sem este teste passar.**

---

## PARTE II — O QUE É O PRISMA STUDIO

### Missão
Motor **end-to-end** que gera e **opera** landing pages de alta conversão para PMEs portuguesas, **sem intervenção humana**.

**Promessa ao cliente:** *"O seu site online em minutos. Sem reuniões, sem orçamentos, sem complicações."*

### O produto NÃO é um site. É um serviço de presença digital gerida
- Domínio próprio (registado, configurado, renovado) — **titular é o cliente**
- Site online, SSL, CDN global
- **Alterações de conteúdo ilimitadas**, self-service, publicadas em minutos
- Captação e reencaminhamento de contactos
- Relatório periódico traduzido em euros, não em métricas

### Mercado
PMEs e profissionais liberais **em Portugal**. Início: Castelo Branco. Expansão: nacional.
**O mercado brasileiro está explicitamente FORA de âmbito.**

### Modelo de preço — escada por coorte (preço vitalício)
| Coorte | Clientes | Preço/ano | Estado |
|---|---|---|---|
| Piloto | 1–5 | €0 | Validação |
| **Fundadores** | 6–25 | **€150 — vitalício** | ← **estamos aqui** |
| Coorte 2 | 26–75 | €199 — vitalício | |
| Coorte 3 | 76–150 | €249 — vitalício | |
| Maturidade | 151+ | €348 | |

**Regras invioláveis de preço:**
- **Nunca aumentar o preço de um cliente existente.** O preço da coorte de origem é vitalício.
- **Nunca apresentar o preço dividido por mês.** €12,50/mês coloca o Prisma ao lado do Wix — a comparação que destrói o posicionamento. Comunicar sempre: *"€150 no primeiro ano — preço de fundador. Valor normal: €348."*
- Pagamento **anual único** (MB WAY / Multibanco / cartão). **NÃO** há subscrição recorrente: o Stripe não suporta MB WAY recorrente e o Multibanco só funciona para pagamentos únicos.

### Unit economics (coorte Fundadores)
€150 − domínio €10 − Gemini €0,02 − hosting €0 = **~€140 margem (93%)**.
Custos fixos €30–50/mês. **Break-even: 4 clientes.**

---

## PARTE III — ESTADO ATUAL (pós-Sprint 0, 2026-07-14)

> O `STATE.md` é a fonte viva. Isto é o contexto de fundo.

### Stack
| Camada | Tecnologia |
|---|---|
| Entrada | Tally.so (8 campos) → webhook |
| Orquestração | n8n `2.29.10` (Docker, SQLite) |
| IA | Gemini `2.0-flash` + `responseSchema` |
| Compilação | Nó Code (Node.js) — `split/join` + RegEx + escaping |
| Entrega | NGINX local, `/var/www/prisma-builds/` |
| Servidor | DigitalOcean Ubuntu 24.04, 1 vCPU / 1 GB RAM + 2 GB swap |
| Versionamento | GitHub `STUDIO-PRISMA` |

### ✅ Sprint 0 — o que ficou sólido
- **Acesso:** chave ed25519; `PasswordAuthentication no`; `PermitRootLogin prohibit-password`. **Relatório de intrusão: sem intrusos** (2473 tentativas falhadas = ruído de bots).
- **Rede:** UFW ativo (22/80/443); n8n em `127.0.0.1:5678`; NGINX proxia apenas `/webhook/`; painel só por túnel SSH.
- **Backup:** script + cron 03:00 + GPG AES-256 + rotação 7 dias + **restauração testada**.

### 🔴 Sprint 0 — o que continua em aberto
| # | Blocker | Porquê |
|---|---|---|
| **A** | **Pipeline em baixo (webhook 404)** | Workflow alterado por escrita direta no SQLite. O n8n não registou a rota Express. **Sanitização e Gemini 2.0 podem estar na BD mas não em execução.** |
| **B** | **`escapeAttr` pode não existir** | `safeUrl()` chama-a. Se não existir, **qualquer submissão com logótipo ou fotografia rebenta o compilador** — e a fotografia é campo obrigatório. |
| **C** | **Backup nunca sai do servidor** | Um backup guardado no droplet não protege contra a perda do droplet, que é o risco terminal. Falta repo privado `prisma-backups` + deploy key + push. |
| D | Workflows duplicados | Dois com o mesmo nome (`66d5ac7f8c71179f`, `tally-onboarding-wf`). Apagar o órfão. |
| E | Workflow não versionado | `n8n/tally-onboarding.json` não existe. **O "último commit" não representa o projeto.** |

### ❓ Pergunta em aberto
> **O "Projeto Raízes" alguma vez correu a partir de uma submissão REAL do Tally — ou só por execução manual dentro do n8n?**
> A auditoria e o relatório do Sprint 0 dizem ambos que a rota do webhook nunca esteve registada. Se assim for, **a PoC "zero-click" nunca correu de ponta a ponta.**

### Formulário Tally (8 campos)
`Nome da Empresa*` · `Nicho*` · `Diferencial*` (min 20) · `WhatsApp*` · `Morada` · `Horário*` · `Logótipo` · `Fotografia*`
**Em falta:** NIF (faturação e `.pt`), Domínio.

---

## PARTE IV — ARQUITETURA ALVO

```
① LANDING — Widget "O seu domínio está livre?"
     → Cloudflare Registrar API (search + check) → 1ª E 2ª opção
     → email capturado (lead, mesmo sem compra)
     ↓
② PAGAMENTO — €150, único (Ifthenpay/Eupago: MB WAY, Multibanco, cartão)
     → webhook → n8n emite TOKEN
     ↓
③ TALLY — só aceita submissões COM token válido; domínio pré-preenchido
     ↓
④ n8n PIPELINE
     1. Validar token
     2. Gemini Flash + responseSchema → identity + content
     3. CLASSIFICADOR DE RISCO → bloqueia se risco ≥ 7
     4. Escrever site_state no SUPABASE
     5. Re-check domínio → registar (titular = CLIENTE)
        └─ ocupado? → regista automaticamente a 2ª opção
     6. RENDER determinístico (esqueleto + tokens + escaping)
     7. Deploy CLOUDFLARE PAGES → DNS + SSL automáticos
     8. Commit GitHub (backup) — paralelo, não bloqueante
     9. WhatsApp ao cliente
```

### Decisões fechadas
| Decisão | Racional |
|---|---|
| **Cloudflare Pages, não Netlify** | Se o registrar é Cloudflare, o domínio já lá está. Domínio personalizado = 1 chamada de API. Sem propagação, sem 2º fornecedor |
| **Git = backup, não gatilho de deploy** | HTML estático sem build step. Deploy via API (~3s vs ~60s) |
| **Supabase = `site_state`** | Sem isto, "alterações ilimitadas" é impossível |
| **Cliente é titular do domínio** | *"O domínio é seu. Se sair, leva-o."* Elimina exposição legal e RGPD |
| **Pagamento único anual** | MB WAY/Multibanco não suportam recorrência |

### 🔑 A separação Generate / Render (crítico)
**Problema:** se um "rebuild" re-executar `Tally → Gemini → HTML`, um cliente que mude o telefone verá o site inteiro reescrito (nova copy, novas cores — o modelo corre a temperature 0.85). Isto **invalida a promessa central do produto**.

```
site_state (Supabase)
├── identity : { paleta, tipografia, arquétipo, tokens CSS }
├── content  : { hero, serviços, sobre, contactos, imagens }
└── meta     : { domínio, pages_project_id, cliente_id, coorte, preço, estado }
```
- **Generate** (LLM): **uma vez**, no onboarding.
- **Render** (determinístico): esqueleto + tokens + escaping. **Zero LLM.**
- **Edit:** `PATCH` ao `site_state` → render → deploy.
- **Regenerate:** chamada explícita ao LLM, num bloco específico, a pedido.

### As 4 guardas do modo Zero-Touch
Um pipeline que publica HTML a partir de um formulário público é, tecnicamente, um serviço gratuito de alojamento de phishing. Consequência: domínio em blocklist, marca destruída.

| # | Guarda | Como |
|---|---|---|
| 1 | **Pagamento é o portão** | Nada é gerado sem pagamento confirmado + NIF rastreável |
| 2 | **Token no formulário** | Tally rejeita submissões sem token emitido pelo n8n |
| 3 | **Classificador de risco** | Gemini Flash → `{"risco": 0-10}`. ≥7 bloqueia + alerta Telegram |
| 4 | **Domínio de sacrifício** | Sites de clientes num domínio descartável, separado da marca |

---

## PARTE V — REGRAS PARA AGENTES

### 🚫 NUNCA
- **Nunca edites o workflow diretamente no SQLite.** O n8n não vê essas alterações em runtime e pode sobrescrevê-las. Usa `n8n import:workflow` → `docker restart` → ativar pela UI. *(Esta regra custou-nos um sprint.)*
- **`docker cp` como root parte permissões.** O processo n8n corre como `node` (uid 1000), não root — `docker exec` sem `-u node` também executa como `node` por defeito. Um `docker cp ficheiro container:/caminho` feito da tua sessão SSH (root) cria o ficheiro com dono `root:root` no bind mount; se esse caminho estiver num diretório restrito (ex.: `/home/node/.n8n-files/data/`, `drwx------` só de `node`), o processo n8n deixa de conseguir reescrever esse ficheiro — falha em silêncio com `EACCES`/"Forbidden by access permissions" na próxima escrita, não no momento da cópia. **Sempre `docker exec -u root <container> chown node:node <caminho>` logo a seguir a qualquer `docker cp` para dentro do container.** Para o `chown` resultar tens de usar `-u root` explicitamente no `docker exec` (o utilizador por omissão do container não tem permissão para mudar dono de ficheiros que não lhe pertencem). Confirma sempre com `ls -la` e um teste de escrita real como `-u node` — nunca apenas com o `chown` a correr sem erro.
- **Nunca marques uma tarefa como feita sem o teste end-to-end passar.** Ver Parte I-B.
- **Nunca escrevas passwords, tokens ou chaves em texto simples** em scripts, logs, ficheiros ou respostas. Chaves SSH e variáveis de ambiente, sempre. Se encontrares um segredo em claro, **reporta a localização, nunca o valor**.
- **Nunca commites** `database.sqlite`, `.n8n/config`, `.env`, ou qualquer credencial. Backups de segredos vão cifrados (GPG) para repo privado dedicado.
- **Nunca consideres um backup válido se ele nunca saiu do servidor.**
- **Nunca inventes.** Se não encontraste: `NÃO ENCONTRADO`. Uma suposição plausível é pior que uma lacuna admitida.
- **Nunca confies no `STATE.md`** sem correr `verify.ps1`.
- **Nunca refatores o que não foi pedido.**
- **Nunca mudes o contrato de output do LLM sem mudar o renderizador no mesmo passo.** O compilador espera `{headline, subheadline}`.
- **Nunca uses `gemini-1.5-*`.** Geração antiga.

### ✅ SEMPRE
- **Verifica na máquina** antes de agir, e **testa a saída real** antes de declarar vitória.
- **Testa a restauração**, não apenas o backup.
- **Escapa todo o input** que entre em HTML — do Tally *e* do LLM (o LLM também é input não confiável).
- **Atualiza o `STATE.md`** antes de terminar.
- **Exporta o workflow do n8n para o repo** sempre que o alteres.
- **Prefere a solução mais simples.** Este é um negócio operado por uma pessoa.

### Princípios orientadores
> **1. Não construir infraestrutura para clientes que ainda não existem.**
> O próximo obstáculo é comercial, não técnico.

> **2. Preço baixo é estratégia, não acidente.**
> €150 compra volume e prova social. A margem vem da automação, não do preço.

> **3. Volume exige aquisição, não capacidade de produção.**
> O motor faz 100 sites/dia sem esforço. O gargalo é encontrar 100 clientes.

> **4. Zero intervenções manuais é uma condição, não um objetivo.**
> A €150/ano, operado por uma pessoa, qualquer minuto humano por cliente destrói o modelo.

---

## PARTE VI — ESTRUTURA DO REPOSITÓRIO

```
STUDIO-PRISMA/
├── AGENT.md                  # esta constituição
├── STATE.md                  # estado vivo ([AUTO] + [MANUAL])
├── verify.ps1                # verdade de terreno (PowerShell + teste E2E)
├── status.json               # output legível por máquina do verify.ps1
├── README.md
├── n8n/
│   └── tally-onboarding.json # ← EXPORTADO A CADA ALTERAÇÃO. Sem isto o Git é uma casca vazia.
├── src/
│   ├── index_template.html
│   └── compiler.js           # código do nó Code, versionado e testável
├── docs/
│   ├── SCHEMA_TALLY.md · PRISMA_BUILDER.md · PRISMA_GIT_PROTOCOL.md
└── infra/
    ├── docker-compose.yml · nginx.conf · backup-n8n.sh
```

**Convenção de commits:** `feat:` · `fix:` · `sec:` · `infra:` · `state:`

---

## PARTE VII — ROADMAP

### Sprint 0.1 — FECHO (bloqueia tudo o resto)
- [ ] Reimportar workflow via `import:workflow` → `docker restart` → ativar pela UI
- [ ] **Teste end-to-end passa** (`.\verify.ps1` sem falhas no bloco E2E)
- [ ] Confirmar que `escapeAttr` existe
- [ ] Backup replicado **fora** do servidor (repo privado `prisma-backups`)
- [ ] Apagar workflow duplicado
- [ ] `n8n/tally-onboarding.json` no Git
- [ ] Trocar password de root

### Sprint 1 — Desbloquear a Receita
- Ifthenpay **ou** Eupago: Payment Link único (€150) via MB WAY/Multibanco
- Cloudflare Registrar API: `search` → `check` → `register` com registante inline
- **Confirmar renovação automática na Cloudflare** (a API beta não tem endpoint de renovação)
- **Inverter o funil:** pagamento → token → formulário
- Widget de verificação de domínio na landing (1ª + 2ª opção + captura de email)
- Classificador de risco · HTTPS (desbloqueia assim que houver domínio)
- **Entregar o 1º site piloto** + aplicar Van Westendorp

### Sprint 2 — Motor de Aquisição
> **É este sprint que determina se o negócio existe.** A €150/ano, sem canais escaláveis, o volume não acontece.
- Widget de domínio como isca de SEO · Atribuição no rodapé · Contabilistas (€30–50)
- Referência de cliente (1 ano grátis) · Página de casos · Nutrição automática de leads

### Sprint 3 — Consolidação Técnica
- **Supabase `site_state`** + separação `generate`/`render` · Cloudflare Pages
- Cron de renovação (D-45, preço da coorte de origem) · Error Workflow · HMAC · Rate limit 10/dia

### Sprint 4+ — Maturidade (25+ clientes)
- Portal self-service · Relatório em euros · Coorte 2 (€199) · RGPD · Upgrade do droplet

---

## PARTE VIII — DECISÕES EM ABERTO

| # | Decisão | Impacto |
|---|---|---|
| 1 | **`.com` ou `.pt` default?** | `.pt` não é suportado pela Cloudflare; exige Nic-Handle + NIF. A €150 custa 13% da receita vs 7% do `.com`. **Validar com os pilotos** |
| 2 | **Fundador: €150 ou €199?** | Pergunta 4 do Van Westendorp (*"barato demais ao ponto de duvidar da qualidade?"*) |
| 3 | **Comissão de contabilista: €30 ou €50?** | €50 = 33% da receita do ano 1 |
| 4 | **Email profissional incluído?** | Lock-in forte, mas ~€3–6/utilizador/mês. Provavelmente incompatível com €150 |
| 5 | **Widget: email antes ou depois dos resultados?** | Antes = mais leads. Depois = mais tráfego |
| 6 | **Manter o nome "Prisma Studio"?** | Colisão com Prisma.io. Impacto SEO alto. Verificar INPI/EUIPO |

---

## ANEXO A — Estrutura do `STATE.md`

```markdown
<!-- AUTO:START -->
## [AUTO] Verdade de terreno       ← escrito por verify.ps1. NÃO editar à mão.
<!-- AUTO:END -->

## [MANUAL] Sprint N — checklist   ← [x] só depois de o verify confirmar
## [MANUAL] Blockers
## [MANUAL] Onde parámos
## 👉 [MANUAL] PRÓXIMO PASSO (um só)
```

**Se o `[MANUAL]` disser uma coisa e o `[AUTO]` disser outra, o `[AUTO]` tem razão.**

---

## ANEXO B — `verify.ps1`

Vive na raiz do repositório. Executar com `.\verify.ps1` (ou `.\verify.ps1 -SkipE2E` para saltar o teste end-to-end).

**Verifica 18 controlos** em quatro grupos:
- **Segurança:** password auth, UFW, porta 5678 fechada (testada da máquina local, não do servidor), SSL
- **Backup:** cron, `.gpg` local, **`.gpg` replicado fora do servidor**, restauração testada, data do último
- **Pipeline:** modelo Gemini, `escapeHtml`, `escapeAttr`, `responseSchema`, typo, duplicados, Error Workflow
- **End-to-end:** POST real no webhook → HTML gerado → XSS escapado, imagem presente, `BEM-VINDO`, copy do LLM (não fallback) → limpa o artefacto de teste

Escreve o bloco `[AUTO]` do `STATE.md` e o `status.json`. Sai com código `1` se houver falhas críticas.

---

## ANEXO C — Referência rápida

| | |
|---|---|
| **Servidor** | `root@161.35.19.139` · Ubuntu 24.04 · 1 vCPU / 1 GB RAM + 2 GB swap |
| **Chave SSH** | `%USERPROFILE%\.ssh\id_ed25519_prisma` |
| **Túnel para o painel** | `ssh -L 5678:127.0.0.1:5678 -i ~/.ssh/id_ed25519_prisma root@161.35.19.139` → `http://localhost:5678` |
| **n8n** | v2.29.10 · Docker · container `prisma-n8n_n8n_1` |
| **SQLite** | `/var/lib/docker/volumes/prisma-n8n_n8n_data/_data/database.sqlite` |
| **Encryption key** | `.../_data/config` — **sem ela, as credenciais do backup são indecifráveis** |
| **Workflow** | `tally-onboarding-wf` |
| **Webhook** | `POST http://161.35.19.139/webhook/tally-onboarding` |
| **Builds** | `/var/www/prisma-builds/` |
| **Backup** | `/root/scripts/backup-n8n.sh` · cron 03:00 · GPG AES-256 |
| **Repo** | `STUDIO-PRISMA`, branch `main` |

---

*Fim do AGENT.md. Se chegaste aqui sem correr o `verify.ps1`, volta ao Passo 2.*
