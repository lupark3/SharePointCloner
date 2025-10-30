# Script: Clone-ListItems.ps1
# Descrição: Clona itens de listas do site de origem para o site de destino.

Write-Host "`n📝 Iniciando clonagem de itens de listas..." -ForegroundColor Cyan

try {
    # Conectar ao site de origem
    Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
    
    # Obter listas no site de origem (ignora bibliotecas)
    $lists = Get-PnPList | Where-Object { $_.BaseTemplate -ne 101 -and $_.Hidden -eq $false }
    
    Write-Host "✅ Encontradas $($lists.Count) listas para clonar itens" -ForegroundColor Green

    foreach ($list in $lists) {
        # Ignorar Site Pages - não pode ser processada como lista normal
        if ($list.Title -eq "Site Pages") {
            continue
        }
        
        Write-Host "  🔄 Clonando itens da lista: $($list.Title)" -ForegroundColor Yellow
        
        try {
            # Conectar ao site de origem
            Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
            
            $items = Get-PnPListItem -List $list.Title -PageSize 500
            
            if ($items.Count -eq 0) {
                Write-Host "    ℹ️  Nenhum item encontrado na lista" -ForegroundColor Gray
                continue
            }

            # Obter informações dos campos da lista para tratamento adequado
            $listFields = Get-PnPField -List $list.Title
            $fieldTypes = @{}
            foreach ($f in $listFields) {
                $fieldTypes[$f.InternalName] = $f.TypeAsString
            }

            $itemCount = 0
            foreach ($item in $items) {
                try {
                    $fieldValues = @{}
                    
                    foreach ($field in $item.FieldValues.Keys) {
                        # Ignorar campos do sistema que não podem ser definidos
                        if ($field -notin @("ID", "Attachments", "ContentType", "Modified", "Editor", "Created", "Author", "GUID", "owshiddenversion", "WorkflowVersion", "UIVersion", "ParentVersionString", "ParentLeafName", "_ModerationStatus", "InstanceID", "Order", "WorkflowInstanceID", "_Level", "_IsCurrentVersion", "ItemChildCount", "FolderChildCount", "SMTotalSize", "SMLastModifiedDate", "SMTotalFileStreamSize", "SMTotalFileCount", "Restricted", "OriginatorId", "NoExecute", "ContentVersion", "ComplianceAssetId", "_ComplianceFlags", "_ComplianceTag", "_ComplianceTagWrittenTime", "_ComplianceTagUserId", "AccessPolicy", "_VirusStatus", "_VirusVendorID", "_VirusInfo", "AppAuthor", "AppEditor", "FileRef", "FileDirRef", "Last_x0020_Modified", "Created_x0020_Date", "File_x0020_Size", "FSObjType", "SortBehavior", "PermMask", "PrincipalCount", "CheckedOutUserId", "UniqueId", "SyncClientId", "ProgId", "ScopeId", "HTML_x0020_File_x0020_Type", "_EditMenuTableStart", "_EditMenuTableStart2", "_EditMenuTableEnd", "LinkFilenameNoMenu", "LinkFilename", "LinkFilename2", "DocIcon", "ServerUrl", "EncodedAbsUrl", "BaseName", "MetaInfo", "_Level", "_IsCurrentVersion", "ItemChildCount", "FolderChildCount", "Restricted", "OriginatorId", "NoExecute", "ContentVersion")) {
                            
                            $fieldValue = $item[$field]
                            
                            # Pular campos vazios ou nulos
                            if ($null -eq $fieldValue -or ($fieldValue -is [string] -and [string]::IsNullOrWhiteSpace($fieldValue))) {
                                continue
                            }
                            
                            # Tratar campos de tipo User/Person
                            if ($fieldTypes.ContainsKey($field)) {
                                $fieldType = $fieldTypes[$field]
                                
                                if ($fieldType -eq "User" -or $fieldType -eq "UserMulti") {
                                    # Conectar ao destino para resolver usuários
                                    Connect-PnPOnline -Url $global:targetSiteUrl -Interactive -ClientId $global:AppClientId
                                    
                                    if ($fieldValue -is [Microsoft.SharePoint.Client.FieldUserValue]) {
                                        # Campo de usuário único
                                        try {
                                            if ($fieldValue.Email) {
                                                $user = Get-PnPUser -Identity $fieldValue.Email -ErrorAction SilentlyContinue
                                                if ($null -ne $user) {
                                                    $fieldValues[$field] = $user.Id
                                                    Write-Host "      ✅ Campo de usuário '$field' mapeado: $($fieldValue.Email)" -ForegroundColor Green
                                                }
                                            } elseif ($fieldValue.LookupValue) {
                                                # Tentar buscar por nome se não tiver email
                                                $user = Get-PnPUser | Where-Object { $_.Title -eq $fieldValue.LookupValue } | Select-Object -First 1
                                                if ($null -ne $user) {
                                                    $fieldValues[$field] = $user.Id
                                                    Write-Host "      ✅ Campo de usuário '$field' mapeado: $($fieldValue.LookupValue)" -ForegroundColor Green
                                                }
                                            }
                                        } catch {
                                            Write-Host "      ⚠️  Não foi possível mapear usuário do campo '$field'" -ForegroundColor Yellow
                                        }
                                    } elseif ($fieldValue -is [Array]) {
                                        # Campo de usuários múltiplos
                                        $userIds = @()
                                        foreach ($userValue in $fieldValue) {
                                            try {
                                                if ($userValue.Email) {
                                                    $user = Get-PnPUser -Identity $userValue.Email -ErrorAction SilentlyContinue
                                                    if ($null -ne $user) {
                                                        $userIds += $user.Id
                                                    }
                                                } elseif ($userValue.LookupValue) {
                                                    $user = Get-PnPUser | Where-Object { $_.Title -eq $userValue.LookupValue } | Select-Object -First 1
                                                    if ($null -ne $user) {
                                                        $userIds += $user.Id
                                                    }
                                                }
                                            } catch {
                                                # Ignorar se o usuário não existir no destino
                                            }
                                        }
                                        if ($userIds.Count -gt 0) {
                                            $fieldValues[$field] = $userIds
                                            Write-Host "      ✅ Campo de usuários '$field' mapeado: $($userIds.Count) usuário(s)" -ForegroundColor Green
                                        }
                                    }
                                    
                                    # Reconectar ao site de origem
                                    Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
                                    
                                } elseif ($fieldType -eq "Lookup" -or $fieldType -eq "LookupMulti") {
                                    # Campos de lookup - ignorar por enquanto (requerem mapeamento)
                                    continue
                                } else {
                                    # Outros tipos de campos
                                    $fieldValues[$field] = $fieldValue
                                }
                            } else {
                                # Campo sem tipo definido - adicionar valor diretamente
                                $fieldValues[$field] = $fieldValue
                            }
                        }
                    }

                    # Conectar ao site de destino
                    Connect-PnPOnline -Url $global:targetSiteUrl -Interactive -ClientId $global:AppClientId
                    
                    if ($fieldValues.Count -gt 0) {
                        Write-Host "      📋 Adicionando item com $($fieldValues.Count) campo(s)" -ForegroundColor Gray
                        Add-PnPListItem -List $list.Title -Values $fieldValues -ErrorAction Stop
                        $itemCount++
                    } else {
                        Write-Host "      ⚠️  Nenhum campo válido para copiar neste item" -ForegroundColor Yellow
                    }
                    
                    # Reconectar ao site de origem para o próximo item
                    Connect-PnPOnline -Url $global:sourceSiteUrl -Interactive -ClientId $global:AppClientId
                    
                } catch {
                    Write-Host "    ⚠️  Erro ao adicionar item: $_" -ForegroundColor Yellow
                    # Continuar com o próximo item
                }
            }
            
            Write-Host "    ✅ $itemCount itens clonados de $($items.Count) totais" -ForegroundColor Green
            
        } catch {
            Write-Host "    ❌ Erro ao clonar itens da lista $($list.Title): $_" -ForegroundColor Red
        }
    }
    
    Write-Host "`n✅ Clonagem de itens de listas concluída!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erro geral na clonagem de itens: $_" -ForegroundColor Red
    throw
}
