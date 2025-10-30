# Script: Clone-Files.ps1
# Descrição: Clona arquivos de bibliotecas do site de origem para o site de destino.

Write-Host "`n📄 Iniciando clonagem de arquivos..." -ForegroundColor Cyan

function Clone-FilesFromFolder {
    param(
        [string]$libraryName,
        [string]$relativePath = ""
    )
    
    try {
        # Conectar ao site de origem
        Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
        
        $folderUrl = if ($relativePath -eq "") { $libraryName } else { "$libraryName/$relativePath" }
        
        # Obter arquivos da pasta atual
        $files = Get-PnPFolderItem -FolderSiteRelativeUrl $folderUrl -ItemType File -ErrorAction SilentlyContinue
        
        foreach ($file in $files) {
            try {
                Write-Host "    📥 Baixando: $($file.Name)" -ForegroundColor Gray
                
                # Criar diretório temporário se não existir
                $tempDir = Join-Path $PSScriptRoot '../temp'
                if (-not (Test-Path $tempDir)) {
                    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
                }
                
                $tempFilePath = Join-Path $tempDir $file.Name
                
                # Baixar arquivo
                Get-PnPFile -Url $file.ServerRelativeUrl -Path $tempDir -FileName $file.Name -AsFile -Force -ErrorAction Stop
                
                # Conectar ao site de destino
                Connect-PnPOnline -Url $global:targetSiteUrl -Interactive -ClientId $global:AppClientId
                
                $targetFolder = if ($relativePath -eq "") { $libraryName } else { "$libraryName/$relativePath" }
                
                # Upload arquivo para o destino
                Add-PnPFile -Path $tempFilePath -Folder $targetFolder -ErrorAction Stop
                
                Write-Host "    ✅ Arquivo copiado: $($file.Name)" -ForegroundColor Green
                
                # Limpar arquivo temporário
                Remove-Item $tempFilePath -Force -ErrorAction SilentlyContinue
                
            } catch {
                Write-Host "    ⚠️  Erro ao copiar arquivo $($file.Name): $_" -ForegroundColor Yellow
            }
        }
        
        # Conectar ao site de origem novamente
        Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
        
        # Obter subpastas
        $folders = Get-PnPFolderItem -FolderSiteRelativeUrl $folderUrl -ItemType Folder -ErrorAction SilentlyContinue
        
        foreach ($folder in $folders) {
            # Ignorar pastas do sistema
            if ($folder.Name -notin @("Forms", "_t", "_w", "_catalogs")) {
                $newRelativePath = if ($relativePath -eq "") { $folder.Name } else { "$relativePath/$($folder.Name)" }
                Clone-FilesFromFolder -libraryName $libraryName -relativePath $newRelativePath
            }
        }
        
    } catch {
        Write-Host "    ❌ Erro ao processar pasta ${folderUrl}: $_" -ForegroundColor Red
    }
}

try {
    # Conectar ao site de origem
    Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
    
    # Obter bibliotecas no site de origem
    $libs = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 -and $_.Hidden -eq $false }
    
    Write-Host "✅ Encontradas $($libs.Count) bibliotecas para clonar arquivos" -ForegroundColor Green

    foreach ($lib in $libs) {
        Write-Host "  🔄 Clonando arquivos da biblioteca: $($lib.Title)" -ForegroundColor Yellow
        Clone-FilesFromFolder -libraryName $lib.Title
    }
    
    # Limpar diretório temporário
    $tempDir = Join-Path $PSScriptRoot '../temp'
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "`n✅ Clonagem de arquivos concluída!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erro geral na clonagem de arquivos: $_" -ForegroundColor Red
    throw
}
