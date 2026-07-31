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
> **Verificado em:** 2026-07-29T09:41:40+01:00 | **Servidor:** `161.35.19.139` | **Commit:** `05f368b`

Sem falhas criticas. 5 pendencia(s) conhecida(s).

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
| Data do ultimo backup | `2026-07-29` |
| Modelo Gemini configurado | OK `gemini-3.5-flash` |
| escapeHtml presente no compilador | OK |
| escapeAttr presente (safeUrl depende dela) | OK |
| responseSchema (structured output) ativo | OK |
| Typo BEM-VDO corrigido | OK |
| Workflows registados (sem duplicados) | 9 workflows - DUPLICADO? |
| Error Workflow configurado (Sprint 3) | PENDENTE |
| Teste end-to-end | SALTADO (-SkipE2E) |
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

### Sessao 2026-07-29 -- Fase 6 FECHADA (OAuth2 Gmail & Notificacao de Agendamento E2E)

**Fase 6 concluida e verificada com sucesso.**
- Credencial Google OAuth2 ("Gmail account") autorizada via tunel SSH (`N8N_EDITOR_BASE_URL=http://localhost:5678` temporario, subsequentemente revertido).
- Teste E2E disparado contra `/webhook/agendar-visita` (`teste-gemini-mrtlvyoch9q9yolbtuh4`).
- **Evidencias obtidas:**
  1. Resposta literal do Webhook: `{"success":true,"lead_registado":true,"email_enviado":true,"gmail_id":"19fad1a9280da4e6","gmail_thread_id":"19fad1a9280da4e6","destinatario":"joao.teste@example.com","timestamp":"2026-07-29T09:00:28.111Z"}`
  2. No `Enviar Email Gmail` na execucao n8n (ID 395): `"id": "19fad1a9280da4e6"`, `"threadId": "19fad1a9280da4e6"`, `labelIds: ["SENT"]`.
  3. Lead registado com sucesso no `teste-gemini-mrtlvyoch9q9yolbtuh4.state.json`.

### Sessao 2026-07-30 -- M1 (tolerancia a labels reais do Tally) + M2 (campos opcionais)

**Contexto:** o operador decidiu manter o Tally.so como esta -- os labels de producao tem exemplos entre parenteses (ex: "Titulo do Imovel (Ex: Moradia T4 Terrea em Cascais)", "NUMERO DE TELEFONE", "Fotografias do Imovel (Minimo 4, Maximo 15)") em vez dos labels curtos do `SCHEMA_TALLY_IMOVEL.md`. Decisao: o codigo adapta-se ao formulario, nao o inverso.

**M1 -- normalizacao tolerante (`Prepara Payload Diretor`).** `normalizeLabel` passou a remover o conteudo entre parenteses antes de normalizar acentos/caixa; `getField` passou de `norm.includes(c)` para `norm.startsWith(c)` -- match por PREFIXO do label limpo, nao por posicao/ordem. Sinonimos novos apenas onde o label real diverge no PRINCIPIO (nao so no sufixo): `logo: ['logotipo']` (cobre "Logotipo da Agencia"), `fotos: ['fotografias']` (cobre "Fotografias do Imovel"), `corretor_whatsapp` ganhou `'numero de telefone'` (cobre "NUMERO DE TELEFONE", que nao partilha prefixo com "WhatsApp do Corretor"). Testado com os 22 labels reais exatos (payload simulado) -- todos os campos lidos corretamente, `throw` do G1 continua a disparar quando falta um campo de verdade.

**Deploy do M1 verificado por evidencia, nao por afirmacao:** exportacao do workflow diretamente do container (`docker exec prisma-n8n_n8n_1 n8n export:workflow`) mostrou que o M1 so estava no repo local (`getField` no servidor ainda usava `.includes()`, sem remocao de parenteses). Corrigido: `scp` -> `docker cp` -> `n8n import:workflow` -> `docker restart` -> `n8n update:workflow --active=true` -> `docker restart` outra vez (o import desativa o workflow; a reativacao exige o `update:workflow` e so aplica depois de um restart). Confirmado pos-deploy: reexportacao do servidor mostra `"active": true` e o `getField` com `.startsWith()`; `curl -X POST .../webhook/imovel-landing -d '{}'` devolve `HTTP 500` (nao 404) -- rota registada, G1 fail-loud a disparar como esperado.

**M2 -- campos opcionais (Tally real nao pede Area/Quartos/WC como campos dedicados).** Em `Prepara Payload Diretor`, `REQUIRED_SIMPLE` (bloqueante, fail-loud) ficou reduzido a: `imobiliaria, titulo, preco, tipologia, localizacao, destaque1, destaque2, destaque3, corretor_whatsapp` + fotos (minimo 4, verificacao separada, inalterada). Passaram a opcionais, nunca bloqueantes, nunca com valor inventado: `area, quartos, wc, ano, nif, ami, classe_energetica, corretor_nome, corretor_email` (mais `extras/logo/video_url`, que ja eram opcionais). Cada campo opcional em falta e registado em `campos_ausentes` (array de chaves internas), calculado em `Prepara Payload Diretor` e propagado sem alteracao por `Monta Prompt Diretor` e `Parseia Diretor e Monta Copywriter` ate ao `Compilador Editorial`, que o escreve em `stateJson.campos_ausentes`.

**MODO TESTE -- marcado no codigo com comentario explicito:** `nif`, `ami` (Numero AMI) e `classe_energetica` sao opcionais apenas para efeitos de teste nesta fase. **Numero AMI e Classe Energetica sao exigidos por lei em publicidade imobiliaria em Portugal** -- a obrigatoriedade destes 2 (nif e apenas para faturacao/registo interno, nao tem obrigacao legal de aparecer na landing) tem de ser revertida em `REQUIRED_SIMPLE` antes de qualquer cliente real. Comentario `// MODO TESTE` deixado no proprio no `Prepara Payload Diretor` como lembrete.

**Buraco visual identificado e corrigido:** `corretor_nome` passar a opcional deixava `<p>{{corretor.nome}}<br>...` (editorial) e `{{corretor.nome}} · <a>...` (atlantico) com uma linha vazia/separador orfao quando o nome faltasse. Ambos os templates (`src/imovel_editorial.html`, `src/imovel_atlantico.html`) foram ajustados para envolver nome+separador num bloco `<!--IF:corretor_nome-->...<!--/IF:corretor_nome-->`, condicionado no Compilador por `renderIf(html, 'corretor_nome', !!(imovelRaw.corretor?.nome))`. Nota: `nif`/`ami`/`classe_energetica` ja nao apareciam em lado nenhum do HTML visivel antes desta sessao (so em `stateJson`) -- tornar estes 3 opcionais nao introduziu nenhum buraco visual novo, mas confirma que a exibicao legal do AMI/Classe Energetica no rodape (prevista no B0) continua por implementar -- **nao corrigido nesta sessao, fora do pedido explicito, registado aqui para nao se perder**.

**Testado (cadeia completa Prepara Payload -> Monta Prompt -> Parseia Diretor -> Compilador, com Gemini stubado, fotos reais descarregadas):**
- (a) payload sem Area/Quartos/WC/Ano/NIF/AMI/Classe Energetica/Nome do Corretor/Email do Corretor/Extras/Logo/Video: `campos_ausentes` = `["area","quartos","wc","ano","nif","ami","classe_energetica","corretor_nome","corretor_email","extras","logo","video_url"]`; ficha tecnica gerada so com `Tipologia` e `Localizacao` (sem linhas vazias); rodape de contacto sem nome do corretor e sem `<br>`/separador orfao.
- (b) payload sem Destaque 2: `throw` antes do Gemini com `VALIDACAO DE ENTRADA: ... -- Destaque 2`, exatamente como o G1 original.

**Deploy do M2:** mesma sequencia do M1 (`scp` -> `docker cp` -> `import:workflow` -> `restart` -> `update:workflow --active=true` -> `restart`), confirmado por reexportacao do servidor + `curl` (HTTP 500 em payload vazio, rota ativa).

**Achado nesta sessao (nao corrigido, so registado): o Tally exigiu HTTPS no webhook** e recusou `http://161.35.19.139/webhook/imovel-landing` com "Please enter a valid link" -- 5o bloqueio com a mesma raiz (Gmail, Brevo, OAuth Google, agora Tally). Ver R7 abaixo para a resolucao (dominio + HTTPS).

### Sessao 2026-07-31 -- R7: HTTPS (H1-H5) via prisma.binderstudios.com

**Contexto:** operador criou o registo DNS A `prisma.binderstudios.com -> 161.35.19.139`; confirmado propagado (resolvido tanto pelo DNS local como por `8.8.8.8`) antes de qualquer alteracao no servidor.

**H1 -- Certificado Let's Encrypt.** `certbot` (2.9.0) + `python3-certbot-nginx` instalados (nao existiam antes). `certbot --nginx -d prisma.binderstudios.com --redirect` emitiu o certificado (valido ate 2026-10-28) e editou o nginx automaticamente para servir 443 + redirecionar 80->443. Renovacao automatica confirmada: `certbot.timer` `enabled`, proximo disparo agendado, `certbot renew --dry-run` bem sucedido.

**H2 -- NGINX.** Config em `/etc/nginx/sites-available/default` (backup guardado no proprio servidor como `default.bak-pre-https-<timestamp>` antes de qualquer alteracao, e agora tambem versionado em `infra/nginx.conf`). `server_name` alterado de `_` para `prisma.binderstudios.com` (necessario para o certbot localizar o bloco certo). O bloco `location /webhook/ { proxy_pass http://127.0.0.1:5678; ... }` sobreviveu intacto a edicao automatica do certbot. Confirmado com `cat < /dev/tcp/161.35.19.139/5678` da maquina local: timeout (porta continua fechada ao exterior, so acessivel via nginx). Nota: pedidos HTTP diretos ao IP nu (`http://161.35.19.139/...`) agora recebem 404 em vez de servir ficheiros estaticos -- efeito colateral aceite da mudanca para roteamento por dominio (nenhum cliente real publicado ainda; landings de teste antigas ficam inacessiveis por HTTP puro, mas continuam acessiveis se recriadas apos este deploy).

**H3 -- URLs no pipeline.** Substituido `http://161.35.19.139` por `https://prisma.binderstudios.com` em todas as 3 ocorrencias em `n8n/imovel-landing-wf.json` (BASE_URL das fotos, `agendamentoEndpoint`, `canonical` no Compilador Editorial), 2 em `n8n/imovel-reativar-wf.json` (`agendamentoEndpoint`, `canonical`) e 1 em `n8n/imovel-libertar-slot-wf.json` (URL de leitura do `state.json` na despublicacao). Confirmado por `grep`: zero ocorrencias da IP antiga a sobrar nos 3 ficheiros. Documentacao tambem atualizada (`docs/B0_CAMPOS_TALLY.md`, `docs/B0_FORMULARIO_TALLY_IMOVEL.md`, `docs/SCHEMA_TALLY_IMOVEL.md`, `docs/SCHEMA_TALLY_LIBERTAR.md`) -- estes documentos sao o que se cola no campo de webhook do Tally, por isso tinham de refletir o dominio novo. `docs/SCHEMA_TALLY.md` (workflow `tally-onboarding-wf`, legado, fora do pedido) **nao foi tocado** -- continua a referenciar a porta 5678 diretamente, o que ja era stale antes desta sessao e nao foi criado por ela.

**H4 -- docker-compose.** `/root/prisma-n8n/docker-compose.yml` nao estava versionado no repo (nem nginx.conf) -- ambos copiados para `infra/` nesta sessao antes de qualquer alteracao. Alterados `WEBHOOK_URL`, `N8N_HOST` e `N8N_PROTOCOL` para o dominio/https; `N8N_PORT` e o bind `127.0.0.1:5678:5678` ficaram inalterados (o n8n continua a ouvir HTTP internamente, o nginx e que termina TLS). `docker-compose up -d` falhou com `KeyError: 'ContainerConfig'` (bug conhecido do docker-compose v1.29.2 com imagens mais recentes) -- resolvido com `docker-compose stop n8n && docker-compose rm -f n8n && docker-compose up -d` (recriacao limpa; dados intactos porque vivem no volume `n8n_data` e nos bind mounts, nao no container). Confirmado pos-recriacao: `docker exec ... printenv` mostra `WEBHOOK_URL=https://prisma.binderstudios.com/`, `N8N_HOST=prisma.binderstudios.com`, `N8N_PROTOCOL=https`; os 9 workflows sobreviveram (mesmo volume de dados).

**H5 -- Testado, nao so afirmado:**
- `curl -X POST https://prisma.binderstudios.com/webhook/imovel-landing -d '{}'` -> `HTTP 500` (fail-loud do G1, nao 404 -- rota ativa).
- `curl http://prisma.binderstudios.com/webhook/imovel-landing` -> `301` para `https://...` (redirect confirmado).
- `openssl s_client` confirma certificado real: `subject=CN=prisma.binderstudios.com`, `issuer=Let's Encrypt`, valido ate 2026-10-28.
- **Landing real gerada de ponta a ponta via HTTPS** (payload direto, incluindo `nif` valido de um cliente de teste pre-existente `123456789`/"Joao Teste" -- ver achado abaixo): `HTTP 200`, `moradia-teste-https-t3-ms866b0yonoqpyxltawn.html` publicado. Confirmado por `grep` de todos os URLs absolutos no HTML: canonical, OG image, 4 fotos, `agendamento_endpoint` -- todos em `https://prisma.binderstudios.com/...`, zero ocorrencias do IP antigo. `state.json` confirma `url` no dominio novo e `campos_ausentes` corretamente populado. Artefactos de teste apagados do servidor no final (html + state + 4 fotos).

**Achado nao relacionado com H1-H5, descoberto durante o teste E2E: o no `Porteiro` (mais a frente no pipeline de `imovel-landing-wf`, gestao de slots/clientes) exige um NIF valido e registado -- falha com `PORTEIRO: NIF ausente ou invalido apos normalizacao` mesmo que o G1 (M2) considere `nif` opcional.** Ou seja: `nif` deixou de ser bloqueante para a VALIDACAO DE ENTRADA (G1), mas continua a ser bloqueante mais tarde, com uma mensagem de erro diferente e menos obvia, se o NIF nao existir no registo de clientes (`clientes.json`). Isto nao foi corrigido nesta sessao (fora do pedido) -- registado para o operador decidir se o MODO TESTE de `nif` em G1 deve ser acompanhado de um ajuste equivalente no `Porteiro`, ou se o `Porteiro` e que reflete o requisito real (um imovel sem cliente/slot associado nao devia publicar-se de qualquer forma).

**Commitado e enviado** (aprovado pelo operador): commit `4012f91` "feat: HTTPS via prisma.binderstudios.com (certbot + nginx), migra URLs do pipeline para dominio; versiona infra/nginx.conf e infra/docker-compose.yml (nunca antes no repo)". `git status` limpo, `git push` confirmado (`b2545ab..4012f91 main -> main`).

### Sessao 2026-07-31 (cont.) -- correcao do Porteiro (S2) para o MODO TESTE de nif

Achado da sessao anterior confirmado e corrigido, com aprovacao do operador (desenho original S2: NIF novo -> cria cliente automaticamente; so bloqueia por conta suspensa ou slots esgotados).

**(a) Criacao automatica de cliente:** ja estava implementada no `Porteiro` (`code-porteiro-1`) -- confirmado por leitura direta do codigo (nao foi preciso implementar). Bloqueio real era so o `if (!nif) throw` a disparar ANTES de chegar a essa logica, sempre que `nif` vinha vazio (permitido desde o M2).

**(b) Normalizacao do NIF:** ja correta, sem bug -- `.replace(/\D/g, '')` reduz `"123456789"`, `"123 456 789"` e `"PT123456789"` todos a exatamente `"123456789"`. Confirmado com teste direto no codigo real extraido do workflow (nao simulado): as 3 variantes convergem para a mesma chave. A falha original nao era de normalizacao, era de `nif` genuinamente vazio (caso c).

**(c) NIF vazio -- implementado MODO TESTE:** em `Prepara Payload Diretor`, apos calcular `campos_ausentes` (que continua a listar `nif` como ausente, sem mentir sobre o que o cliente realmente enviou), gera-se `nifFinal = nif || ('TESTE-' + Date.now())` e escreve-se em `imovel.nif` apenas quando `nif` estava vazio (`nifPlaceholderUsado`). Este flag e propagado (mesmo padrao do `campos_ausentes`: `Monta Prompt Diretor` -> `Parseia Diretor e Monta Copywriter` -> `Compilador Editorial`) ate `stateJson.nif_placeholder`. No `Porteiro`, a normalizacao passou a preservar literalmente qualquer nif que comece por `TESTE-` (nao reduz a digitos), para a entrada no registo de clientes ficar obviamente distinta de um NIF real -- so nifs reais continuam a ser reduzidos a digitos. Comentario `// MODO TESTE` deixado em ambos os nos.

**(d) Testado em producao real via HTTPS (nao simulado):**
- POST com NIF em formato `"PT 111 222 333"` -> `HTTP 200`; `clientes.json` no servidor ganhou a chave normalizada `"111222333"` (cliente novo, `plano: beta`, `slots_total: 5`).
- POST sem `nif` -> `HTTP 200`; `state.json` da landing confirma `nif_placeholder: true`, `cliente.nif: "TESTE-1785456842336"`, e `campos_ausentes` continua a incluir `"nif"` (nao esconde que faltou); `clientes.json` ganhou essa chave `TESTE-...` literal, distinta de qualquer NIF real.
- Teste do limite de slots (5/5 -> bloqueia o 6o): confirmado diretamente no codigo do `Porteiro` com um cliente fixture de 5 paginas `publicado` -- bloqueia com a mensagem `PORTEIRO: limite atingido -- 5/5 ...`, como esperado.
- **Achado importante ao tentar reproduzir "o mesmo NIF 6x via imovel-landing-wf bloqueia na 6a":** nao bloqueia. Confirmado com 6 submissoes reais seguidas ao mesmo NIF novo -- `publicadas` fica em `0/5` nas 6, porque o `Porteiro`/`Escreve Clientes` do `imovel-landing-wf` **nunca** escreve em `cliente.paginas` (so cria/identifica o cliente). Quem ocupa efetivamente um slot (`paginas.push(..., estado:'publicado')`) e o no "Atualiza Slot Publicacao" do `imovel-reativar-wf`, na transicao para `estado: publicado` -- ou seja, gerar previews (mesmo repetidamente) nunca esgota slots; so a publicacao efetiva (fora do ambito de `imovel-landing-wf`) e que conta. Isto nao foi alterado nesta sessao -- o operador decide se quer limitar tambem a criacao de previews.

Artefactos de teste (2 landings, 8 fotos, 2 entradas em `clientes.json`) removidos do servidor no fim; o cliente fixture pre-existente `123456789` ("Joao Teste") ficou intacto.

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





