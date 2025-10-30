# Script: Main.ps1
# Descrição: Script principal para orquestrar a clonagem de sites SharePoint Online.

# Configurar tratamento de erros
$ErrorActionPreference = "Continue"

# Importar módulos
Import-Module PnP.PowerShell -ErrorAction Stop

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      SHAREPOINT CLONER - Clonagem de Sites SharePoint         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ══════════════════════════════════════════════════════════════════════
# SOLICITAR INFORMAÇÕES DOS SITES
# ══════════════════════════════════════════════════════════════════════

Write-Host "📋 CONFIGURAÇÃO DA CLONAGEM" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# Solicitar URL do site de origem
do {
    Write-Host "📍 Site de Origem:" -ForegroundColor Cyan -NoNewline
    Write-Host " (ex: https://tenant.sharepoint.com/sites/origem)" -ForegroundColor DarkGray
    $global:sourceSiteUrl = Read-Host "   "
    
    if ([string]::IsNullOrWhiteSpace($global:sourceSiteUrl)) {
        Write-Host "   ⚠️  A URL do site de origem não pode estar vazia!" -ForegroundColor Red
        Write-Host ""
    } elseif ($global:sourceSiteUrl -notmatch "^https://.*\.sharepoint\.com/") {
        Write-Host "   ⚠️  URL inválida! Deve começar com https:// e conter .sharepoint.com" -ForegroundColor Red
        Write-Host ""
        $global:sourceSiteUrl = ""
    }
} while ([string]::IsNullOrWhiteSpace($global:sourceSiteUrl))

Write-Host ""

# Solicitar URL do site de destino
do {
    Write-Host "📍 Site de Destino:" -ForegroundColor Cyan -NoNewline
    Write-Host " (ex: https://tenant.sharepoint.com/sites/destino)" -ForegroundColor DarkGray
    $global:targetSiteUrl = Read-Host "   "
    
    if ([string]::IsNullOrWhiteSpace($global:targetSiteUrl)) {
        Write-Host "   ⚠️  A URL do site de destino não pode estar vazia!" -ForegroundColor Red
        Write-Host ""
    } elseif ($global:targetSiteUrl -notmatch "^https://.*\.sharepoint\.com/") {
        Write-Host "   ⚠️  URL inválida! Deve começar com https:// e conter .sharepoint.com" -ForegroundColor Red
        Write-Host ""
        $global:targetSiteUrl = ""
    } elseif ($global:targetSiteUrl -eq $global:sourceSiteUrl) {
        Write-Host "   ⚠️  Os sites de origem e destino não podem ser iguais!" -ForegroundColor Red
        Write-Host ""
        $global:targetSiteUrl = ""
    }
} while ([string]::IsNullOrWhiteSpace($global:targetSiteUrl))

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# Criar diretório de logs (caminhos relativos ao repositório)
# Usa $PSScriptRoot para ser portátil entre unidades/locais
$scriptDir = $PSScriptRoot
$repoRoot = Split-Path -Parent $scriptDir
$logDir = Join-Path $repoRoot 'logs'
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Configurar arquivo de log
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logDir "execution-log-$timestamp.log"

# Função para log
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$Level] $Message"
    Add-Content -Path $logFile -Value $logMessage
    
    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        default { Write-Host $Message }
    }
}

try {
    Write-Log "Iniciando processo de clonagem SharePoint..." "INFO"
    
    # Importar e executar scripts auxiliares (caminhos relativos)
    Write-Log "Executando conexão aos sites..." "INFO"
    $connectScript = Join-Path $scriptDir 'Connect-ToSites.ps1'
    if (Test-Path $connectScript) { . $connectScript } else { Write-Log "Script não encontrado: $connectScript" "ERROR"; throw }

    # Executar clonagem de listas e bibliotecas
    Write-Log "Executando clonagem de listas e bibliotecas..." "INFO"
    $listsScript = Join-Path $scriptDir 'Clone-ListsAndLibraries.ps1'
    if (Test-Path $listsScript) { . $listsScript } else { Write-Log "Script não encontrado: $listsScript" "ERROR"; throw }

    # Executar clonagem de estrutura de pastas
    Write-Log "Executando clonagem de estrutura de pastas..." "INFO"
    $foldersScript = Join-Path $scriptDir 'Clone-FolderStructure.ps1'
    if (Test-Path $foldersScript) { . $foldersScript } else { Write-Log "Script não encontrado: $foldersScript" "ERROR"; throw }

    # Executar clonagem de itens de lista
    Write-Log "Executando clonagem de itens de listas..." "INFO"
    $itemsScript = Join-Path $scriptDir 'Clone-ListItems.ps1'
    if (Test-Path $itemsScript) { . $itemsScript } else { Write-Log "Script não encontrado: $itemsScript" "ERROR"; throw }

    # Executar clonagem de arquivos
    Write-Log "Executando clonagem de arquivos..." "INFO"
    $filesScript = Join-Path $scriptDir 'Clone-Files.ps1'
    if (Test-Path $filesScript) { . $filesScript } else { Write-Log "Script não encontrado: $filesScript" "ERROR"; throw }
    
    # Nota: Site Pages não é clonado devido a limitações de permissão do SharePoint
    # Páginas ASPX requerem permissões especiais e não podem ser copiadas diretamente
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║        ✅ PROCESSO DE CLONAGEM CONCLUÍDO COM SUCESSO!         ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Log "Processo de clonagem concluído com sucesso!" "SUCCESS"
    Write-Host ""
    Write-Host "📋 Log salvo em: $logFile" -ForegroundColor Cyan
    
} catch {
    Write-Log "Erro crítico durante o processo de clonagem: $_" "ERROR"
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║           ❌ PROCESSO INTERROMPIDO POR ERRO                   ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host "📋 Verifique o log em: $logFile" -ForegroundColor Yellow
    throw
} finally {
    # Desconectar de todos os sites
    try {
        Disconnect-PnPOnline -ErrorAction SilentlyContinue
        Write-Log "Desconectado de todos os sites SharePoint" "INFO"
    } catch {
        # Ignorar erros de desconexão
    }
}
