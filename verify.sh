#!/usr/bin/env bash
#
# verify.sh — Verdade de terreno do Prisma Studio.
#
set -uo pipefail

SERVER="${PRISMA_SERVER:-root@161.35.19.139}"
HOST="${SERVER#*@}"
STATE_FILE="$(dirname "$0")/STATE.md"
DB="/var/lib/docker/volumes/prisma-n8n_n8n_data/_data/database.sqlite"
WF="tally-onboarding-wf"

# Usa array para evitar word splitting issues
SSH_CMD=(ssh -i "C:/Users/Ibisson/.ssh/id_ed25519_prisma" -o BatchMode=yes -o ConnectTimeout=10 "$SERVER")

rows=""
fails=0
warns=0

check() {
  local desc="$1" cmd="$2" mode="${3:-fail}"
  local pass=0
  "${SSH_CMD[@]}" "$cmd" >/dev/null 2>&1 && pass=1

  if [ "$mode" = "invert" ]; then
    pass=$((1 - pass))
  fi

  if [ "$pass" -eq 1 ]; then
    rows+="| $desc | ✅ OK |"$'\n'
  elif [ "$mode" = "warn" ]; then
    rows+="| $desc | ⚠️ PENDENTE |"$'\n'
    warns=$((warns + 1))
  else
    rows+="| $desc | ❌ FALHA |"$'\n'
    fails=$((fails + 1))
  fi
}

echo "🔍 A verificar $SERVER ..."

if ! "${SSH_CMD[@]}" "true" >/dev/null 2>&1; then
  echo "❌ Sem acesso SSH por chave a $SERVER."
  exit 1
fi

check "Login SSH por password desativado" "grep -qE '^\s*PasswordAuthentication\s+no' /etc/ssh/sshd_config"
check "Firewall UFW ativo" "ufw status | grep -q 'Status: active'"

if timeout 5 bash -c "cat < /dev/null > /dev/tcp/$HOST/5678" 2>/dev/null; then
  rows+="| Porta 5678 (painel n8n) fechada ao exterior | ❌ ABERTA À INTERNET |"$'\n'
  fails=$((fails + 1))
else
  rows+="| Porta 5678 (painel n8n) fechada ao exterior | ✅ OK |"$'\n'
fi

check "Webhook acessível via NGINX (porta 80)" "curl -s -o /dev/null -w '%{http_code}' -X POST http://localhost/webhook/$WF | grep -qE '^(200|404|405)'" warn
check "SSL / HTTPS configurado (aguarda domínio)" "test -d /etc/letsencrypt/live" warn
check "Cron de backup configurado" "crontab -l 2>/dev/null | grep -q backup"
check "Existe pelo menos um backup cifrado" "ls /root/backups/archive/*.gpg >/dev/null 2>&1"
check "Restauração já foi testada" "grep -q 'RESTAURACAO TESTADA COM SUCESSO' /var/log/n8n-backup.log 2>/dev/null" warn

LAST_BK=$("${SSH_CMD[@]}" "ls -t /root/backups/archive/*.gpg 2>/dev/null | head -1 | xargs -r stat -c %y 2>/dev/null | cut -d' ' -f1" || echo "")
[ -n "$LAST_BK" ] && rows+="| Data do último backup | \`$LAST_BK\` |"$'\n' || rows+="| Data do último backup | ❌ NUNCA |"$'\n'

MODEL=$("${SSH_CMD[@]}" "sqlite3 $DB \"SELECT nodes FROM workflow_entity WHERE id='$WF';\" 2>/dev/null | grep -oE 'gemini-[a-z0-9.-]+' | head -1" || echo "")
if [ -z "$MODEL" ]; then
  rows+="| Modelo Gemini em uso | ❌ NÃO DETETADO |"$'\n'
  fails=$((fails + 1))
elif [[ "$MODEL" == *"1.5"* ]]; then
  rows+="| Modelo Gemini em uso | ❌ \`$MODEL\` (geração antiga) |"$'\n'
  fails=$((fails + 1))
else
  rows+="| Modelo Gemini em uso | ✅ \`$MODEL\` |"$'\n'
fi

check "Escaping HTML presente no compilador (XSS)" "sqlite3 $DB \"SELECT nodes FROM workflow_entity WHERE id='$WF';\" | grep -q escapeHtml"
check "Structured output (responseSchema) ativo" "sqlite3 $DB \"SELECT nodes FROM workflow_entity WHERE id='$WF';\" | grep -qi responseSchema" warn
check "Typo 'BEM-VDO' corrigido" "sqlite3 $DB \"SELECT nodes FROM workflow_entity WHERE id='$WF';\" | grep -q 'BEM-VDO'" invert
check "Error Workflow configurado (Sprint 3)" "sqlite3 $DB \"SELECT settings FROM workflow_entity WHERE id='$WF';\" | grep -q errorWorkflow" warn
check "Validação HMAC no webhook (Sprint 3)" "sqlite3 $DB \"SELECT nodes FROM workflow_entity WHERE id='$WF';\" | grep -qi hmac" warn

if [ -f "$(dirname "$0")/n8n/tally-onboarding.json" ]; then
  rows+="| Workflow n8n versionado no Git | ✅ OK |"$'\n'
else
  rows+="| Workflow n8n versionado no Git | ❌ EM FALTA — o último commit não representa o projeto |"$'\n'
  fails=$((fails + 1))
fi

NOW=$(date -Iseconds)
COMMIT=$(git -C "$(dirname "$0")" rev-parse --short HEAD 2>/dev/null || echo "n/d")

if [ "$fails" -gt 0 ]; then
  VERDICT="🔴 **$fails falha(s) crítica(s)** e $warns pendência(s). **NÃO avançar** para sprints seguintes."
elif [ "$warns" -gt 0 ]; then
  VERDICT="🟡 Sem falhas críticas. $warns pendência(s) conhecida(s)."
else
  VERDICT="🟢 Todos os controlos verificados."
fi

BLOCK=$(cat <<EOF
<!-- AUTO:START -->
## [AUTO] Verdade de terreno

> Gerado por \`verify.sh\` — **não editar à mão**.
> **Verificado em:** $NOW · **Servidor:** \`$HOST\` · **Commit:** \`$COMMIT\`

$VERDICT

| Item | Estado |
|---|---|
$rows
<!-- AUTO:END -->
EOF
)

awk -v auto="$BLOCK" '
  /<!-- AUTO:START -->/ { print auto; skip=1; next }
  /<!-- AUTO:END -->/ { skip=0; next }
  !skip { print }
' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

echo ""
echo "$rows" | sed 's/|/ /g'
echo ""
echo "$VERDICT"
echo ""
echo "✏️  STATE.md atualizado."
echo "👉 Corre: git diff STATE.md   (para ver o que mudou na realidade)"

[ "$fails" -gt 0 ] && exit 1 || exit 0

