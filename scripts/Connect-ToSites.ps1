# Script: Connect-ToSites.ps1
# Descrição: Conecta aos sites de origem e destino no SharePoint Online usando PnP PowerShell.

Import-Module PnP.PowerShell

# Carregar configurações do App
. (Join-Path $PSScriptRoot '../config/AppConfig.ps1')

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          🔐 AUTENTICAÇÃO SHAREPOINT ONLINE                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 Site de Origem : $global:sourceSiteUrl" -ForegroundColor White
Write-Host "📍 Site de Destino: $global:targetSiteUrl" -ForegroundColor White
Write-Host "🔐 Client ID      : $global:AppClientId" -ForegroundColor Gray
Write-Host "🏢 Tenant ID      : $global:AppTenantId" -ForegroundColor Gray
Write-Host ""

# Determinar método de autenticação
$useCertificate = -not [string]::IsNullOrWhiteSpace($global:CertificatePath)

if ($useCertificate) {
    Write-Host "🔐 Método de Autenticação: Certificado" -ForegroundColor Yellow
    Write-Host "📜 Certificado: $global:CertificatePath" -ForegroundColor Gray
} else {
    Write-Host "🔐 Método de Autenticação: Interactive (Browser)" -ForegroundColor Yellow
    Write-Host "ℹ️  Uma janela do navegador será aberta para autenticação" -ForegroundColor Yellow
}
Write-Host ""

try {
    Write-Host "🔗 Conectando ao SharePoint Online..." -ForegroundColor Cyan
    
    if ($useCertificate) {
        # Autenticação com certificado
        $certPassword = ConvertTo-SecureString -String $global:CertificatePassword -Force -AsPlainText
        
        Connect-PnPOnline -Url $global:sourceSiteUrl `
            -ClientId $global:AppClientId `
            -Tenant "$global:AppTenantId" `
            -CertificatePath $global:CertificatePath `
            -CertificatePassword $certPassword
    } else {
        # Autenticação interativa (browser)
        Connect-PnPOnline -Url $global:sourceSiteUrl `
            -Interactive `
            -ClientId $global:AppClientId `
            -ForceAuthentication
    }
    
    Write-Host "✅ Autenticação realizada com sucesso!" -ForegroundColor Green
    Write-Host "✅ Conectado ao site: $global:sourceSiteUrl" -ForegroundColor Green
    Write-Host ""
    Write-Host "ℹ️  Nota: A mesma autenticação será usada para alternar entre sites" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "❌ ERRO NA AUTENTICAÇÃO" -ForegroundColor Red
    Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "Detalhes: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 SOLUÇÕES POSSÍVEIS:" -ForegroundColor Yellow
    Write-Host "   1. Verifique se você tem permissões no SharePoint" -ForegroundColor Yellow
    Write-Host "   2. Confirme que o App Registration está configurado:" -ForegroundColor Yellow
    Write-Host "      • Platform: Mobile and desktop applications" -ForegroundColor Yellow
    Write-Host "      • Redirect URI: http://localhost" -ForegroundColor Yellow
    Write-Host "   3. Verifique se as permissões foram concedidas no Azure AD" -ForegroundColor Yellow
    Write-Host "   4. Certifique-se de que as URLs dos sites estão corretas" -ForegroundColor Yellow
    Write-Host "   5. Revise as configurações em: config/AppConfig.ps1" -ForegroundColor Yellow
    Write-Host ""
    throw
}
