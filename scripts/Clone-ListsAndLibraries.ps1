# Script: Clone-ListsAndLibraries.ps1
# Descrição: Clona listas e bibliotecas do site de origem para o site de destino.

Write-Host "`n📋 Iniciando clonagem de listas e bibliotecas..." -ForegroundColor Cyan

try {
    # Conectar ao site de origem
    Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
    
    # Obter listas e bibliotecas visíveis no site de origem
    $lists = Get-PnPList | Where-Object { $_.Hidden -eq $false }
    
    Write-Host "✅ Encontradas $($lists.Count) listas/bibliotecas no site de origem" -ForegroundColor Green

    foreach ($list in $lists) {
        Write-Host "  🔄 Clonando: $($list.Title)" -ForegroundColor Yellow

        try {
            # Conectar ao site de destino
            Connect-PnPOnline -Url $global:targetSiteUrl -Interactive -ClientId $global:AppClientId
            
            # Verificar se a lista já existe no destino
            $existingList = Get-PnPList -Identity $list.Title -ErrorAction SilentlyContinue
            
            if ($null -eq $existingList) {
                # Criar lista no destino
                New-PnPList -Title $list.Title -Template $list.BaseTemplate
                Write-Host "    ✅ Lista criada: $($list.Title)" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️  Lista já existe: $($list.Title)" -ForegroundColor Yellow
            }

            # Conectar novamente ao site de origem para obter campos
            Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
            
            # Clonar colunas personalizadas
            $fields = Get-PnPField -List $list.Title
            $customFieldsCount = 0
            $customFieldsAdded = @()
            
            foreach ($field in $fields) {
                if ($field.ReadOnlyField -eq $false -and $field.Sealed -eq $false -and $field.FromBaseType -eq $false) {
                    try {
                        # Conectar ao destino para adicionar campo
                        Connect-PnPOnline -Url $global:targetSiteUrl -Interactive -ClientId $global:AppClientId
                        
                        # Verificar se o campo já existe no destino
                        $existingField = Get-PnPField -List $list.Title -Identity $field.InternalName -ErrorAction SilentlyContinue
                        
                        if ($null -eq $existingField) {
                            # Adicionar campo usando XML Schema
                            Add-PnPFieldFromXml -List $list.Title -FieldXml $field.SchemaXml -ErrorAction Stop
                            $customFieldsCount++
                            $customFieldsAdded += $field.Title
                            Write-Host "      ✅ Campo adicionado: $($field.Title) (Tipo: $($field.TypeAsString))" -ForegroundColor Green
                        }
                        
                        # Reconectar ao site de origem
                        Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
                        
                    } catch {
                        Write-Host "      ⚠️  Erro ao adicionar campo $($field.Title): $_" -ForegroundColor Yellow
                        # Reconectar ao site de origem em caso de erro
                        Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
                    }
                }
            }
            
            if ($customFieldsCount -gt 0) {
                Write-Host "    ✅ Total: $customFieldsCount campos personalizados adicionados" -ForegroundColor Green
            } else {
                Write-Host "    ℹ️  Nenhum campo personalizado novo para adicionar" -ForegroundColor Gray
            }
            
        } catch {
            Write-Host "    ❌ Erro ao clonar lista $($list.Title): $_" -ForegroundColor Red
            # Garantir reconexão ao site de origem após erro
            try {
                Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
            } catch {
                Write-Host "    ⚠️  Erro ao reconectar ao site de origem" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host "`n✅ Clonagem de listas e bibliotecas concluída!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erro geral na clonagem de listas: $_" -ForegroundColor Red
    throw
}
