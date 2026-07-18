#Requires -Version 5.1
<#
.SYNOPSIS
  verify.ps1 — Verdade de terreno do Prisma Studio.

.DESCRIPTION
  Interroga o servidor REAL e reescreve o bloco [AUTO] do STATE.md.
  Não confia no que está escrito. Confia no que a máquina responde.

  O check mais importante é o TESTE END-TO-END: dispara um POST real no
  webhook com payload XSS e verifica o HTML gerado. Configuração correta
  na base de dados NÃO significa pipeline vivo — essa lição custou-nos
  um sprint.

.EXAMPLE
  .\verify.ps1
  .\verify.ps1 -SkipE2E          # salta o teste end-to-end (mais rápido)
  git diff STATE.md              # ver o que mudou na REALIDADE
#>

param(
    [string]$Server  = "root@161.35.19.139",
    [string]$KeyPath = "$env:USERPROFILE\.ssh\id_ed25519_prisma",
    [switch]$SkipE2E
)

$ErrorActionPreference = "Continue"
$RemoteHost = $Server.Split('@')[-1]
$Root       = Split-Path -Parent $MyInvocation.MyCommand.Path
$StateFile  = Join-Path $Root "STATE.md"
$StatusJson = Join-Path $Root "status.json"
$DB         = "/var/lib/docker/volumes/prisma-n8n_n8n_data/_data/database.sqlite"
$WF         = "tally-onboarding-wf"
$Container  = "prisma-n8n_n8n_1"

$rows    = New-Object System.Collections.Generic.List[string]
$results = [ordered]@{}
$fails   = 0
$warns   = 0

function Invoke-Remote([string]$Cmd) {
    $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Cmd))
    $out = & ssh -i $KeyPath -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new $Server "echo $b64 | base64 -d | bash" 2>&1
    return [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
}

function Add-Row([string]$Desc, [string]$Status, [string]$Key) {
    $script:rows.Add("| $Desc | $Status |")
    $script:results[$Key] = $Status
}

function Check([string]$Desc, [string]$Key, [string]$Cmd, [string]$Mode = "fail") {
    $r    = Invoke-Remote $Cmd
    $pass = ($r.Code -eq 0)
    if ($Mode -eq "invert") { $pass = -not $pass }

    if ($pass) {
        Add-Row $Desc "OK" $Key
    } elseif ($Mode -eq "warn") {
        Add-Row $Desc "PENDENTE" $Key
        $script:warns++
    } else {
        Add-Row $Desc "FALHA" $Key
        $script:fails++
    }
}

Write-Host "`n=== VERIFICACAO PRISMA STUDIO ===" -ForegroundColor Cyan
Write-Host "Servidor: $RemoteHost`n"

# ---------------------------------------------------------------- LIGACAO
if (-not (Test-Path $KeyPath)) {
    Write-Host "ERRO: chave SSH nao encontrada em $KeyPath" -ForegroundColor Red
    exit 2
}
if ((Invoke-Remote "true").Code -ne 0) {
    Write-Host "ERRO: sem acesso SSH por chave a $Server." -ForegroundColor Red
    Write-Host "      Servidor em baixo, ou chave mal configurada." -ForegroundColor Red
    exit 2
}

# --------------------------------------------------------------- SEGURANCA
Write-Host "[SEGURANCA]" -ForegroundColor Yellow
Check "Login SSH por password desativado" "ssh_no_password" `
      "grep -qE '^\s*PasswordAuthentication\s+no' /etc/ssh/sshd_config"

Check "Firewall UFW ativo" "ufw_active" `
      "ufw status | grep -q 'Status: active'"

$tcp = Test-NetConnection -ComputerName $RemoteHost -Port 5678 -WarningAction SilentlyContinue -InformationLevel Quiet
if ($tcp) {
    Add-Row "Porta 5678 fechada ao exterior" "ABERTA A INTERNET" "port_5678_closed"; $fails++
} else {
    Add-Row "Porta 5678 fechada ao exterior" "OK" "port_5678_closed"
}

Check "SSL/HTTPS (bloqueado: precisa de dominio)" "ssl" `
      "test -d /etc/letsencrypt/live" "warn"

# ----------------------------------------------------------------- BACKUP
Write-Host "[BACKUP]" -ForegroundColor Yellow
Check "Cron de backup configurado" "backup_cron" `
      "crontab -l 2>/dev/null | grep -q backup"

Check "Backup cifrado existe no servidor" "backup_local" `
      "ls /root/backups/archive/*.gpg >/dev/null 2>&1"

# CRITICO: um backup que nunca sai do servidor nao protege contra a perda do servidor
Check "Backup replicado FORA do servidor" "backup_offsite" `
      "cd /root/backups/archive 2>/dev/null && git log -1 --since='2 days ago' --oneline | grep -q ."

Check "Restauracao ja foi testada" "restore_tested" `
      "grep -q 'restauracao_testada' /var/log/n8n-backup.log 2>/dev/null" "warn"

$last = (Invoke-Remote "ls -t /root/backups/archive/*.gpg 2>/dev/null | head -1 | xargs -r stat -c %y | cut -d' ' -f1").Out
if ($last) { Add-Row "Data do ultimo backup" "``$last``" "backup_date" }
else        { Add-Row "Data do ultimo backup" "NUNCA" "backup_date" }

# --------------------------------------------------------------- PIPELINE
Write-Host "[PIPELINE]" -ForegroundColor Yellow

$model = (Invoke-Remote "echo `"SELECT nodes FROM workflow_entity WHERE id='$WF';`" | sqlite3 $DB | grep -oE 'gemini[-a-z0-9./]+' | head -1").Out.Trim()
if (-not $model)              { Add-Row "Modelo Gemini configurado" "NAO DETETADO" "model"; $fails++ }
elseif ($model -match '1\.5') { Add-Row "Modelo Gemini configurado" "``$model`` (geracao antiga)" "model"; $fails++ }
else                          { Add-Row "Modelo Gemini configurado" "OK ``$model``" "model" }

Check "escapeHtml presente no compilador" "escape_html" `
      "echo `"SELECT nodes FROM workflow_entity WHERE id='$WF';`" | sqlite3 $DB | grep -q escapeHtml"

# safeUrl chama escapeAttr. Se escapeAttr nao existir, qualquer site com
# logotipo ou fotografia rebenta o compilador com ReferenceError.
Check "escapeAttr presente (safeUrl depende dela)" "escape_attr" `
      "echo `"SELECT nodes FROM workflow_entity WHERE id='$WF';`" | sqlite3 $DB | grep -q 'function escapeAttr'"

Check "responseSchema (structured output) ativo" "response_schema" `
      "echo `"SELECT nodes FROM workflow_entity WHERE id='$WF';`" | sqlite3 $DB | grep -qi responseSchema" "warn"

Check "Typo BEM-VDO corrigido" "typo_fixed" `
      "echo `"SELECT nodes FROM workflow_entity WHERE id='$WF';`" | sqlite3 $DB | grep -q 'BEM-VDO'" "invert"

$wfCount = (Invoke-Remote "echo `"SELECT COUNT(*) FROM workflow_entity;`" | sqlite3 $DB").Out.Trim()
if ($wfCount -eq "1") { Add-Row "Workflows registados (sem duplicados)" "OK (1)" "wf_count" }
else                  { Add-Row "Workflows registados (sem duplicados)" "$wfCount workflows - DUPLICADO?" "wf_count"; $warns++ }

Check "Error Workflow configurado (Sprint 3)" "error_workflow" `
      "echo `"SELECT settings FROM workflow_entity WHERE id='$WF';`" | sqlite3 $DB | grep -q errorWorkflow" "warn"

# ===========================================================================
#  TESTE END-TO-END — O UNICO CRITERIO QUE CONTA
#
#  Configuracao correta na BD nao significa pipeline vivo. O n8n regista as
#  rotas Express na ATIVACAO; escritas diretas no SQLite nao sao vistas pelo
#  processo em execucao. Este teste dispara o webhook a serio.
# ===========================================================================
if (-not $SkipE2E) {
    Write-Host "[TESTE END-TO-END]" -ForegroundColor Magenta

    $payload = @{
        empresa     = "Prisma E2E Test"
        nicho       = "Padaria"
        diferencial = "Pao fresco todos os dias feito a mao com fermentacao natural lenta e ingredientes locais"
        whatsapp    = "+351912345678"
        horario     = "<script>alert(1)</script> 9h-19h"
        morada      = "Rua de Teste 1, Castelo Branco"
        heroImg     = "https://images.unsplash.com/photo-1509440159596-0249088772ff"
    } | ConvertTo-Json -Compress

    $webhookOk = $false
    try {
        $resp = Invoke-WebRequest -Uri "http://$RemoteHost/webhook/tally-onboarding" `
                    -Method POST -Body $payload -ContentType "application/json" `
                    -TimeoutSec 45 -UseBasicParsing
        $code = $resp.StatusCode
    } catch {
        $code = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
    }

    if ($code -eq 404) {
        Add-Row "Webhook responde (rota registada)" "404 - ROTA NAO REGISTADA. PIPELINE EM BAIXO" "webhook_alive"; $fails++
    } elseif ($code -ge 200 -and $code -lt 300) {
        Add-Row "Webhook responde (rota registada)" "OK ($code)" "webhook_alive"; $webhookOk = $true
    } else {
        Add-Row "Webhook responde (rota registada)" "HTTP $code" "webhook_alive"; $fails++
    }

    if ($webhookOk) {
        Start-Sleep -Seconds 6
        $html = (Invoke-Remote "cat /var/www/prisma-builds/prisma_e2e_test.html 2>/dev/null").Out

        if (-not $html) {
            Add-Row "HTML gerado pelo pipeline" "NENHUM FICHEIRO PRODUZIDO" "e2e_file"; $fails++
        } else {
            Add-Row "HTML gerado pelo pipeline" "OK" "e2e_file"

            # XSS neutralizado?
            if ($html -match '&lt;script&gt;' -and $html -notmatch '<script>alert\(1\)') {
                Add-Row "XSS neutralizado na saida REAL" "OK" "e2e_xss"
            } else {
                Add-Row "XSS neutralizado na saida REAL" "VULNERAVEL - SCRIPT NAO ESCAPADO" "e2e_xss"; $fails++
            }

            # safeUrl/escapeAttr nao rebentou?
            if ($html -match 'images\.unsplash\.com') {
                Add-Row "safeUrl processou a imagem (escapeAttr ok)" "OK" "e2e_image"
            } else {
                Add-Row "safeUrl processou a imagem (escapeAttr ok)" "IMAGEM PERDIDA - escapeAttr em falta?" "e2e_image"; $fails++
            }

            # Typo corrigido na saida real?
            if ($html -match 'BEM-VINDO')      { Add-Row "Typo corrigido na saida REAL" "OK" "e2e_typo" }
            elseif ($html -match 'BEM-VDO')    { Add-Row "Typo corrigido na saida REAL" "AINDA 'BEM-VDO'" "e2e_typo"; $fails++ }
            else                               { Add-Row "Typo corrigido na saida REAL" "eyebrow nao encontrado" "e2e_typo"; $warns++ }

            # Copy gerada pelo LLM (nao os fallbacks estaticos)?
            if ($html -match 'O Seu Sucesso Comeca Aqui') {
                Add-Row "Copy do Gemini (nao fallback estatico)" "FALLBACK - o LLM falhou" "e2e_llm"; $warns++
            } else {
                Add-Row "Copy do Gemini (nao fallback estatico)" "OK" "e2e_llm"
            }
        }

        # limpar o artefacto de teste
        Invoke-Remote "rm -f /var/www/prisma-builds/prisma_e2e_test.html" | Out-Null
    }
} else {
    Add-Row "Teste end-to-end" "SALTADO (-SkipE2E)" "e2e"
    $warns++
}

# ------------------------------------------------------------- REPOSITORIO
Write-Host "[REPOSITORIO]" -ForegroundColor Yellow
if (Test-Path (Join-Path $Root "n8n\tally-onboarding.json")) {
    Add-Row "Workflow n8n versionado no Git" "OK" "wf_in_git"
} else {
    Add-Row "Workflow n8n versionado no Git" "EM FALTA - o ultimo commit nao representa o projeto" "wf_in_git"
    $fails++
}

# ------------------------------------------------------- ESCREVER RESULTADO
$now    = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
$commit = (& git -C $Root rev-parse --short HEAD 2>$null); if (-not $commit) { $commit = "n/d" }

if ($fails -gt 0) {
    $verdict = "**$fails falha(s) critica(s)** e $warns pendencia(s). **NAO avancar** para sprints seguintes."
    $color   = "Red"
} elseif ($warns -gt 0) {
    $verdict = "Sem falhas criticas. $warns pendencia(s) conhecida(s)."
    $color   = "Yellow"
} else {
    $verdict = "Todos os controlos verificados. Pipeline vivo."
    $color   = "Green"
}

$block = @"
<!-- AUTO:START -->
## [AUTO] Verdade de terreno

> Gerado por ``verify.ps1`` — **nao editar a mao**.
> **Verificado em:** $now | **Servidor:** ``$RemoteHost`` | **Commit:** ``$commit``

$verdict

| Item | Estado |
|---|---|
$($rows -join "`n")

<!-- AUTO:END -->
"@

if (Test-Path $StateFile) {
    $content = Get-Content $StateFile -Raw -Encoding UTF8
    $new = [regex]::Replace($content, '(?s)<!-- AUTO:START -->.*?<!-- AUTO:END -->', { $block })
    Set-Content -Path $StateFile -Value $new -Encoding UTF8 -NoNewline
    Write-Host "`nSTATE.md atualizado." -ForegroundColor Green
} else {
    Write-Host "`nAVISO: STATE.md nao encontrado em $StateFile" -ForegroundColor Yellow
}

@{
    verified_at = $now
    server      = $RemoteHost
    commit      = $commit
    fails       = $fails
    warns       = $warns
    checks      = $results
} | ConvertTo-Json -Depth 4 | Set-Content -Path $StatusJson -Encoding UTF8

# ------------------------------------------------------------------ OUTPUT
Write-Host ""
$rows | ForEach-Object { Write-Host ("  " + ($_ -replace '\|', ' ')) }
Write-Host ""
Write-Host $verdict -ForegroundColor $color
Write-Host ""
Write-Host "Proximo: git diff STATE.md   (ver o que mudou na realidade)" -ForegroundColor Cyan

if ($fails -gt 0) { exit 1 } else { exit 0 }
