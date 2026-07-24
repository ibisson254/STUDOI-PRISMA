# STATE.md � PRISMA STUDIO

> **Este ficheiro tem dois blocos com donos diferentes.**
> **`[AUTO]`** � escrito pelo `verify.sh` contra o servidor real. **NENHUM agente ou humano edita isto � m�o.**
> **`[MANUAL]`** � narrativa da sess�o. Escrito pelo agente antes de terminar.
>
> Se o bloco MANUAL disser uma coisa e o bloco AUTO disser outra, **o AUTO tem raz�o**. Para e reporta.

---

<!-- AUTO:START -->
## [AUTO] Verdade de terreno

> Gerado por `verify.ps1` â€” **nao editar a mao**.
> **Verificado em:** 2026-07-22T07:52:14+01:00 | **Servidor:** `161.35.19.139` | **Commit:** `3f4ce4a`

Sem falhas criticas. 4 pendencia(s) conhecida(s).

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
| Data do ultimo backup | `2026-07-22` |
| Modelo Gemini configurado | OK `gemini-3.5-flash` |
| escapeHtml presente no compilador | OK |
| escapeAttr presente (safeUrl depende dela) | OK |
| responseSchema (structured output) ativo | OK |
| Typo BEM-VDO corrigido | OK |
| Workflows registados (sem duplicados) | 5 workflows - DUPLICADO? |
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

## [MANUAL] Sprint 0 � Prote��o do Ativo

> Marca `[x]` **apenas** depois de o `verify.sh` confirmar.

- [x] **0. Rota��o de credenciais** � chave ed25519 ativa; `PasswordAuthentication no` + `PermitRootLogin prohibit-password` aplicados; 25 scripts com password hardcoded eliminados. **Relat�rio de intrus�o: SEM intrusos** (2473 tentativas falhadas = ru�do de bots; todos os logins aceites do IP do operador `213.22.159.91`).
- [x] **1. Firewall + fechar porta 5678** � UFW ativo (22/80/443); n8n em `127.0.0.1:5678`; NGINX proxia apenas `/webhook/`; painel s� por t�nel SSH.
- [x] **2. Backup** � script + cron (03:00) + GPG AES-256 + rota��o 7 dias. Replica��o off-site para `github.com/ibisson254/prisma-backups` via deploy key ed25519 (write access). Push confirmado em 2026-07-16.
- [~] **3. Escaping HTML** � `escapeHtml()`, `escapeAttr()` e `safeUrl()` presentes no Compilador Prisma (confirmado no c�digo do n� Code); typo `BEM-VDO` corrigido; limite de 64 chars no nome do ficheiro. ?? **E2E PENDENTE por quota 429 � n�o confirmado em runtime.**
- [~] **4. Gemini 2.5 Flash + responseSchema** � `models/gemini-2.5-flash`, `temperature 0.85`, `maxOutputTokens 512`, schema `{headline, subheadline}`. N� HTTP Request configurado com credencial `httpHeaderAuth`. ?? **E2E PENDENTE por quota 429.**
- [x] **5. Workflow no Git** � `n8n/tally-onboarding.json` exportado do servidor e commitado. Git espelha o servidor.

---

## ?? [MANUAL] BLOCKERS � Sprint 0 N�O est� fechado

### A/B. Workflow e Compilador (Tecnicamente Resolvidos, Pendente 429)
O workflow foi limpo, reconfigurado com um n� `Prepara Gemini Payload` (para evitar parsing errors inline), os headers foram corrigidos, e as fun��es de sanitiza��o (`escapeAttr`) est�o injetadas e ativas.
O pipeline processa corretamente o Webhook e chega � chamada do Gemini, mas bate na quota da API (**HTTP 429 Too Many Requests**).
*Assim que a quota resetar ou houver upgrade (billing), correr `/root/scripts/test-e2e.sh` para fechar o blocker.*

### C. Backup off-site ? FECHADO
Repo privado `github.com/ibisson254/prisma-backups` criado. Deploy key `ed25519` com write access adicionada. Push confirmado sem erros em 2026-07-16.
Backup completo (BD + config + workflows + builds) cifrado GPG ? push autom�tico no cron das 03:00.

### Menores
- **Dois workflows com o mesmo nome** (`66d5ac7f8c71179f` e `tally-onboarding-wf`). Apagar o �rf�o.
- Password de root ainda por trocar (baixa urg�ncia � password auth desativado).

---

## ? [MANUAL] PERGUNTA EM ABERTO

> **O "Projeto Ra�zes" alguma vez foi gerado a partir de uma submiss�o REAL do Tally, ou s� por execu��o manual dentro do n8n?**

A auditoria e o relat�rio do Sprint 0 dizem ambos que a rota do webhook nunca esteve registada. Se for esse o caso, **a PoC "zero-click" pode nunca ter corrido de ponta a ponta** � e isso muda o que consideramos validado.

---

## [MANUAL] Onde par�mos

**�ltima sess�o:** 2026-07-22 07:47 � por: agente (Claude Code)
**O que aconteceu:** Fase 6 confirmada como PENDENTE (n�o fechada) e registada formalmente na sec��o "Motor v2" acima. Executada a Fase 7 (SPEC-MOTOR-V2-IMOBILIARIO.md �9): disparado o webhook real `imovel-landing` 3 vezes com dados fict�cios de 3 im�veis deliberadamente diferentes (praia/luxo, urbano/premium, rural/car�ter), sem logo. As 3 landings foram publicadas de facto no servidor, verificadas via sweep de placeholders, contagem de hero-block/h1, presen�a de lightbox/v�deo/formul�rio/ficha t�cnica/banner, e auditadas com Lighthouse mobile real (Chrome headless local contra o servidor). Resultado completo na sec��o "Fase 7" acima, incluindo uma **falha do sistema anti-gen�rico** (2 dos 3 im�veis sa�ram com o mesmo arqu�tipo+fontes) e **performance mobile abaixo do alvo ?90 nos 3** (74/70/73), com causas j� conhecidas (HTTP puro, Tailwind CDN dev-only, imagens n�o otimizadas, droplet de 1GB).
**BLOCKER FASE 6 (inalterado):** A API do Brevo retornou 201 (aceite na fila) e registou a execu��o com MessageId oficial (ex: <202607202251.77276665287@smtp-relay.mailin.fr>), MAS o dashboard rejeitou o envio posterior com: \Sending rejected because the sender leads@prismastudio.pt is not valid.\. Isto ocorre porque o dom�nio prismastudio.pt n�o est� configurado e o sender n�o est� verificado na conta Brevo. O workflow j� foi adaptado para ler das vari�veis de ambiente n8n (\{{ $env.BREVO_SENDER_EMAIL || 'leads@prismastudio.pt' }}\) para trocar o remetente sem reimportar o c�digo. A Fase 6 FICA PENDENTE de verifica��o de sender e chegada do e-mail � caixa de entrada do operador. **N�o bloqueou a Fase 7** (que n�o depende de e-mail).

### Pend�ncias fora do Sprint 0
- **HTTPS** � bloqueado: Let's Encrypt n�o emite para IPs. Precisa de dom�nio.
- **Classificador de risco** � Sprint 1
- **HMAC no webhook, Error Workflow, retry** � Sprint 3
- **Supabase site_state** � Sprint 3. Sem isto, altera��es de cliente s�o tecnicamente imposs�veis.

## ?? [MANUAL] PR�XIMO PASSO (um s�)

> **Decis�o do operador sobre as 3 landings da Fase 7 (ver evid�ncias na sec��o "Fase 7" acima) antes de qualquer avan�o.**
>
> Duas falhas concretas para o operador julgar: (1) 2 dos 3 im�veis sa�ram com o mesmo arqu�tipo+fontes (falha do anti-gen�rico); (2) Lighthouse mobile 70�74 de performance, abaixo do alvo ?90 nos 3, por causas j� conhecidas (HTTP puro, Tailwind CDN dev-only, imagens sem otimiza��o). Se aprovado apesar destas falhas, o pr�ximo passo t�cnico natural � resolver o CSS compilado (remover Tailwind CDN) e otimiza��o de imagens antes de qualquer link a cliente real � que j� est� bloqueado por HTTPS/dom�nio (ver bloco (a) acima). Sprint 1 (dom�nios) continua como pend�ncia paralela, n�o dependente desta decis�o.

Ficheiro de refer�ncia: `sprint-1-dominios.md`

---

## [MANUAL] Motor v2 � Imobili�rio de Luxo (SPEC-MOTOR-V2-IMOBILIARIO.md)

**Sess�o:** 2026-07-18/19 � Fases 1-5 executadas e aprovadas pelo operador (Fase 5 aprovada explicitamente em 2026-07-19).

### Estado
- Fase 1: `src/imovel_template.html` � 3 arqu�tipos (cinematic/editorial/gallery_first), CSS vars, form agendamento. ?
- Fase 2: prompt+schema Gemini v2, workflow `imovel-landing-wf` (novo, `tally-onboarding-wf` n�o tocado). Modelo `gemini-3.5-flash` validado contra `/models`. ?
- Fase 3: Compilador v2 � sweep de placeholders, isolamento de arqu�tipo (1 hero/1 h1), XSS testado em todos os campos. ?
- Fase 4: `docs/SCHEMA_TALLY_IMOVEL.md` � spec do formul�rio para o operador construir no Tally.so (sem API do Tally neste ambiente). Testado com envelope Tally real (FILE_UPLOAD, CHECKBOXES, v�deo). ?
- Fase 5: Deploy via NGINX/DigitalOcean (decis�o do operador � sem token Cloudflare dispon�vel); banner de countdown; cron de expira��o hor�rio (`imovel-cron-expiracao-wf`); `state.json` persistido por landing; ficheiros usam `{slug}-{token}.html` com token n�o determin�stico (V1 confirmado); reativa��o sem chamar o Gemini (`imovel-reativar-wf`, V2 confirmado � diff id�ntico exceto banner). ?
- **Fase 6: PENDENTE (bloqueada, n�o fechada).** Webhook de agendamento (`imovel-agendamento-wf`) configurado, credencial Brevo inserida pela via segura (API REST), workflow importado com sucesso. A API do Brevo aceitou o pedido (HTTP 201, MessageId oficial devolvido), **mas o e-mail nunca chegou � caixa do operador** � o dashboard Brevo rejeitou o envio a jusante com `Sending rejected because the sender leads@prismastudio.pt is not valid`, porque o dom�nio `prismastudio.pt` n�o est� configurado/verificado na conta Brevo. O workflow j� l� o remetente de `$env.BREVO_SENDER_EMAIL` para permitir trocar sem reimportar. **N�o fechar esta fase at� um envio real ser confirmado na caixa de entrada.** N�o bloqueia a Fase 7 (que n�o depende de e-mail).

### ?? (a) Pr�-requisito de venda � BLOQUEANTE antes de qualquer link a cliente real
> **Nenhum link de preview pode ser entregue a um cliente/lead real enquanto o hosting for `http://161.35.19.139/...`.**

Falta, por esta ordem, antes de qualquer uso comercial:
1. **Dom�nio de preview** (ex.: um subdom�nio pr�prio tipo `preview.prismastudio.pt` ou a migra��o para Cloudflare Pages j� prevista na spec) � o IP nu n�o � apresent�vel a um cliente pagante nem a um lead de imobili�rio de luxo.
2. **HTTPS** � atualmente imposs�vel (Let's Encrypt n�o emite para IPs; SSL/HTTPS j� consta como `PENDENTE` no bloco `[AUTO]` acima, bloqueado por falta de dom�nio). Um formul�rio de agendamento com dados pessoais (nome, telefone, email) servido em HTTP puro � uma falha de confian�a e de conformidade.

**Isto n�o bloqueia os testes internos da Fase 7** (o operador aprova por link HTTP interno), mas **bloqueia qualquer entrega a cliente/lead real** e deve ser resolvido antes do Sprint de Pagamento (Ifthenpay/dom�nio), j� adiado para depois da Fase 7 por decis�o anterior do operador.

### (b) Limpeza pendente � workflows tempor�rios no n8n
5 workflows de teste, todos **inativos** (unpublished, sem rota registada � zero risco em produ��o), criados durante a valida��o de capacidades da inst�ncia (Code node HTTP/fs/exec, cron, helpers). Precisam de remo��o manual pela UI do n8n � n�o h� comando CLI de delete no n8n 2.29.10, e por regra do AGENT.md n�o se edita o SQLite diretamente:

| ID | Nome | Prop�sito (j� cumprido) |
|---|---|---|
| `temp-test-code-http-wf` | TEMP - Test Code HTTP | validar `this.helpers.httpRequest` em Code node |
| `temp-test-fs-wf` | TEMP - Test FS Code | confirmar que `fs` est� bloqueado no sandbox |
| `temp-test-exec-wf` | TEMP - Test Exec Command | confirmar que o n� Execute Command n�o est� instalado |
| `temp-test-cron-wf` | TEMP - Test Cron Logic | validar a l�gica de expira��o antes do Schedule Trigger real |
| `temp-probe-helpers-wf` | TEMP - Probe Helpers | listar `this.helpers` dispon�veis (n�o h� UUID/crypto) |

**A��o:** apagar os 5 pela UI (`Workflows` ? selecionar ? Delete) numa pr�xima sess�o com acesso ao painel.

### Fase 7 � As 3 landings de prova (executada 2026-07-22)

Disparado o webhook real (`POST http://161.35.19.139/webhook/imovel-landing`) com 3 im�veis fict�cios deliberadamente diferentes (praia/luxo, urbano/premium, rural/car�ter). Sem logo nos 3 (testa o wordmark). Verifica��o feita a partir do HTML e `state.json` **realmente publicados no servidor**, n�o de uma simula��o.

**Links (preview HTTP, expiram 24h ap�s 2026-07-22T06:3x):**
1. Comporta: `http://161.35.19.139/moradia-t5-frente-ao-mar-comporta-mrvpfgr76j2b4v5h27zt.html`
2. Pr�ncipe Real: `http://161.35.19.139/penthouse-t3-com-terraco-principe-real-lisboa-mrvpgjp9b2ikw2pqzk9x.html`
3. Alentejo: `http://161.35.19.139/quinta-restaurada-com-lagar-alentejo-mrvpi8tpugapzmgzl3wa.html`

**Crit�rios de aceita��o (�9):**
| Crit�rio | Resultado |
|---|---|
| 3 completas, zero placeholders/fallback | ? Sweep `{{...}}` e `<!--IF:...-->` limpo nos 3; compilador tamb�m validou hero-block=1 e h1=1 nos 3 (falharia a execu��o caso contr�rio) |
| 3 visualmente distintas | ? **FALHA PARCIAL** � ver abaixo |
| Galeria com lightbox funcional | ? 6/8/6 fotos, `#lightbox` presente nos 3 |
| V�deo embutido no im�vel 2 | ? `<iframe src="https://www.youtube.com/embed/jNQXAC9IVRw">` confirmado no HTML |
| Ficha t�cnica preenchida | ? pre�o/tipologia/�rea/quartos/wc presentes nos 3 |
| Formul�rio de agendamento | ? presente, `data-endpoint="http://161.35.19.139/webhook/agendar-visita"` |
| Headline usa detalhe �nico | ? confirmado nos 3 (ver headlines abaixo) |
| Lighthouse mobile ? 90 | ? **FALHA** � ver scores abaixo |
| Banner de preview com countdown | ? `#preview-banner` presente nos 3 |

**?? FALHA DO SISTEMA ANTI-GEN�RICO (reportada por regra expl�cita do teste):** Im�vel 1 (Comporta) e Im�vel 2 (Pr�ncipe Real) sa�ram ambos com arqu�tipo `cinematic` **e** o mesmo par de fontes `Marcellus + Mulish`. As paletas diferem (areia/azul-atl�ntico vs. grafite/dourado) e o conte�do � claramente distinto, mas a estrutura visual (hero full-screen) e a tipografia s�o id�nticas entre dois im�veis de posicionamento muito diferente (praia vs. penthouse urbana). Im�vel 3 (Alentejo) saiu distinto (`editorial`, Cormorant Garamond + Inter). Com pool de 3 arqu�tipos e 5 pares de fontes, a taxa de colis�o em 3 gera��es n�o � desprez�vel — **recomenda-se** ou (a) aumentar a temperatura/pool, ou (b) o compilador impor no-repeat de arqu�tipo+fontes dentro da mesma sess�o/imobili�ria, antes de qualquer uso comercial com m�ltiplos im�veis da mesma agncia.

**Direction sheets:**

| | Im�vel 1 � Comporta | Im�vel 2 � Pr�ncipe Real | Im�vel 3 � Alentejo |
|---|---|---|---|
| Arqu�tipo | cinematic | cinematic | editorial |
| Fontes | Marcellus + Mulish | Marcellus + Mulish | Cormorant Garamond + Inter |
| Paleta | bg #FAF8F5 / ink #14213D / accent #C5A880 (areia + azul-atl�ntico) | bg #121212 / ink #F4F4F4 / accent #C5A880 (grafite + dourado) | bg #FAF6F0 / ink #1C2421 / accent #A35738 (terracota + oliva) |
| Detalhe �nico no headline | piscina de �gua salgada alinhada com o p�r do sol | terra�o de 80 m� com vista sobre o Tejo e o castelo | lagar de azeite do s�culo XIX restaurado e funcional |
| Justif. arqu�tipo | "Valorizar a escala monumental da 1� linha de mar [...] emulando a sensa��o de imers�o total" | "Potenciar o forte impacto visual do terra�o [...] e a presen�a de v�deo promocional" | "Narrativa visual pausada e sofisticada [...] simula o design de uma revista de arquitetura" |

**Headlines + subheadlines:**
1. **Comporta:** "Uma piscina de �gua salgada alinhada com o p�r do sol" / "Desenhada sob a tradicional arquitetura de madeira e cal, esta moradia T5 oferece uma transi��o invis�vel entre o design minimalista e as dunas intocadas do Atl�ntico."
2. **Pr�ncipe Real:** "Onde a vida se estende num terra�o de 80 m� com vista sobre o Tejo e o castelo" / "Uma penthouse T3 meticulosamente desenhada num edif�cio pombalino reabilitado, combinando a heran�a hist�rica com o conforto contempor�neo."
3. **Alentejo:** "Uma heran�a viva: Quinta hist�rica com lagar de azeite do s�culo XIX restaurado e funcional" / "Com quatro hectares de terra f�rtil, esta propriedade de 1890 une o rigor da preserva��o contempor�nea � tradi��o de um olival centen�rio em plena produ��o."

**Lighthouse mobile (Chrome headless local, simulated throttling, contra o servidor real):**
| | Performance | Accessibility | Best Practices | SEO |
|---|---|---|---|---|
| Comporta | **74** | 96 | 78 | 100 |
| Pr�ncipe Real | **70** | 100 | 74 | 100 |
| Alentejo | **73** | 96 | 56 | 100 |

**Performance fica abaixo do alvo (?90) nos 3 � causas identificadas nos audits, todas conhecidas e j� documentadas:**
- `is-on-https`/`redirects-http` = 0 nos 3 (esperado: hosting HTTP puro no IP, j� bloqueante para cliente real por decis�o anterior, ver bloco (a) acima)
- Tailwind via CDN (`<script src="https://cdn.tailwindcss.com">`) marcado no pr�prio template como "DEV ONLY: substituir por CSS compilado em produ��o" � maior contribuidor para `render-blocking-insight` e `unused-javascript`
- Imagens Unsplash/Wikimedia servidas no tamanho original sem `srcset`/responsive � `image-delivery-insight` estima 1.8�2.1 MB de poupan�a poss�vel por p�gina
- `document-latency-insight` (~2.3s) consistente com o droplet de 1 vCPU / 1 GB RAM + swap
- Best Practices do Alentejo (56) mais baixo por `inspector-issues` (avisos no DevTools) al�m dos itens comuns acima
- Nenhuma destas causas � nova: HTTPS j� consta `PENDENTE` no bloco `[AUTO]`, e o CSS compilado em produ��o j� est� assinalado como pend�ncia no pr�prio template desde a Fase 1.

**Placeholder sweep (evid�ncia):** `grep -oE '\{\{[^}]*\}\}'` e `grep -oE '<!--/?IF:[a-z_]+-->'` nos 3 HTML publicados devolveram **zero resultados**. `hero-block` count = 1 e `<h1>` count = 1 nos 3 (o compilador teria abortado a execu��o e nada seria publicado caso contr�rio � confirmado no c�digo, n�o apenas assumido).

**Observa��o menor (n�o bloqueante):** o im�vel 2 (Pr�ncipe Real) devolveu parte da ficha t�cnica/galeria sem acentua��o portuguesa ("Preco", "Area Util") enquanto os im�veis 1 e 3 vieram corretamente acentuados. Copy do LLM, n�o do compilador � n�o houve fallback est�tico, mas vale monitorizar a consist�ncia de diacr�ticos do Gemini entre gera��es.

**Conclus�o Fase 7:** motor produz 3 landings tecnicamente completas, funcionalmente corretas (galeria, lightbox, v�deo, formul�rio, ficha t�cnica, countdown) e sem placeholders — mas **n�o** cumpre 2 dos 8 crit�rios de aceita��o na sua forma mais estrita: diferencia��o visual entre 2 dos 3 im�veis (mesmo arqu�tipo+fontes) e performance mobile abaixo do alvo nos 3. Decis�o de avan�ar ou n�o fica com o operador � esta se��o cont�m as evid�ncias para essa decis�o, n�o uma recomenda��o de aprova��o.

### Achados de seguran�a/engenharia desta sess�o
- **Chave API Gemini em texto simples** em `scratch/list_models2.sh` (linha 2) � n�o commitada no Git, mas em disco. Recomenda-se rota��o e remo��o.
- **`state.json` fica publicamente acess�vel** em `/var/www/prisma-builds/*.state.json` (mesmo document root do NGINX que serve os `.html`) � cont�m NIF, email e WhatsApp do corretor. A migra��o para Cloudflare Pages/Supabase deve tirar isto do document root p�blico.
- Tokens de ficheiro (`{slug}-{token}.html`) usam `Date.now()+Math.random()` � n�o criptograficamente seguros (nem `crypto` nem `require('crypto')` est�o dispon�veis no sandbox do Code node deste n8n). Suficiente para n�o serem adivinh�veis a partir do nome do im�vel/imobili�ria num preview de 24h, mas n�o � um limite de seguran�a forte � reavaliar se o modelo de neg�cio precisar de mais garantias.
- `this.helpers.getBinaryDataBuffer`/`prepareBinaryData` s�o a forma correta e robusta de ler/escrever bin�rios em Code nodes nesta inst�ncia (armazenamento em modo `filesystem-v2`) � recomendo que o `tally-onboarding-wf` (v1) adote o mesmo padr�o como blindagem (n�o alterado nesta sess�o, por instru��o expl�cita de n�o o tocar).

### Sessao 2026-07-24 -- F5/F6/F7 aprovados + G1 (auditoria de contrato de campos)

**F5 (destaques_unicos obrigatorios), F6 (legendas obrigatorias na galeria) e F7 (monograma ignora palavras genericas iniciais) aprovados pelo operador em 2026-07-24**, apos verificacao direta na landing `quinta-restaurada-com-lagar-alentejo-mry57e9hu6zls75my1w5.html`. Implementados no pipeline real de 3 agentes (Diretor de Arte -> Copywriter -> Compilador Editorial), nao no pipeline de agente unico que ainda constava do repo (ver achado de drift abaixo).

**Achado durante F5: bug no proprio harness de teste desta sessao.** O primeiro teste de F5 enviou `destaques_unicos` como array direto no payload; `Prepara Payload Diretor` so le os campos individuais `destaque1`/`destaque2`/`destaque3`. O array nunca era lido, `destaques_unicos` chegava vazio ao pipeline, e o sintoma original reportado (destaques do cliente substituidos por comodidades genericas) foi agravado por este erro de teste, nao apenas por decisao livre do LLM. Corrigido no payload de teste; nao e um bug de producao em si, mas foi o que expos o risco maior descrito a seguir.

**Achado critico: repo e producao tinham divergido.** `n8n/imovel-landing-wf.json` no git ainda refletia a arquitetura antiga de agente unico (`Prepara Payload Gemini` -> `Compilador Imovel v2`, template `imovel_template.html`), enquanto o servidor corria ha varias iteracoes a arquitetura de 3 agentes (`Prepara Payload Diretor` -> `Monta Prompt Diretor` -> `Diretor de Arte` -> `Parseia Diretor e Monta Copywriter` -> `Copywriter` -> `Compilador Editorial`, template `imovel_editorial.html`, ledger de variacao anti-repeticao). O ultimo commit a tocar aquele ficheiro (`0e541be`) e da arquitetura antiga -- todo o trabalho multi-agente, incluindo F5/F6/F7, nunca tinha voltado ao git. Corrigido nesta sessao: `n8n/imovel-landing-wf.json` foi sincronizado a partir de `n8n export:workflow --id=imovel-landing-wf` contra o servidor real (fonte de verdade), antes de qualquer edicao. **Recomenda-se conferir isto no inicio de qualquer sessao futura que toque neste workflow** -- nao assumir que o repo reflete producao sem exportar e comparar primeiro.

**G1 -- bug de silencio: campo nao lido produz pagina plausivel mas sem os dados do cliente. Validacao de entrada obrigatoria.**

Auditoria de contrato (`docs/SCHEMA_TALLY_IMOVEL.md` vs. no `Prepara Payload Diretor`): labels alinhados (correspondencia parcial case-insensitive, confirmado campo a campo). **O formulario Tally de imoveis nao existe como formulario real no Tally.so** -- so existe como spec (`docs/SCHEMA_TALLY_IMOVEL.md`), nunca construido na plataforma (documentado desde a Fase 4: "sem API do Tally neste ambiente"). Esse doc e agora o contrato canonico contra o qual o Tally real tem de ser construido.

Risco confirmado no codigo (antes da correcao desta sessao): 5 campos obrigatorios tinham fallback mascarante que engolia a ausencia em silencio -- `imobiliaria` -> `"Imobiliaria Prisma"`, `titulo` -> `"Imovel Exclusivo"`, `preco` -> `"Sob consulta"`, `corretor.nome` -> nome da imobiliaria, e **`corretor.whatsapp` -> `"+351900000000"`** (numero de telefone inventado publicado como contacto real de agendamento). Nenhum destes gerava erro; todos produziam uma landing publicavel e aparentemente completa.

**Correcao aplicada em `Prepara Payload Diretor`:** removidos os 5 fallbacks mascarantes; adicionada validacao fail-loud logo apos a leitura do payload, antes de qualquer chamada ao Gemini (poupa custo e falha o mais cedo possivel). Campos obrigatorios verificados: imobiliaria, titulo, preco, tipologia, area, quartos, wc, localizacao, destaque1/2/3, corretor.nome/whatsapp/email, nif, e fotos (minimo 4). Qualquer um vazio ou ausente -> `throw new Error(...)` com a lista completa dos campos em falta; nada e publicado. Campos opcionais (logo, video_url, extras, ano) continuam a poder faltar em silencio, por decisao explicita.

Testado localmente (5 cenarios: completo, falta destaque2, so 2 fotos, falta whatsapp do corretor, payload vazio -- todos com o resultado esperado) e depois E2E contra o webhook real em producao: payload com `destaque2` vazio -> `HTTP 500`, nenhum ficheiro novo em `/var/www/prisma-builds/`; payload completo -> `HTTP 200`, landing publicada normalmente com os 3 destaques corretamente atribuidos (`destaques_backstop_indices: []`).

---

## Protocolo de fim de sess�o (obrigat�rio)

```bash
./verify.sh                    # reescreve o bloco [AUTO]
git diff STATE.md              # o que mudou na REALIDADE
# atualizar blocos [MANUAL]
git add -A && git commit -m "state: <resumo factual>" && git push
```

**Uma sess�o que n�o corre o `verify.sh` e n�o atualiza este ficheiro partiu a cadeia.**

- 2� viola��o da regra SQLite, mesmo sintoma (404). A regra n�o tem exce��es, nem para credenciais.





