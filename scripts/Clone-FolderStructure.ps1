# Script: Clone-FolderStructure.ps1
# Descrição: Clona a estrutura de pastas de bibliotecas do site de origem para o site de destino.

Write-Host "`n📁 Iniciando clonagem de estrutura de pastas..." -ForegroundColor Cyan

function Clone-Folders {
    param(
        [string]$libraryName,
        [string]$relativePath = ""
    )
    
    try {
        # Conectar ao site de origem
        Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
        
        $folderUrl = if ($relativePath -eq "") { $libraryName } else { "$libraryName/$relativePath" }
        
        $folders = Get-PnPFolderItem -FolderSiteRelativeUrl $folderUrl -ItemType Folder -ErrorAction SilentlyContinue
        
        if ($null -eq $folders -or $folders.Count -eq 0) {
            return
        }

        foreach ($folder in $folders) {
            # Ignorar pastas do sistema
            if ($folder.Name -notin @("Forms", "_t", "_w", "_catalogs")) {
                try {
                    # Conectar ao site de destino
                    Connect-PnPOnline -Url $global:targetSiteUrl -Interactive -ClientId $global:AppClientId
                    
                    $newFolderPath = if ($relativePath -eq "") { $libraryName } else { "$libraryName/$relativePath" }
                    
                    # Criar pasta no destino
                    $newFolder = Add-PnPFolder -Name $folder.Name -Folder $newFolderPath -ErrorAction SilentlyContinue
                    
                    if ($null -ne $newFolder) {
                        Write-Host "    ✅ Pasta criada: $newFolderPath/$($folder.Name)" -ForegroundColor Green
                    }
                    
                    # Recursivamente clonar subpastas
                    $newRelativePath = if ($relativePath -eq "") { $folder.Name } else { "$relativePath/$($folder.Name)" }
                    Clone-Folders -libraryName $libraryName -relativePath $newRelativePath
                    
                } catch {
                    Write-Host "    ⚠️  Erro ao criar pasta $($folder.Name): $_" -ForegroundColor Yellow
                }
            }
        }
    } catch {
        Write-Host "    ❌ Erro ao processar pasta ${folderUrl}: $_" -ForegroundColor Red
    }
}

try {
    # Conectar ao site de origem
    Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
    
    # Obter bibliotecas
    $libraries = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 -and $_.Hidden -eq $false }
    
    Write-Host "✅ Encontradas $($libraries.Count) bibliotecas para clonar estrutura de pastas" -ForegroundColor Green
    
    foreach ($library in $libraries) {
        Write-Host "  🔄 Clonando estrutura de pastas da biblioteca: $($library.Title)" -ForegroundColor Yellow
        Clone-Folders -libraryName $library.Title
    }
    
    Write-Host "`n✅ Clonagem de estrutura de pastas concluída!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erro geral na clonagem de pastas: $_" -ForegroundColor Red
    throw
}
