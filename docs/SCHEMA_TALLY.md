# SCHEMA_TALLY.md — Formulário de Onboarding Prisma Studio

> **Objetivo:** Recolher os dados mínimos de um novo cliente para gerar automaticamente a sua landing page via o motor Prisma.
> **Destino dos dados:** Webhook n8n em `http://161.35.19.139:5678/webhook/tally-onboarding`

---

## Configuração do Formulário no Tally.so

### Metadados do Formulário

| Campo | Valor |
|-------|-------|
| **Título** | Onboarding Prisma Studio |
| **Descrição** | Preencha este formulário em menos de 3 minutos e receberá a sua landing page profissional pronta a usar. |
| **Botão de submissão** | Criar a minha página → |
| **Mensagem de sucesso** | ✅ Dados recebidos! A sua landing page será gerada nas próximas 24 horas. Receberá o link no WhatsApp indicado. |

---

## Campos (na ordem exata de construção)

> [!IMPORTANT]
> A ordem e os nomes dos campos são críticos. O n8n mapeia os dados pelo nome do campo tal como aparece no JSON do Tally.

---

### 1. Nome da Empresa
| Propriedade | Valor |
|-------------|-------|
| **Tipo Tally** | Short Answer |
| **Label** | Nome da Empresa |
| **Placeholder** | Ex: Oficina do Manel, Clínica Bela Saúde |
| **Obrigatório** | ✅ Sim |
| **Validação** | Mínimo 2 caracteres |

---

### 2. Nicho de Atuação
| Propriedade | Valor |
|-------------|-------|
| **Tipo Tally** | Short Answer |
| **Label** | Nicho de Atuação |
| **Placeholder** | Ex: Cabeleireiro, Oficina Auto, Restaurante, Clínica Dentária |
| **Obrigatório** | ✅ Sim |
| **Descrição auxiliar** | Em poucas palavras, qual é o seu setor de atividade? |

---

### 3. Diferencial / Por que vos escolhem?
| Propriedade | Valor |
|-------------|-------|
| **Tipo Tally** | Long Answer |
| **Label** | Diferencial — Por que os clientes vos escolhem? |
| **Placeholder** | Ex: Somos os únicos na zona com serviço ao domicílio e garantia de 2 anos em todas as reparações. |
| **Obrigatório** | ✅ Sim |
| **Descrição auxiliar** | Esta resposta será usada para destacar o que vos torna únicos na página. Seja específico — quanto mais detalhe, melhor ficará o resultado. |
| **Validação** | Mínimo 20 caracteres |

---

### 4. WhatsApp de Conversão
| Propriedade | Valor |
|-------------|-------|
| **Tipo Tally** | Phone Number |
| **Label** | WhatsApp de Conversão |
| **Placeholder** | +351 912 345 678 |
| **Obrigatório** | ✅ Sim |
| **Descrição auxiliar** | O número para o qual os seus futuros clientes vão enviar mensagem. Inclua o código de país (ex: +351 para Portugal, +55 para Brasil). |

> [!TIP]
> No Tally, o campo **Phone Number** já inclui validação automática de formato e seletor de código de país. Ative a opção "International" se disponível.

---

### 5. Morada Física da Empresa
| Propriedade | Valor |
|-------------|-------|
| **Tipo Tally** | Long Answer |
| **Label** | Morada Física da Empresa |
| **Placeholder** | Ex: Rua do Comércio, 45 — 2700-123 Amadora |
| **Obrigatório** | ❌ Não (opcional) |
| **Descrição auxiliar** | Se o seu negócio é puramente digital ou ao domicílio, pode deixar em branco. A secção de morada será automaticamente omitida da sua página. |

> [!NOTE]
> Este campo mapeia para a secção colapsável `<!--IF:address-->` do template. Se vazio, a secção é removida automaticamente pelo motor.

---

### 6. Horário de Funcionamento
| Propriedade | Valor |
|-------------|-------|
| **Tipo Tally** | Short Answer |
| **Label** | Horário de Funcionamento |
| **Placeholder** | Ex: Seg-Sex 09h às 18h, Sáb 10h às 13h |
| **Obrigatório** | ✅ Sim |
| **Descrição auxiliar** | Indique os dias e horas em que está disponível. |

---

### 7. Logótipo
| Propriedade | Valor |
|-------------|-------|
| **Tipo Tally** | File Upload |
| **Label** | Logótipo da Empresa |
| **Obrigatório** | ❌ Não (opcional) |
| **Tamanho máximo** | 10 MB |
| **Tipos aceites** | PNG, JPG, SVG, WEBP |
| **Descrição auxiliar** | Se não tiver logótipo, não há problema — o nome da empresa será usado como texto estilizado (wordmark) no cabeçalho. |

> [!NOTE]
> Este campo mapeia para a condicional `<!--IF:logo-->`. Sem upload, o header mostra apenas o wordmark `{{brand.name}}`.

---

### 8. Fotografia Principal (Hero Section)
| Propriedade | Valor |
|-------------|-------|
| **Tipo Tally** | File Upload |
| **Label** | Fotografia Principal do Negócio |
| **Obrigatório** | ✅ Sim |
| **Tamanho máximo** | 10 MB |
| **Tipos aceites** | JPG, PNG, WEBP |
| **Descrição auxiliar** | Esta será a imagem de destaque no topo da sua página. Escolha uma foto que represente bem o seu negócio: a fachada, a equipa, o espaço de trabalho, ou o produto em ação. Fotos com boa iluminação e orientação horizontal (paisagem) funcionam melhor. |

---

## Ligação ao Webhook n8n

Após criar o formulário no Tally.so:

1. Abrir **Settings** → **Integrations** → **Webhooks**
2. Ativar **Webhook** e colar o URL:

```
http://161.35.19.139:5678/webhook/tally-onboarding
```

3. Método: **POST** (o Tally usa POST por defeito)
4. Guardar

---

## Estrutura JSON esperada (output do Tally)

Quando o formulário é submetido, o Tally envia um payload semelhante a este:

```json
{
  "eventId": "...",
  "eventType": "FORM_RESPONSE",
  "createdAt": "2026-07-13T15:00:00.000Z",
  "data": {
    "responseId": "...",
    "submissionId": "...",
    "formId": "...",
    "formName": "Onboarding Prisma Studio",
    "fields": [
      { "key": "question_nome_da_empresa", "label": "Nome da Empresa", "type": "INPUT_TEXT", "value": "Oficina do Manel" },
      { "key": "question_nicho_de_atuacao", "label": "Nicho de Atuação", "type": "INPUT_TEXT", "value": "Oficina Auto" },
      { "key": "question_diferencial", "label": "Diferencial — Por que os clientes vos escolhem?", "type": "TEXTAREA", "value": "..." },
      { "key": "question_whatsapp", "label": "WhatsApp de Conversão", "type": "INPUT_PHONE_NUMBER", "value": "+351912345678" },
      { "key": "question_morada", "label": "Morada Física da Empresa", "type": "TEXTAREA", "value": "Rua do Comércio, 45" },
      { "key": "question_horario", "label": "Horário de Funcionamento", "type": "INPUT_TEXT", "value": "Seg-Sex 09h-18h" },
      { "key": "question_logotipo", "label": "Logótipo da Empresa", "type": "FILE_UPLOAD", "value": [{"url": "https://..."}] },
      { "key": "question_foto_hero", "label": "Fotografia Principal do Negócio", "type": "FILE_UPLOAD", "value": [{"url": "https://..."}] }
    ]
  }
}
```

> [!IMPORTANT]
> As `key` exatas dependem do texto do label no Tally (são geradas automaticamente). No workflow n8n, usa a propriedade `label` para mapear os campos de forma fiável, já que o `label` é sempre o texto que definiste.

---

## Mapeamento Tally → Placeholders do Template

| Campo Tally | Placeholder no Template |
|-------------|------------------------|
| Nome da Empresa | `{{brand.name}}` |
| Nicho de Atuação | Usado pelo Architect para gerar conteúdo |
| Diferencial | Usado pelo Architect para `{{hero.subheadline}}`, trust signals, etc. |
| WhatsApp de Conversão | `{{brand.whatsapp}}` → `{{brand.wa_link}}` |
| Morada Física | `{{brand.address}}` + condicional `address` |
| Horário | `{{brand.hours}}` |
| Logótipo | `{{brand.logo}}` + condicional `logo` |
| Foto Hero | `{{hero.hero_image}}` |
