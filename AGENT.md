# AGENT — Constituição do Prisma Studio

## I. MISSÃO
O Prisma Studio é um motor automatizado de geração de landing pages (HTML estático) para PMEs portuguesas, focado na conversão (WhatsApp). Zero interações manuais na interface do n8n (tudo configurado via código).

## II. ARQUITETURA DE INFRAESTRUTURA
- **Host:** Servidor DigitalOcean Ubuntu (1 vCPU, 1 GB RAM, 2 GB Swap). IP: `161.35.19.139`
- **Orquestração:** n8n em Docker (`docker.n8n.io/n8nio/n8n`), porto 5678 (escondido atrás do NGINX).
- **Entrada:** Webhook via Tally.so → NGINX (`/webhook/tally-onboarding`) → n8n.
- **IA:** Google Gemini API (modelo `models/gemini-2.0-flash`), estruturado em JSON. Prompt focado em Copywriting.
- **Compilador:** Nó de Node.js no n8n com regex para injetar valores no template HTML, mitigando XSS.
- **Entrega Web:** NGINX a servir estáticos na diretoria `/var/www/prisma-builds/`.

## III. ESTRUTURA DO REPOSITÓRIO
- `/n8n/`: Workflows exportados do n8n em JSON.
- `/src/`: Código fonte e templates (ex: `index_template.html`).
- `/docs/`: Documentação técnica, esquemas, builder e protocolos.
- `/infra/`: Scripts de deploy, bash, configurações Docker/NGINX.

## IV. WORKFLOW CORE
1. Recebe webhook Tally.
2. Extrai campos de texto e links.
3. Chama Gemini para gerar `headline` e `subheadline`.
4. Injeta os dados num template HTML através do "Compilador Prisma".
5. Guarda o HTML final localmente para ser servido pelo NGINX.

## V. REGRAS INVIOLÁVEIS (PROTOCOLO DE SEGURANÇA)
1. **Zero plaintext secrets:** Nunca escrevas passwords, tokens ou chaves em plain text em scripts, logs, ficheiros ou respostas. Usa variáveis de ambiente ou chaves SSH (ed25519).
2. **Não commites lixo sensível:** Nunca commites ficheiros SQLite (`database.sqlite`), chaves de encriptação (`.n8n/config`) ou `.env`.
3. **Não assumas factos não confirmados:** Nunca inventes o estado do sistema. Se não verificaste, a resposta é "NÃO ENCONTRADO".
4. **LLM Controlado:** O modelo a usar é obrigatoriamente a família `gemini-2.0-flash` (ou superior). Nunca uses `gemini-1.5-*`.
5. **Contrato de Output Rigoroso:** O renderizador/compilador espera estritamente `{ "headline": "...", "subheadline": "..." }`. Se mudares o formato no LLM, tens de mudar o JS do Compilador no mesmo passo.
