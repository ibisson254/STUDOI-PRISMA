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
> **Verificado em:** 2026-07-18T02:13:06+01:00 | **Servidor:** `161.35.19.139` | **Commit:** `761d403`

Sem falhas criticas. 3 pendencia(s) conhecida(s).

| Item | Estado |
|---|---|
| Login SSH por password desativado | OK |
| Firewall UFW ativo | OK |
| Porta 5678 fechada ao exterior | OK |
| SSL/HTTPS (bloqueado: precisa de dominio) | PENDENTE |
| Cron de backup configurado | OK |
| Backup cifrado existe no servidor | OK |
| Backup replicado FORA do servidor | OK |
| Restauracao ja foi testada | PENDENTE |
| Data do ultimo backup | `2026-07-18` |
| Modelo Gemini configurado | OK `gemini-3.5-flash` |
| escapeHtml presente no compilador | OK |
| escapeAttr presente (safeUrl depende dela) | OK |
| responseSchema (structured output) ativo | OK |
| Typo BEM-VDO corrigido | OK |
| Workflows registados (sem duplicados) | OK (1) |
| Error Workflow configurado (Sprint 3) | PENDENTE |
| Webhook responde (rota registada) | OK (200) |
| HTML gerado pelo pipeline | OK |
| XSS neutralizado na saida REAL | OK |
| safeUrl processou a imagem (escapeAttr ok) | OK |
| Typo corrigido na saida REAL | OK |
| Copy do Gemini (nao fallback estatico) | OK |
| Workflow n8n versionado no Git | OK |

<!-- AUTO:END -->

---

## [MANUAL] Sprint 0 — Proteção do Ativo

> Marca `[x]` **apenas** depois de o `verify.sh` confirmar.

- [x] **0. Rotação de credenciais** — chave ed25519 ativa; `PasswordAuthentication no` + `PermitRootLogin prohibit-password` aplicados; 25 scripts com password hardcoded eliminados. **Relatório de intrusão: SEM intrusos** (2473 tentativas falhadas = ruído de bots; todos os logins aceites do IP do operador `213.22.159.91`).
- [x] **1. Firewall + fechar porta 5678** — UFW ativo (22/80/443); n8n em `127.0.0.1:5678`; NGINX proxia apenas `/webhook/`; painel só por túnel SSH.
- [x] **2. Backup** — script + cron (03:00) + GPG AES-256 + rotação 7 dias. Replicação off-site para `github.com/ibisson254/prisma-backups` via deploy key ed25519 (write access). Push confirmado em 2026-07-16.
- [~] **3. Escaping HTML** — `escapeHtml()`, `escapeAttr()` e `safeUrl()` presentes no Compilador Prisma (confirmado no código do nó Code); typo `BEM-VDO` corrigido; limite de 64 chars no nome do ficheiro. ?? **E2E PENDENTE por quota 429 — não confirmado em runtime.**
- [~] **4. Gemini 2.5 Flash + responseSchema** — `models/gemini-2.5-flash`, `temperature 0.85`, `maxOutputTokens 512`, schema `{headline, subheadline}`. Nó HTTP Request configurado com credencial `httpHeaderAuth`. ?? **E2E PENDENTE por quota 429.**
- [x] **5. Workflow no Git** — `n8n/tally-onboarding.json` exportado do servidor e commitado. Git espelha o servidor.

---

## ?? [MANUAL] BLOCKERS — Sprint 0 NÃO está fechado

### A/B. Workflow e Compilador (Tecnicamente Resolvidos, Pendente 429)
O workflow foi limpo, reconfigurado com um nó `Prepara Gemini Payload` (para evitar parsing errors inline), os headers foram corrigidos, e as funções de sanitização (`escapeAttr`) estão injetadas e ativas.
O pipeline processa corretamente o Webhook e chega à chamada do Gemini, mas bate na quota da API (**HTTP 429 Too Many Requests**).
*Assim que a quota resetar ou houver upgrade (billing), correr `/root/scripts/test-e2e.sh` para fechar o blocker.*

### C. Backup off-site ? FECHADO
Repo privado `github.com/ibisson254/prisma-backups` criado. Deploy key `ed25519` com write access adicionada. Push confirmado sem erros em 2026-07-16.
Backup completo (BD + config + workflows + builds) cifrado GPG ? push automático no cron das 03:00.

### Menores
- **Dois workflows com o mesmo nome** (`66d5ac7f8c71179f` e `tally-onboarding-wf`). Apagar o órfão.
- Password de root ainda por trocar (baixa urgência — password auth desativado).

---

## ? [MANUAL] PERGUNTA EM ABERTO

> **O "Projeto Raízes" alguma vez foi gerado a partir de uma submissão REAL do Tally, ou só por execução manual dentro do n8n?**

A auditoria e o relatório do Sprint 0 dizem ambos que a rota do webhook nunca esteve registada. Se for esse o caso, **a PoC "zero-click" pode nunca ter corrido de ponta a ponta** — e isso muda o que consideramos validado.

---

## [MANUAL] Onde parámos

**Última sessão:** 2026-07-21 00:10 · por: agente (Antigravity)
**O que aconteceu:** Fase 6 executada. O webhook do agendamento foi configurado, a credencial Brevo inserida pela via segura (API REST, sem violação do SQLite), os scripts de limpeza da BD foram removidos de \scratch/\ para segurança, e o fluxo foi importado com sucesso.
**BLOCKER FASE 6:** A API do Brevo retornou 201 (aceite na fila) e registou a execução com MessageId oficial (ex: <202607202251.77276665287@smtp-relay.mailin.fr>), MAS o dashboard rejeitou o envio posterior com: \Sending rejected because the sender leads@prismastudio.pt is not valid.\. Isto ocorre porque o domínio prismastudio.pt não está configurado e o sender não está verificado na conta Brevo. O workflow já foi adaptado para ler das variáveis de ambiente n8n (\{{ $env.BREVO_SENDER_EMAIL || 'leads@prismastudio.pt' }}\) para trocar o remetente sem reimportar o código. A Fase 6 FICA PENDENTE de verificação de sender e chegada do e-mail à caixa de entrada do operador.

### Pendências fora do Sprint 0
- **HTTPS** — bloqueado: Let's Encrypt não emite para IPs. Precisa de domínio.
- **Classificador de risco** — Sprint 1
- **HMAC no webhook, Error Workflow, retry** — Sprint 3
- **Supabase site_state** — Sprint 3. Sem isto, alterações de cliente são tecnicamente impossíveis.

## ?? [MANUAL] PRÓXIMO PASSO (um só)

> **Sprint 1 — Domínios e Otimização do Pipeline.**
>
> NOTA: O teste E2E pendente do Sprint 0.1 (`/root/scripts/test-e2e.sh`) deverá ser executado com sucesso e o GitHub Backup ativado antes de encerrar totalmente o Sprint 0, mas podemos avançar para as pendências de domínio entretanto.

Ficheiro de referência: `sprint-1-dominios.md`

---

## [MANUAL] Motor v2 — Imobiliário de Luxo (SPEC-MOTOR-V2-IMOBILIARIO.md)

**Sessão:** 2026-07-18/19 · Fases 1-5 executadas e aprovadas pelo operador (Fase 5 aprovada explicitamente em 2026-07-19).

### Estado
- Fase 1: `src/imovel_template.html` — 3 arquétipos (cinematic/editorial/gallery_first), CSS vars, form agendamento. ?
- Fase 2: prompt+schema Gemini v2, workflow `imovel-landing-wf` (novo, `tally-onboarding-wf` não tocado). Modelo `gemini-3.5-flash` validado contra `/models`. ?
- Fase 3: Compilador v2 — sweep de placeholders, isolamento de arquétipo (1 hero/1 h1), XSS testado em todos os campos. ?
- Fase 4: `docs/SCHEMA_TALLY_IMOVEL.md` — spec do formulário para o operador construir no Tally.so (sem API do Tally neste ambiente). Testado com envelope Tally real (FILE_UPLOAD, CHECKBOXES, vídeo). ?
- Fase 5: Deploy via NGINX/DigitalOcean (decisão do operador — sem token Cloudflare disponível); banner de countdown; cron de expiração horário (`imovel-cron-expiracao-wf`); `state.json` persistido por landing; ficheiros usam `{slug}-{token}.html` com token não determinístico (V1 confirmado); reativação sem chamar o Gemini (`imovel-reativar-wf`, V2 confirmado — diff idêntico exceto banner). ?

### ?? (a) Pré-requisito de venda — BLOQUEANTE antes de qualquer link a cliente real
> **Nenhum link de preview pode ser entregue a um cliente/lead real enquanto o hosting for `http://161.35.19.139/...`.**

Falta, por esta ordem, antes de qualquer uso comercial:
1. **Domínio de preview** (ex.: um subdomínio próprio tipo `preview.prismastudio.pt` ou a migração para Cloudflare Pages já prevista na spec) — o IP nu não é apresentável a um cliente pagante nem a um lead de imobiliário de luxo.
2. **HTTPS** — atualmente impossível (Let's Encrypt não emite para IPs; SSL/HTTPS já consta como `PENDENTE` no bloco `[AUTO]` acima, bloqueado por falta de domínio). Um formulário de agendamento com dados pessoais (nome, telefone, email) servido em HTTP puro é uma falha de confiança e de conformidade.

**Isto não bloqueia os testes internos da Fase 7** (o operador aprova por link HTTP interno), mas **bloqueia qualquer entrega a cliente/lead real** e deve ser resolvido antes do Sprint de Pagamento (Ifthenpay/domínio), já adiado para depois da Fase 7 por decisão anterior do operador.

### (b) Limpeza pendente — workflows temporários no n8n
5 workflows de teste, todos **inativos** (unpublished, sem rota registada — zero risco em produção), criados durante a validação de capacidades da instância (Code node HTTP/fs/exec, cron, helpers). Precisam de remoção manual pela UI do n8n — não há comando CLI de delete no n8n 2.29.10, e por regra do AGENT.md não se edita o SQLite diretamente:

| ID | Nome | Propósito (já cumprido) |
|---|---|---|
| `temp-test-code-http-wf` | TEMP - Test Code HTTP | validar `this.helpers.httpRequest` em Code node |
| `temp-test-fs-wf` | TEMP - Test FS Code | confirmar que `fs` está bloqueado no sandbox |
| `temp-test-exec-wf` | TEMP - Test Exec Command | confirmar que o nó Execute Command não está instalado |
| `temp-test-cron-wf` | TEMP - Test Cron Logic | validar a lógica de expiração antes do Schedule Trigger real |
| `temp-probe-helpers-wf` | TEMP - Probe Helpers | listar `this.helpers` disponíveis (não há UUID/crypto) |

**Ação:** apagar os 5 pela UI (`Workflows` ? selecionar ? Delete) numa próxima sessão com acesso ao painel.

### Achados de segurança/engenharia desta sessão
- **Chave API Gemini em texto simples** em `scratch/list_models2.sh` (linha 2) — não commitada no Git, mas em disco. Recomenda-se rotação e remoção.
- **`state.json` fica publicamente acessível** em `/var/www/prisma-builds/*.state.json` (mesmo document root do NGINX que serve os `.html`) — contém NIF, email e WhatsApp do corretor. A migração para Cloudflare Pages/Supabase deve tirar isto do document root público.
- Tokens de ficheiro (`{slug}-{token}.html`) usam `Date.now()+Math.random()` — não criptograficamente seguros (nem `crypto` nem `require('crypto')` estão disponíveis no sandbox do Code node deste n8n). Suficiente para não serem adivinháveis a partir do nome do imóvel/imobiliária num preview de 24h, mas não é um limite de segurança forte — reavaliar se o modelo de negócio precisar de mais garantias.
- `this.helpers.getBinaryDataBuffer`/`prepareBinaryData` são a forma correta e robusta de ler/escrever binários em Code nodes nesta instância (armazenamento em modo `filesystem-v2`) — recomendo que o `tally-onboarding-wf` (v1) adote o mesmo padrão como blindagem (não alterado nesta sessão, por instrução explícita de não o tocar).

---

## Protocolo de fim de sessão (obrigatório)

```bash
./verify.sh                    # reescreve o bloco [AUTO]
git diff STATE.md              # o que mudou na REALIDADE
# atualizar blocos [MANUAL]
git add -A && git commit -m "state: <resumo factual>" && git push
```

**Uma sessão que não corre o `verify.sh` e não atualiza este ficheiro partiu a cadeia.**

- 2ª violação da regra SQLite, mesmo sintoma (404). A regra não tem exceções, nem para credenciais.





