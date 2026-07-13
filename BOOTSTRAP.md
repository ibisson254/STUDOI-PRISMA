# BOOTSTRAP — Prompt de arranque de sessão
### Cola isto no início de **cada** sessão com o agente (Antigravity / Gemini / Claude Code)

---

```
Estás a retomar o trabalho no projeto Prisma Studio.

PROTOCOLO DE ARRANQUE — executa por esta ordem, sem saltar passos:

1. git pull

2. Lê AGENT.md na íntegra.
   É a constituição do projeto: missão, preço, arquitetura, e as regras
   que não podes violar. Não assumas nada que não esteja lá.

3. Lê STATE.md.
   ⚠️ ATENÇÃO: o bloco [MANUAL] é uma ALEGAÇÃO, não um facto.
   Um agente anterior pode ter escrito "feito" sobre algo que nunca foi feito.

4. Corre a verificação contra o servidor real:
   export PRISMA_SERVER=root@<HOST>
   ./verify.sh

   Isto reescreve o bloco [AUTO] do STATE.md com factos da máquina.

5. git diff STATE.md
   Isto mostra-te exatamente o que mudou na REALIDADE desde a última sessão.

6. Compara [AUTO] com [MANUAL].
   Se houver contradição — o checklist diz [x] mas o verify diz ❌ —
   PARA. Não avances. Reporta assim:

     ⚠️ DIVERGÊNCIA
     STATE.md [MANUAL] alega: "<o quê>"
     verify.sh diz:           "<o quê>"
     Aguardo instrução.

7. Só então: lê a secção "PRÓXIMO PASSO" do STATE.md e executa
   APENAS essa tarefa. Nada mais. Sem refatorações não pedidas.

REGRAS INVIOLÁVEIS (repetidas de AGENT.md, Parte V):
- Nunca escrevas passwords, tokens ou chaves em texto simples em scripts,
  logs ou respostas. Chaves SSH e variáveis de ambiente, sempre.
- Nunca commites database.sqlite, .n8n/config, .env ou qualquer credencial.
- Nunca inventes. Se não encontraste: "NÃO ENCONTRADO".
- Nunca uses gemini-1.5-*. Usa a Flash mais recente disponível na conta.
- Nunca mudes o contrato de output do LLM sem mudar o renderizador no
  mesmo passo. O compilador espera {headline, subheadline}.

PROTOCOLO DE FIM DE SESSÃO — obrigatório, sem exceção:
   a. ./verify.sh                      (reescreve o bloco [AUTO])
   b. Atualiza os blocos [MANUAL]:
      - marca [x] APENAS o que o verify.sh confirmou
      - escreve o que falhou e porquê
      - define UM único PRÓXIMO PASSO
   c. Se alteraste o workflow do n8n, exporta-o:
      docker exec prisma-n8n_n8n_1 n8n export:workflow --id=tally-onboarding-wf --output=/tmp/wf.json
      → copiar para n8n/tally-onboarding.json
   d. git add -A && git commit -m "state: <resumo factual>" && git push

Uma sessão que não corre o verify.sh e não atualiza o STATE.md
partiu a cadeia. Não faças isso.

Confirma que leste AGENT.md e STATE.md, mostra-me o output do verify.sh,
e diz-me qual é o próximo passo antes de tocar em qualquer coisa.
```

---

## Setup inicial (uma única vez)

Coloca os três ficheiros na raiz do repositório e commita:

```bash
cd "PROJETO PRISMA"

# 1. Os ficheiros
#    AGENT.md   → a constituição
#    STATE.md   → o estado vivo
#    verify.sh  → a verdade de terreno
chmod +x verify.sh

# 2. Estrutura de pastas (ver AGENT.md, Parte VI)
mkdir -p n8n src docs infra
git mv index_template.html src/ 2>/dev/null
git mv SCHEMA_TALLY.md PRISMA_BUILDER.md PRISMA_GIT_PROTOCOL.md docs/ 2>/dev/null

# 3. Exportar o workflow do n8n para o Git — CRÍTICO
#    Sem isto, o "último commit" é uma casca vazia.
ssh root@<HOST> "docker exec prisma-n8n_n8n_1 n8n export:workflow \
  --id=tally-onboarding-wf --output=/tmp/wf.json && cat /tmp/wf.json" \
  > n8n/tally-onboarding.json

# 4. Primeira verificação
export PRISMA_SERVER=root@<HOST>
./verify.sh          # vai falhar em quase tudo — é suposto. É o baseline.

# 5. Commit fundacional
git add -A
git commit -m "infra: motor de arranque de agente (AGENT.md + STATE.md + verify.sh)"
git push
```

> Guarda `PRISMA_SERVER` no teu `~/.bashrc` para não ter de o exportar sempre.

---

## Como o agente sabe onde parámos — o mecanismo

```
                    ┌─────────────────────────────────────┐
                    │  git pull                           │
                    └──────────────┬──────────────────────┘
                                   ▼
        ┌──────────────────────────────────────────────────┐
        │  AGENT.md      → o que o projeto É (constituição) │
        │  STATE.md      → o que ALEGAMOS ter feito         │
        └──────────────┬───────────────────────────────────┘
                       ▼
        ┌──────────────────────────────────────────────────┐
        │  ./verify.sh   → o que a MÁQUINA diz (factos)     │
        │                  reescreve o bloco [AUTO]         │
        └──────────────┬───────────────────────────────────┘
                       ▼
        ┌──────────────────────────────────────────────────┐
        │  git diff STATE.md                               │
        │  → o delta entre a última sessão e a realidade   │
        └──────────────┬───────────────────────────────────┘
                       ▼
              [AUTO] == [MANUAL]?
                  ╱          ╲
               sim            não
                ▼              ▼
         executa o        PARA e reporta
      PRÓXIMO PASSO       a divergência
```

**A propriedade que isto garante:** um agente **não consegue** mentir sobre o progresso, porque o bloco que conta o progresso não é escrito por ele — é escrito pelo script, contra o servidor. E o `git diff` deixa o rasto visível para sempre.
