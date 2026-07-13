#!/bin/bash
# verify.sh - Verifica o estado real do servidor e atualiza o STATE.md
# Execução local, liga-se ao servidor via SSH (PRISMA_SERVER)

if [ -z "$PRISMA_SERVER" ]; then
  echo "Erro: PRISMA_SERVER não está definido. Ex: export PRISMA_SERVER=root@161.35.19.139"
  exit 1
fi

echo "A ligar a $PRISMA_SERVER para verificação..."

# Checks
SSH_CMD="ssh -i ~/.ssh/id_ed25519_prisma -o BatchMode=yes $PRISMA_SERVER"

# 1. n8n running?
N8N_STATUS=$($SSH_CMD "docker ps -q -f name=prisma-n8n_n8n_1" 2>/dev/null)
if [ -n "$N8N_STATUS" ]; then N8N_CHECK="✅ n8n a correr"; else N8N_CHECK="❌ n8n não está a correr"; fi

# 2. Firewall 5678 localhost bind?
PORT_CHECK=$($SSH_CMD "ss -tlnp | grep 5678" 2>/dev/null)
if echo "$PORT_CHECK" | grep -q "127.0.0.1:5678"; then BIND_CHECK="✅ Porta 5678 protegida (localhost)"; else BIND_CHECK="❌ Porta 5678 EXPOSTA"; fi

# 3. NGINX Reverse Proxy?
NGINX_CHECK=$($SSH_CMD "grep 'proxy_pass http://127.0.0.1:5678' /etc/nginx/sites-available/default" 2>/dev/null)
if [ -n "$NGINX_CHECK" ]; then PROXY_CHECK="✅ NGINX Proxy configurado"; else PROXY_CHECK="❌ NGINX Proxy em falta"; fi

# 4. Gemini version and Schema?
GEMINI_CHECK=$($SSH_CMD "sqlite3 /var/lib/docker/volumes/prisma-n8n_n8n_data/_data/database.sqlite \"SELECT nodes FROM workflow_entity WHERE id='tally-onboarding-wf'\" | grep 'gemini-2.0-flash'" 2>/dev/null)
if [ -n "$GEMINI_CHECK" ]; then MODEL_CHECK="✅ Gemini 2.0 Flash ativo"; else MODEL_CHECK="❌ Modelo incorreto ou Workflow ausente"; fi

# 5. XSS Sanitization check?
XSS_CHECK=$($SSH_CMD "sqlite3 /var/lib/docker/volumes/prisma-n8n_n8n_data/_data/database.sqlite \"SELECT nodes FROM workflow_entity WHERE id='tally-onboarding-wf'\" | grep 'escapeHtml'" 2>/dev/null)
if [ -n "$XSS_CHECK" ]; then XSS_STATUS="✅ Compilador imune a XSS"; else XSS_STATUS="❌ Compilador vulnerável a XSS"; fi

# Build the AUTO block
AUTO_BLOCK="<!-- INÍCIO DO BLOCO [AUTO] -->
### [AUTO] - Estado da Máquina (Verificado a $(date))
- $N8N_CHECK
- $BIND_CHECK
- $PROXY_CHECK
- $MODEL_CHECK
- $XSS_STATUS
<!-- FIM DO BLOCO [AUTO] -->"

# Replace the block in STATE.md
awk -v auto="$AUTO_BLOCK" '
  /<!-- INÍCIO DO BLOCO \[AUTO\] -->/ { print auto; skip=1; next }
  /<!-- FIM DO BLOCO \[AUTO\] -->/ { skip=0; next }
  !skip { print }
' STATE.md > STATE.tmp && mv STATE.tmp STATE.md

echo "STATE.md atualizado com os resultados da verificação."
