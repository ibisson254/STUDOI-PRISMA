# B0 — Especificação Definitiva do Formulário Tally.so (Imóvel Luxo / Prisma Studio)

> **Documento Canónico de Construção (B0)**  
> **Destino do Webhook:** `https://prisma.binderstudios.com/webhook/imovel-landing` (POST JSON)  
> **Validação do Código (`Prepara Payload Diretor`):** Os labels listados abaixo são lidos por correspondência exata ou sinónimos case-insensitive. Os campos marcados com **✅ Sim** são validados com *fail-loud* (se algum faltar, o pipeline rejeita com HTTP 500 antes de chamar o Gemini).

---

## 📋 Resumo Estrutural por Ecrã (4 Ecrãs / Page Breaks)

Para otimizar a conversão (UX) no Tally.so, o formulário de 22 campos deve ser dividido em **4 ecrãs sequenciais**:

| Ecrã | Tema | N.º Campos | Foco |
|---|---|---|---|
| **Ecrã 1** | Identificação & Legal | 7 | Imobiliária, NIF, Licença AMI, Corretor e Contactos |
| **Ecrã 2** | Dados do Imóvel | 9 | Título, Preço, Tipologia, Áreas, WC, Localização, Energia |
| **Ecrã 3** | Diferenciação | 5 | Os 3 Destaques Únicos, Comodidades (Extras) e Vídeo |
| **Ecrã 4** | Multimédia | 1 | Upload Múltiplo de Fotos (mínimo 4) |

---

## 🖥️ Ecrã 1 — Identificação & Legal

### 1. Nome da Imobiliária
* **Label Exato (código):** `Nome da Imobiliária`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Nome comercial ou denominação oficial da agência imobiliária.
* **Placeholder:** Ex: Prisma Real Estate

### 2. Logótipo da Imobiliária
* **Label Exato (código):** `Logótipo da Imobiliária`
* **Tipo Tally:** File Upload (único)
* **Obrigatório:** ❌ Não
* **Texto de Ajuda:** Carregue o logótipo em alta resolução (PNG, SVG, JPG ou WEBP). Usado para derivar automaticamente a paleta de cores da landing page.

### 3. NIF
* **Label Exato (código):** `NIF`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** NIF da empresa/imobiliária (necessário para faturação, registo de domínio e controlo de licenças).
* **Placeholder:** Ex: 123456789

### 4. Número AMI
* **Label Exato (código):** `Número AMI`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Número da Licença de Mediação Imobiliária atribuída pelo IMPIC (obrigatório por lei no rodapé de publicidade imobiliária em Portugal).
* **Placeholder:** Ex: 12345

### 5. Nome do Corretor
* **Label Exato (código):** `Nome do Corretor`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Nome do consultor imobiliário responsável pela angariação/atendimento.
* **Placeholder:** Ex: João Mendes

### 6. WhatsApp do Corretor
* **Label Exato (código):** `WhatsApp do Corretor`
* **Tipo Tally:** Phone Number
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Número de telefone com indicativo (+351...). Será associado ao botão de contacto direto por WhatsApp na landing page.
* **Placeholder:** +351 912 345 678

### 7. Email do Corretor
* **Label Exato (código):** `Email do Corretor`
* **Tipo Tally:** Email
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Email onde o corretor receberá os alertas imediatos dos pedidos de agendamento de visita.
* **Placeholder:** joao.mendes@exemplo.pt

---

## 🖥️ Ecrã 2 — Dados do Imóvel

### 8. Título do Imóvel
* **Label Exato (código):** `Título do Imóvel`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Título conciso do imóvel para destaque e otimização SEO.
* **Placeholder:** Ex: Moradia T4 Contemporânea com Vista Mar

### 9. Preço
* **Label Exato (código):** `Preço`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Valor de comercialização do imóvel.
* **Placeholder:** Ex: 1.250.000 € (ou "Sob Consulta")

### 10. Tipologia
* **Label Exato (código):** `Tipologia`
* **Tipo Tally:** Dropdown
* **Obrigatório:** ✅ Sim
* **Opções Tally:** `T0`, `T1`, `T2`, `T3`, `T4`, `T5`, `T6+`, `Moradia`, `Penthouse`, `Quinta`, `Terreno`
* **Texto de Ajuda:** Selecione a tipologia principal do ativo.

### 11. Área
* **Label Exato (código):** `Área`
* **Tipo Tally:** Number
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Área útil ou área bruta de construção em metros quadrados (m²).
* **Placeholder:** Ex: 280

### 12. Quartos
* **Label Exato (código):** `Quartos`
* **Tipo Tally:** Number
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Número total de quartos/suítes.
* **Placeholder:** Ex: 4

### 13. WC
* **Label Exato (código):** `WC`
* **Tipo Tally:** Number
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Número total de casas de banho.
* **Placeholder:** Ex: 3

### 14. Localização
* **Label Exato (código):** `Localização`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Cidade, concelho ou zona de prestígio (usado para o mapa dinâmico e marcação estruturada JSON-LD).
* **Placeholder:** Ex: Cascais, Quinta da Marinha

### 15. Classe Energética
* **Label Exato (código):** `Classe Energética`
* **Tipo Tally:** Dropdown
* **Obrigatório:** ✅ Sim
* **Opções Tally:** `A+`, `A`, `B`, `B-`, `C`, `D`, `E`, `F`
* **Texto de Ajuda:** Classificação constante do Certificado Energético (obrigatório em anúncio público).

### 16. Ano de Construção
* **Label Exato (código):** `Ano de Construção`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ❌ Não
* **Texto de Ajuda:** Ano de construção ou da última grande intervenção/remodelação.
* **Placeholder:** Ex: 2023 ou 1890 (remodelada em 2022)

---

## 🖥️ Ecrã 3 — Diferenciação & Conteúdo

### 17. Destaque 1
* **Label Exato (código):** `Destaque 1`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** A característica mais marcante e exclusiva do imóvel (será trabalhada pelo Gemini no título de impacto).
* **Placeholder:** Ex: Piscina de água salgada aquecida com vista panorâmica para a serra

### 18. Destaque 2
* **Label Exato (código):** `Destaque 2`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Segundo elemento de elevado valor arquitetónico ou de estilo de vida.
* **Placeholder:** Ex: Suíte principal de 40 m² com closet italiano e varanda privativa

### 19. Destaque 3
* **Label Exato (código):** `Destaque 3`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ✅ Sim
* **Texto de Ajuda:** Terceiro detalhe distintivo.
* **Placeholder:** Ex: Garagem fechada para 4 viaturas e garrafeira climatizada em pedra

### 20. Extras
* **Label Exato (código):** `Extras`
* **Tipo Tally:** Multi-select (Checkboxes)
* **Obrigatório:** ❌ Não
* **Opções Tally:** `piscina`, `garagem`, `elevador`, `vista mar`, `jardim`, `domótica`, `painel solar`
* **Texto de Ajuda:** Selecione as comodidades adicionais presentes no imóvel.

### 21. Link do Vídeo
* **Label Exato (código):** `Link do Vídeo`
* **Tipo Tally:** Short Answer
* **Obrigatório:** ❌ Não
* **Texto de Ajuda:** URL de apresentação em vídeo (suportados apenas links do YouTube ou Vimeo).
* **Placeholder:** Ex: https://www.youtube.com/watch?v=...

---

## 🖥️ Ecrã 4 — Multimédia

### 22. Fotos do Imóvel
* **Label Exato (código):** `Fotos do Imóvel`
* **Tipo Tally:** File Upload (Modo **Múltiplo** ativado no Tally)
* **Obrigatório:** ✅ Sim (Mínimo de 4 fotos; máximo recomendado de 15)
* **Texto de Ajuda:** Selecione e carregue entre 4 a 15 fotografias. A primeira imagem enviada é automaticamente utilizada na secção principal (Hero) e nas redes sociais (OpenGraph).

---

## ⚙️ Configuração da Integração Webhook no Tally.so

1. No painel do Tally, aceda a **Settings** → **Integrations** → **Webhooks**.
2. **Endpoint URL:** `https://prisma.binderstudios.com/webhook/imovel-landing`
3. **HTTP Method:** `POST`
4. **Formato:** JSON (padrão Tally)

---

## 🔍 Tabela Resumo do Mapeamento Interno do Código

| Label no Tally | Chave no Código | Validação no Pipeline |
|---|---|---|
| `Nome da Imobiliária` | `imobiliaria` | Requerido |
| `Logótipo da Imobiliária` | `logo` | Opcional |
| `NIF` | `nif` | Requerido |
| `Número AMI` | `ami` | Requerido |
| `Nome do Corretor` | `corretor_nome` | Requerido |
| `WhatsApp do Corretor` | `corretor_whatsapp` | Requerido |
| `Email do Corretor` | `corretor_email` | Requerido |
| `Título do Imóvel` | `titulo` | Requerido |
| `Preço` | `preco` | Requerido |
| `Tipologia` | `tipologia` | Requerido |
| `Área` | `area` | Requerido |
| `Quartos` | `quartos` | Requerido |
| `WC` | `wc` | Requerido |
| `Localização` | `localizacao` | Requerido |
| `Classe Energética` | `classe_energetica` | Requerido |
| `Ano de Construção` | `ano` | Opcional |
| `Destaque 1` | `destaque1` | Requerido |
| `Destaque 2` | `destaque2` | Requerido |
| `Destaque 3` | `destaque3` | Requerido |
| `Extras` | `extras` | Opcional |
| `Link do Vídeo` | `video_url` | Opcional |
| `Fotos do Imóvel` | `fotos` | Requerido (min 4) |
