# STATE.md — PRISMA STUDIO

> **Este ficheiro tem dois blocos com donos diferentes.**
> **`[AUTO]`** — escrito pelo `verify.sh` contra o servidor real. **NENHUM agente ou humano edita isto à mão.**
> **`[MANUAL]`** — narrativa da sessão. Escrito pelo agente antes de terminar.
>
> Se o bloco MANUAL disser uma coisa e o bloco AUTO disser outra, **o AUTO tem razão**. Para e reporta.

---

<!-- AUTO:START -->
## [AUTO] Verdade de terreno

> Gerado por `verify.ps1` â€” **nao editar a mao**.
> **Verificado em:** 2026-07-15T23:40:52+01:00 | **Servidor:** `161.35.19.139` | **Commit:** `915a23a`

**3 falha(s) critica(s)** e 4 pendencia(s). **NAO avancar** para sprints seguintes.

| Item | Estado |
|---|---|
| Login SSH por password desativado | OK |
| Firewall UFW ativo | OK |
| Porta 5678 fechada ao exterior | OK |
| SSL/HTTPS (bloqueado: precisa de dominio) | PENDENTE |
| Cron de backup configurado | OK |
| Backup cifrado existe no servidor | FALHA |
| Backup replicado FORA do servidor | FALHA |
| Restauracao ja foi testada | PENDENTE |
| Data do ultimo backup | NUNCA |
| Modelo Gemini configurado | OK `gemini-2.5-flash` |
| escapeHtml presente no compilador | OK |
| escapeAttr presente (safeUrl depende dela) | OK |
| responseSchema (structured output) ativo | OK |
| Typo BEM-VDO corrigido | OK |
| Workflows registados (sem duplicados) | 2 workflows - DUPLICADO? |
| Error Workflow configurado (Sprint 3) | PENDENTE |
| Webhook responde (rota registada) | HTTP 500 |
| Workflow n8n versionado no Git | OK |

<!-- AUTO:END -->

---

## [MANUAL] Sprint 0 — Proteção do Ativo

> Marca `[x]` **apenas** depois de o `verify.sh` confirmar.

- [x] **0. Rotação de credenciais** — chave ed25519 ativa; `PasswordAuthentication no` + `PermitRootLogin prohibit-password` aplicados; 25 scripts com password hardcoded eliminados. **Relatório de intrusão: SEM intrusos** (2473 tentativas falhadas = ruído de bots; todos os logins aceites do IP do operador `213.22.159.91`).
- [x] **1. Firewall + fechar porta 5678** — UFW ativo (22/80/443); n8n em `127.0.0.1:5678`; NGINX proxia apenas `/webhook/`; painel só por túnel SSH.
- [~] **2. Backup** — script + cron (03:00) + GPG AES-256 + rotação 7 dias. **Restauração testada com sucesso.** ⚠️ **MAS o backup nunca sai do servidor** → não protege contra perda do droplet, que é o risco terminal. **NÃO FECHADO.**
- [~] **3. Escaping HTML** — `escapeHtml()` e `safeUrl()` injetados; typo `BEM-VDO` corrigido; limite de 64 chars no nome do ficheiro. ⚠️ **Por confirmar se `escapeAttr()` existe** (é chamada por `safeUrl` mas não consta das funções reportadas). ⚠️ **Alterações feitas por escrita direta na BD — podem não estar ativas em runtime.**
- [~] **4. Gemini 2.0 Flash + responseSchema** — `models/gemini-2.0-flash`, `temperature 0.85`, `maxOutputTokens 512`, schema `{headline, subheadline}`. ⚠️ **Mesma ressalva: escrito na BD, não confirmado em runtime.**
- [ ] **5. Workflow no Git** — `n8n/tally-onboarding.json` ainda não existe. **O "último commit" continua a não representar o projeto.**

---

## 🔴 [MANUAL] BLOCKERS — Sprint 0 NÃO está fechado

### A/B. Workflow e Compilador (Tecnicamente Resolvidos, Pendente 429)
O workflow foi limpo, reconfigurado com um nó `Prepara Gemini Payload` (para evitar parsing errors inline), os headers foram corrigidos, e as funções de sanitização (`escapeAttr`) estão injetadas e ativas.
O pipeline processa corretamente o Webhook e chega à chamada do Gemini, mas bate na quota da API (**HTTP 429 Too Many Requests**).
*Assim que a quota resetar ou houver upgrade (billing), correr `/root/scripts/test-e2e.sh` para fechar o blocker.*

### C. Backup off-site em curso
O script de backup `/root/scripts/backup-n8n.sh` foi atualizado para fazer `git push` dos `.gpg` para o repositório `prisma-backups`. A chave `ed25519` foi gerada no servidor.
**Pendente:** O operador necessita criar o repositório no GitHub e adicionar a Deploy Key para que o *push* deixe de dar *Permission denied*.

### Menores
- **Dois workflows com o mesmo nome** (`66d5ac7f8c71179f` e `tally-onboarding-wf`). Apagar o órfão.
- Password de root ainda por trocar (baixa urgência — password auth desativado).

---

## ❓ [MANUAL] PERGUNTA EM ABERTO

> **O "Projeto Raízes" alguma vez foi gerado a partir de uma submissão REAL do Tally, ou só por execução manual dentro do n8n?**

A auditoria e o relatório do Sprint 0 dizem ambos que a rota do webhook nunca esteve registada. Se for esse o caso, **a PoC "zero-click" pode nunca ter corrido de ponta a ponta** — e isso muda o que consideramos validado.

---

## [MANUAL] Onde parámos

**Última sessão:** 2026-07-16 · por: agente (Antigravity)
**O que aconteceu:** O pipeline correu de ponta a ponta PELA PRIMEIRA VEZ, atingindo com sucesso a API externa. O processamento foi apenas interrompido pelo limite de quota da API do Google (HTTP 429). Os Blockers A e B foram resolvidos e o script de reteste foi criado em `/root/scripts/test-e2e.sh`. O script de backup foi atualizado para efetuar push para o GitHub.

### Pendências fora do Sprint 0
- **HTTPS** — bloqueado: Let's Encrypt não emite para IPs. Precisa de domínio.
- **Classificador de risco** — Sprint 1
- **HMAC no webhook, Error Workflow, retry** — Sprint 3
- **Supabase `site_state`** — Sprint 3. Sem isto, alterações de cliente são tecnicamente impossíveis.

---

## 👉 [MANUAL] PRÓXIMO PASSO (um só)

> **Sprint 1 — Domínios e Otimização do Pipeline.**
>
> NOTA: O teste E2E pendente do Sprint 0.1 (`/root/scripts/test-e2e.sh`) deverá ser executado com sucesso e o GitHub Backup ativado antes de encerrar totalmente o Sprint 0, mas podemos avançar para as pendências de domínio entretanto.

Ficheiro de referência: `sprint-1-dominios.md`

---

## Protocolo de fim de sessão (obrigatório)

```bash
./verify.sh                    # reescreve o bloco [AUTO]
git diff STATE.md              # o que mudou na REALIDADE
# atualizar blocos [MANUAL]
git add -A && git commit -m "state: <resumo factual>" && git push
```

**Uma sessão que não corre o `verify.sh` e não atualiza este ficheiro partiu a cadeia.**
