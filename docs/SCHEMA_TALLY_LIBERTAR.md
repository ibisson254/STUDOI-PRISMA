# SCHEMA_TALLY_LIBERTAR.md — Formulário "Libertar Slot" (Sistema de Clientes e Slots)

> **Objetivo:** Permitir que o corretor liberte um slot (imóvel vendido/arrendado) sem intervenção manual do operador — é o que torna a "rotação de inventário" real (ver S4 em STATE.md).
> **Destino dos dados:** Webhook n8n em `https://prisma.binderstudios.com/webhook/libertar-slot`
> **Workflow:** `n8n/imovel-libertar-slot-wf.json` ("Prisma - Libertar Slot")

---

> [!IMPORTANT]
> Tal como o formulário de imóvel, os **labels têm de bater** com os lidos pelo nó `Prepara Payload Libertar` (correspondência parcial, tolerante a acentos/maiúsculas). Este formulário ainda não existe no Tally.so — construir contra esta spec.

## Campos (3, um único ecrã)

### 1. NIF
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Short Answer |
| **Label** | NIF |
| **Obrigatório** | ✅ Sim |
| **Nota** | Tem de ser o mesmo NIF usado no formulário de lançamento do imóvel — é a chave do registo de clientes. |

### 2. Link da Página a Libertar
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Short Answer |
| **Label** | Link da Página a Libertar |
| **Placeholder** | Cole aqui o link da landing que quer retirar (ex: `https://prisma.binderstudios.com/moradia-t3-....html`) |
| **Obrigatório** | ✅ Sim |
| **Nota** | O corretor cola o link completo que recebeu quando o imóvel foi publicado. O código extrai o nome do ficheiro do fim do link — não precisa de saber o `landing_id` interno. |

### 3. Confirmação
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Dropdown ou Yes/No |
| **Label** | Confirmação |
| **Opções** | Sim / Não |
| **Obrigatório** | ✅ Sim |
| **Nota** | Só avança se a resposta normalizar para "sim" — protege contra libertações acidentais. |

---

## O que acontece ao submeter (S4)

1. Valida os 3 campos (fail-loud, sem inventar).
2. Lê `/var/www/prisma-data/clientes.json` (fora do document root do NGINX — nunca público).
3. Confirma que o NIF existe e que o ficheiro indicado está em `paginas[]` desse cliente; falha explicitamente se não encontrar (NIF errado, ou link de outro cliente).
4. Remove a página de `paginas[]` e grava `clientes.json` — **este é o passo que liberta o slot** (contado pelo Porteiro em `imovel-landing-wf.json`).
5. Best-effort: sobrescreve o `.html` publicado por um aviso "já não disponível" e marca o `.state.json` como `despublicado`. Se estes ficheiros já não existirem por algum motivo, o passo 4 já garantiu o resultado que importa (o slot ficou livre) — não bloqueia nem reverte a libertação.

## Nota de compatibilidade de teste

Tal como `imovel-landing-wf`, aceita formato direto para testes sem Tally: `{ "nif": "...", "link": "...", "confirmacao": "sim" }`.
