# SCHEMA_TALLY_IMOVEL.md — Formulário "Landing de Imóvel" (Motor v2)

> **Objetivo:** Recolher os dados de UM imóvel para gerar a sua landing page individual via o motor Prisma v2 (imobiliário de luxo).
> **Destino dos dados:** Webhook n8n em `http://161.35.19.139:5678/webhook/imovel-landing`
> **Modelo de negócio:** uma landing por imóvel. Este formulário reabre-se (com token) durante a janela de 7 dias de alterações — ver §7 da SPEC-MOTOR-V2-IMOBILIARIO.md.

---

> [!IMPORTANT]
> Os **labels têm de bater exatamente** com os usados abaixo — o nó `Prepara Payload Diretor` (`n8n/imovel-landing-wf.json`) procura os campos por correspondência parcial do label (case-insensitive), não pela ordem. Um label diferente = um campo vazio em produção.
>
> **Este formulário ainda não existe como formulário real no Tally.so** (só existe como esta spec) — este documento é o contrato canónico contra o qual o Tally tem de ser construído. Ver auditoria G1 em `STATE.md` (2026-07-24).
>
> Desde 2026-07-24, todos os campos marcados **Obrigatório: ✅ Sim** abaixo são validados no início do pipeline (`Prepara Payload Diretor`, antes de qualquer chamada ao Gemini) — se algum chegar vazio ou ausente, a execução falha explicitamente e nada é publicado. Campos **❌ Não** (Logótipo, Link do Vídeo, Extras, Ano de Construção) continuam a poder faltar em silêncio.

---

## Campos (na ordem exata de construção)

### 1. Nome da Imobiliária
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Short Answer |
| **Label** | Nome da Imobiliária |
| **Obrigatório** | ✅ Sim |

### 2. Logótipo da Imobiliária
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | File Upload |
| **Label** | Logótipo da Imobiliária |
| **Obrigatório** | ❌ Não |
| **Tipos aceites** | PNG, JPG, SVG, WEBP |
| **Nota** | Usado pelo Gemini para derivar a paleta de cores da landing (Camada A do sistema anti-genérico). Sem logo, a paleta deriva do carácter do imóvel. |

### 3. Título do Imóvel
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Short Answer |
| **Label** | Título do Imóvel |
| **Placeholder** | Ex: Moradia T4 com vista mar — Cascais |
| **Obrigatório** | ✅ Sim |

### 4. Preço
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Short Answer |
| **Label** | Preço |
| **Placeholder** | Ex: 1.250.000 € ou "Sob consulta" |
| **Obrigatório** | ✅ Sim |

### 5. Tipologia
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Dropdown |
| **Label** | Tipologia |
| **Opções** | T0, T1, T2, T3, T4, T5, T6+, Moradia, Penthouse, Quinta, Terreno |
| **Obrigatório** | ✅ Sim |

### 6. Área
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Number |
| **Label** | Área |
| **Descrição auxiliar** | Em metros quadrados (m²) |
| **Obrigatório** | ✅ Sim |

### 7. Quartos
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Number |
| **Label** | Quartos |
| **Obrigatório** | ✅ Sim |

### 8. WC
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Number |
| **Label** | WC |
| **Obrigatório** | ✅ Sim |

### 9. Localização
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Short Answer |
| **Label** | Localização |
| **Placeholder** | Ex: Cascais, junto à Praia da Rainha |
| **Obrigatório** | ✅ Sim |
| **Nota** | Usado para gerar o embed do Google Maps (sem API key) e o `RealEstateListing` JSON-LD. |

### 10. Fotos do Imóvel
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | File Upload (múltiplo) |
| **Label** | Fotos do Imóvel |
| **Mínimo** | 4 fotos |
| **Máximo** | 15 fotos |
| **Obrigatório** | ✅ Sim |
| **Nota** | A 1ª foto é usada como hero/OG image. As 4 primeiras alimentam o arquétipo `gallery_first`. |

### 11. Link do Vídeo
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Short Answer |
| **Label** | Link do Vídeo |
| **Placeholder** | Link do YouTube ou Vimeo (opcional) |
| **Obrigatório** | ❌ Não |
| **Nota** | Só são aceites links YouTube/Vimeo reconhecíveis — outros formatos são ignorados (secção de vídeo colapsa). |

### 12, 13, 14. Destaques Únicos (3 campos)
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Short Answer × 3 |
| **Labels** | Destaque 1 / Destaque 2 / Destaque 3 |
| **Descrição auxiliar** | O que este imóvel tem que nenhum outro tem. Seja específico — um destes é usado literalmente no headline da landing. |
| **Obrigatório** | ✅ Sim (os 3) |

### 15. Extras
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Multi-select (checkboxes) |
| **Label** | Extras |
| **Opções** | piscina, garagem, elevador, vista mar, jardim, domótica, painel solar |
| **Obrigatório** | ❌ Não |

### 16. Ano de Construção
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Short Answer |
| **Label** | Ano de Construção |
| **Placeholder** | Ex: 2019 ou "1890 (renovada em 2020)" |
| **Obrigatório** | ❌ Não |

### 17, 18, 19. Corretor (3 campos)
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Short Answer / Phone Number / Email |
| **Labels** | Nome do Corretor / WhatsApp do Corretor / Email do Corretor |
| **Descrição auxiliar** | Destino dos agendamentos de visita gerados pela landing. |
| **Obrigatório** | ✅ Sim (os 3) |

### 20. NIF
| Propriedade | Valor |
|---|---|
| **Tipo Tally** | Short Answer |
| **Label** | NIF |
| **Descrição auxiliar** | Necessário para faturação e, mais tarde, para o registo de domínio. |
| **Obrigatório** | ✅ Sim |

---

## Ligação ao Webhook n8n

1. Tally.so → **Settings** → **Integrations** → **Webhooks**
2. URL: `http://161.35.19.139:5678/webhook/imovel-landing`
3. Método: **POST**

---

## Mapeamento Tally → Payload interno (nó "Prepara Payload Diretor")

| Campo Tally | Chave interna | Usado por |
|---|---|---|
| Nome da Imobiliária | `imobiliaria` | header, footer, SEO |
| Logótipo da Imobiliária | `logo` | Gemini (paleta), header/footer |
| Título do Imóvel | `titulo` | hero, SEO, JSON-LD |
| Preço | `preco` | ficha técnica, JSON-LD |
| Tipologia | `tipologia` | ficha técnica |
| Área | `area` | ficha técnica, JSON-LD |
| Quartos | `quartos` | ficha técnica, JSON-LD |
| WC | `wc` | ficha técnica |
| Localização | `localizacao` | rodapé, mapa, JSON-LD |
| Fotos do Imóvel | `fotos[]` | hero, galeria, OG image |
| Link do Vídeo | `video_url` | secção galeria (embed) |
| Destaque 1/2/3 | `destaques_unicos[]` | prompt Gemini (headline obrigatório) |
| Extras | `extras[]` | ficha técnica (via Gemini) |
| Ano de Construção | `ano` | ficha técnica (via Gemini) |
| Nome/WhatsApp/Email do Corretor | `corretor.{nome,whatsapp,email}` | rodapé, FAB WhatsApp, agendamento |
| NIF | `nif` | state.json (faturação/domínio, não aparece na landing) |

---

## Nota de compatibilidade de teste

O nó `Prepara Payload Diretor` aceita dois formatos de entrada, para permitir testes sem o Tally:
- **Formato Tally real:** `{ data: { fields: [{ label, type, value }, ...] } }`
- **Formato direto (teste):** chaves diretas como `{ imobiliaria, titulo, preco, ... }`

Isto está documentado aqui para que quem testar o webhook manualmente (`curl`/Postman) saiba que pode usar o formato direto sem montar o envelope completo do Tally.
