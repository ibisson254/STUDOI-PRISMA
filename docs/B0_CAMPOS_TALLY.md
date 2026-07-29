# B0 — Campos do Formulário Tally: Contrato Canónico

> **Versão:** 1.0 — 2026-07-29  
> **Fonte de verdade:** nó `Prepara Payload Diretor` do workflow `imovel-landing-wf` (commit `58d14ec`, exportado do servidor real).  
> Este documento é o contrato entre o formulário Tally (a construir) e o pipeline de geração de landings.  
> Um campo com label diferente do especificado aqui → pipeline ignora-o → validação fail-loud → **landing não publicada**.

---

## Como o pipeline lê os labels

O código normaliza os labels antes de os comparar: remove acentos (NFD), converte para minúsculas e colapsa espaços. Exemplo: `"Área"` = `"area"` = `"AREA"` — todos são aceites. A tabela abaixo usa o **label principal recomendado** (com acentos correctos), que é também a forma que o código tenta primeiro. As variantes alternativas aceites estão na coluna "Sinónimos aceites".

Campos não reconhecidos são silenciosamente ignorados — o pipeline não falha por campos extra.

---

## Ecrã 1 — Imobiliária

| # | Label exacto (recomendado) | Tipo Tally | Obrigatório | Sinónimos aceites | Texto de ajuda sugerido |
|---|---|---|---|---|---|
| 1 | **Nome da Imobiliária** | Short Text | ✅ Sim | `Nome da Agência`, `Agência ou Corretor`, `Nome da Empresa` | Ex: "Porta da Frente Christie's" — aparece no cabeçalho e rodapé da landing. |
| 2 | **Logótipo da Imobiliária** | File Upload | ❌ Opcional | `logo`, `logótipo` | PNG, SVG ou JPEG. Mínimo 200×200px. Se não tiver, será gerado um monograma com as iniciais. |
| 3 | **NIF** | Short Text | ✅ Sim | `nif` | NIF da imobiliária ou do corretor responsável pela venda. Ex: "123456789". |
| 4 | **Número AMI** | Short Text | ✅ Sim | `Licença AMI`, `AMI` | Número de licença AMI da imobiliária. Ex: "12345". Obrigatório por lei para publicidade imobiliária em Portugal. |

---

## Ecrã 2 — Corretor

| # | Label exacto (recomendado) | Tipo Tally | Obrigatório | Sinónimos aceites | Texto de ajuda sugerido |
|---|---|---|---|---|---|
| 5 | **Nome do Corretor** | Short Text | ✅ Sim | `Nome do Agente` | Nome completo do corretor responsável. Aparece na secção de contacto da landing. |
| 6 | **WhatsApp do Corretor** | Short Text | ✅ Sim | `Telefone do Corretor` | Número com indicativo. Ex: "+351912345678". Os leads de agendamento chegam a este número via link WhatsApp directo. |
| 7 | **Email do Corretor** | Email | ✅ Sim | `email do corretor` | Email para onde são enviadas as notificações de pedidos de visita. |

---

## Ecrã 3 — Imóvel: Identidade

| # | Label exacto (recomendado) | Tipo Tally | Obrigatório | Sinónimos aceites | Texto de ajuda sugerido |
|---|---|---|---|---|---|
| 8 | **Título do Imóvel** | Short Text | ✅ Sim | `Título do Anúncio` | Título descritivo e factual. Ex: "Moradia T5 com Piscina — Comporta". Não é o headline da landing (esse é gerado pelo Diretor de Arte + Copywriter a partir dos Destaques). |
| 9 | **Localização** | Short Text | ✅ Sim | `Morada` | Endereço ou zona. Ex: "Rua do Século, 12, Lisboa" ou "Quinta de Catralvos, Sesimbra". Usado no mapa e na ficha técnica. |
| 10 | **Preço** | Short Text | ✅ Sim | `preco` | Valor de venda. Ex: "1 250 000 €" ou "Sob consulta". Aparece em destaque na ficha técnica. |

---

## Ecrã 4 — Imóvel: Ficha Técnica

| # | Label exacto (recomendado) | Tipo Tally | Obrigatório | Sinónimos aceites | Texto de ajuda sugerido |
|---|---|---|---|---|---|
| 11 | **Tipologia** | Short Text | ✅ Sim | `tipologia` | Ex: "T4", "Moradia T5", "Apartamento T3+1". |
| 12 | **Área** | Short Text | ✅ Sim | `area` | Área útil total. Ex: "320 m²". |
| 13 | **Quartos** | Short Text | ✅ Sim | `Número de Quartos` | Ex: "4" ou "4 suites". |
| 14 | **WC** | Short Text | ✅ Sim | `Casas de Banho`, `Casa de Banho`, `Quartos de Banho` | Ex: "3". |
| 15 | **Ano de Construção** | Short Text | ❌ Opcional | `ano` | Ex: "1920 (reabilitado 2022)". Deixar em branco se desconhecido — não aparece na ficha. |
| 16 | **Classe Energética** | Short Text | ✅ Sim | `Certificado Energético` | Ex: "A+", "B", "C". Obrigatório por legislação portuguesa em qualquer publicidade de imóveis para venda. |
| 17 | **Extras** | Multiple Choice (multi-select) | ❌ Opcional | `extras` | Comodidades genéricas: piscina, garagem, jardim, painéis solares, etc. **Não confundir com os Destaques Únicos (Ecrã 6)** — extras são listados na ficha, destaques são o argumento criativo. |

---

## Ecrã 5 — Fotos e Vídeo

| # | Label exacto (recomendado) | Tipo Tally | Obrigatório | Notas técnicas | Texto de ajuda sugerido |
|---|---|---|---|---|---|
| 18 | **Fotos do Imóvel** | File Upload (multi-ficheiro) | ✅ Sim (mín. 4) | Aceita também campos separados `Foto 1`, `Foto 2`, … `Foto N` pela ordem numérica | JPEG ou WebP. Mínimo 4, ideal 8–12. **A primeira foto é o hero.** A ordem de upload define a ordem na galeria. As fotos são descarregadas e servidas pelo servidor Prisma — os URLs do Tally são temporários. |
| 19 | **Link do Vídeo** | Short Text | ❌ Opcional | Aceita URLs YouTube e Vimeo | Ex: "https://youtu.be/abc123". Se presente, é embutido na landing e influencia a decisão de arquétipo do Diretor de Arte (favorece `cinematic`/`atlantico`). |

---

## Ecrã 6 — Os 3 Destaques Únicos ⭐

> **Estes são os campos mais importantes do formulário.**  
> São o que diferencia este imóvel de todos os outros — o material criativo que o Diretor de Arte e o Copywriter usam.  
> **Não são comodidades genéricas** (piscina, garagem, jardim) — essas vão nos "Extras".  
> São os argumentos de venda únicos: o que este imóvel tem que nenhum outro tem.

| # | Label exacto (recomendado) | Tipo Tally | Obrigatório | Notas | Texto de ajuda sugerido |
|---|---|---|---|---|---|
| 20 | **Destaque 1** | Long Text | ✅ Sim | Primeiro card obrigatório na secção "A Casa". O Copywriter não pode substituir por comodidade genérica — o pipeline verifica isto (backstop F5). | O argumento de venda único mais forte. Ex: "Piscina de água salgada alinhada com o horizonte do mar — o pôr do sol entra pela água". |
| 21 | **Destaque 2** | Long Text | ✅ Sim | Segundo card obrigatório, pela ordem do formulário. | Segundo argumento único. Ex: "Lagar de azeite do século XIX restaurado e funcional, com 300 oliveiras centenárias em produção". |
| 22 | **Destaque 3** | Long Text | ✅ Sim | Terceiro card obrigatório, pela ordem do formulário. | Terceiro argumento único. Ex: "Arquitectura Siza Vieira — única moradia privada da Comporta projectada pelo arquitecto". |

> **Nota de implementação:** Os 3 destaques aparecem pela ordem enviada na secção "02 A Casa". Se o Copywriter os substituir por comodidades genéricas (detecção por sobreposição de keywords), o pipeline restitui o texto original do cliente sem embelezamento (backstop F5, activo desde 2026-07-24).

---

## Resumo executivo

| Categoria | Obrigatórios | Opcionais |
|---|---|---|
| Imobiliária | Nome da Imobiliária, NIF, Número AMI | Logótipo |
| Corretor | Nome, WhatsApp, Email | — |
| Imóvel — Identidade | Título, Localização, Preço | — |
| Imóvel — Ficha | Tipologia, Área, Quartos, WC, Classe Energética | Ano de Construção, Extras |
| Media | Fotos do Imóvel (mín. 4) | Link do Vídeo |
| Destaques | Destaque 1, Destaque 2, Destaque 3 | — |
| **Total** | **17 obrigatórios** | **5 opcionais** |

---

## O que acontece se um campo obrigatório faltar

O pipeline falha **antes de chamar o Gemini**, devolve HTTP 500 com a lista completa dos campos em falta, e nada é publicado. Mensagem exemplo:

```
VALIDACAO DE ENTRADA: campo(s) obrigatorio(s) vazio(s) ou ausente(s) --
NIF, Classe Energetica, Destaque 2. Execucao falhada antes de chamar o
Gemini, nada publicado.
```

Zero custos de API. Zero landings a meio. Zero dados em falta silenciosos.

---

## Estrutura recomendada do formulário Tally (copiar/colar)

```
[Ecrã 1] A Imobiliária
  ● Nome da Imobiliária   (Short Text — obrigatório)
  ● Logótipo da Imobiliária   (File Upload — opcional)
  ● NIF   (Short Text — obrigatório)
  ● Número AMI   (Short Text — obrigatório)

[Ecrã 2] O Corretor
  ● Nome do Corretor   (Short Text — obrigatório)
  ● WhatsApp do Corretor   (Short Text — obrigatório)
  ● Email do Corretor   (Email — obrigatório)

[Ecrã 3] O Imóvel — Identidade
  ● Título do Imóvel   (Short Text — obrigatório)
  ● Localização   (Short Text — obrigatório)
  ● Preço   (Short Text — obrigatório)

[Ecrã 4] Ficha Técnica
  ● Tipologia   (Short Text — obrigatório)
  ● Área   (Short Text — obrigatório)
  ● Quartos   (Short Text — obrigatório)
  ● WC   (Short Text — obrigatório)
  ● Classe Energética   (Short Text — obrigatório)
  ● Ano de Construção   (Short Text — opcional)
  ● Extras   (Multiple Choice multi-select — opcional)
      Opções sugeridas: Piscina · Garagem · Jardim · Terraço · Quintal
      Painéis Solares · Domótica · Elevador · Arrecadação · Barbecue
      Ginásio · Spa/Jacuzzi · Portaria 24h · Condomínio Fechado

[Ecrã 5] Fotos e Vídeo
  ● Fotos do Imóvel   (File Upload multi-ficheiro — obrigatório, mín. 4)
  ● Link do Vídeo   (Short Text — opcional)

[Ecrã 6] ⭐ Os Destaques Únicos (o que ESTE imóvel tem que nenhum outro tem)
  ● Destaque 1   (Long Text — obrigatório)
  ● Destaque 2   (Long Text — obrigatório)
  ● Destaque 3   (Long Text — obrigatório)
```

---

## Configuração do webhook Tally

Após construir o formulário, configurar o webhook em **Integrations → Webhooks**:

| Campo | Valor |
|---|---|
| URL | `http://161.35.19.139/webhook/imovel-landing` |
| Método | POST |
| Formato | JSON (padrão Tally) |

> [!WARNING]
> Substituir `http://161.35.19.139` pelo domínio HTTPS final antes de qualquer uso comercial — obrigatório antes de entregar qualquer link a um cliente real (bloqueante desde Sprint 0).

---

## Sinónimos aceites — referência técnica completa

Extraídos directamente do objecto `SYNONYMS` no código (`Prepara Payload Diretor`):

| Campo canónico (interno) | Label principal | Sinónimos aceites (case-insensitive, sem acentos) |
|---|---|---|
| `imobiliaria` | Nome da Imobiliária | nome da agencia, agencia ou corretor, nome da empresa |
| `titulo` | Título do Imóvel | titulo do anuncio |
| `preco` | Preço | preco |
| `tipologia` | Tipologia | tipologia |
| `area` | Área | area |
| `quartos` | Quartos | numero de quartos |
| `wc` | WC | casas de banho, casa de banho, quartos de banho |
| `localizacao` | Localização | morada |
| `video_url` | Link do Vídeo | video promocional |
| `destaque1` | Destaque 1 | destaque 1 |
| `destaque2` | Destaque 2 | destaque 2 |
| `destaque3` | Destaque 3 | destaque 3 |
| `extras` | Extras | extras |
| `ano` | Ano de Construção | ano de construcao |
| `corretor_nome` | Nome do Corretor | nome do agente |
| `corretor_whatsapp` | WhatsApp do Corretor | telefone do corretor |
| `corretor_email` | Email do Corretor | email do corretor |
| `nif` | NIF | nif |
| `ami` | Número AMI | licenca ami, ami |
| `classe_energetica` | Classe Energética | certificado energetico |
| `fotos` | Fotos do Imóvel | (+ campos `Foto 1`, `Foto 2`, …) |
| `logo` | Logótipo da Imobiliária | logo, logotipo |
