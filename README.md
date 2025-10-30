# SharePoint Cloner

## Objetivo
Automatizar a clonagem de sites SharePoint Online, incluindo listas, bibliotecas, pastas e arquivos, preservando metadados e replicando entre ambientes como dev, hom e prod.

## Funcionalidades

✅ **Implementadas:**
- Clonagem de listas e bibliotecas (estrutura e campos personalizados)
- Clonagem de estrutura de pastas
- Clonagem de itens de listas com metadados
- Clonagem de arquivos de bibliotecas
- Tratamento de campos de usuário (User/UserMulti)
- Logs detalhados de execução
- Autenticação interativa (Browser)

❌ **Não Suportadas:**
- Site Pages (páginas ASPX) - Limitação de permissão do SharePoint Online
- Campos de lookup complexos
- Permissões de item
- Workflows

## Estrutura do Projeto
```
/SharePointCloner
│
├── /scripts
│   ├── Connect-ToSites.ps1          # Autenticação e conexão
│   ├── Clone-ListsAndLibraries.ps1  # Clona listas/bibliotecas
│   ├── Clone-FolderStructure.ps1    # Clona estrutura de pastas
│   ├── Clone-ListItems.ps1          # Clona itens com metadados
│   ├── Clone-Files.ps1              # Clona arquivos
│   ├── Main.ps1                     # Script principal
│   └── /disabled                    # Scripts desabilitados
│       ├── Clone-SitePages.ps1      # Desabilitado (limitação)
│       └── Debug-Lists.ps1          # Script de diagnóstico
│
├── /logs
│   └── execution-log-YYYYMMDD_HHMMSS.log
│
├── /config
│   └── sites.json                   # Configuração de sites
│
├── /docs
│   └── CORREÇÕES-ASPX.md           # Documentação sobre limitações
│
└── README.md
```

## Pré-requisitos
- PowerShell 7+
- Módulo PnP.PowerShell instalado
- Registro de aplicação no Azure AD com permissões adequadas
- Certificado PFX para autenticação

## Configuração

### 1. Instalar PnP PowerShell
```powershell
Install-Module -Name PnP.PowerShell -Force -AllowClobber
```

### 2. Criar Registro de Aplicação no Azure AD
1. Acesse o portal do Azure ([https://portal.azure.com](https://portal.azure.com)).
2. Navegue até **Azure Active Directory > App registrations** e clique em **New registration**.
3. Preencha os campos obrigatórios:
   - **Name**: Nome da aplicação (ex.: SharePointClonerApp).
   - **Supported account types**: Escolha "Accounts in this organizational directory only".
   - **Redirect URI**: Deixe em branco.
4. Clique em **Register**.
5. Anote o **Application (client) ID** e o **Directory (tenant) ID**.
6. Vá para **Certificates & secrets** e clique em **Upload certificate** para enviar o arquivo PFX.

### 3. Configurar Permissões da Aplicação
1. Vá para **API permissions** e clique em **Add a permission**.
2. Escolha **SharePoint** e selecione **Application permissions**.
3. Adicione as permissões necessárias:
   - `Sites.FullControl.All`
4. Clique em **Grant admin consent** para conceder permissões.

### 4. Configurar Credenciais no Script
Atualize o arquivo `AppConfig.ps1` com as informações do registro da aplicação:
```powershell
$global:AppClientId = "<seu-client-id>"
$global:AppTenantId = "<seu-tenant-id>"
$global:CertificatePath = "<caminho-para-seu-certificado>.pfx"
$global:CertificatePassword = "<senha-do-certificado>"
```

### 5. Configurar Sites
Atualize o arquivo `config/sites.json`:
```json
{
  "sourceSiteUrl": "https://tenant.sharepoint.com/sites/origem",
  "targetSiteUrl": "https://tenant.sharepoint.com/sites/destino"
}
```

## Execução

### Execução Completa
```powershell
pwsh -File "d:/Metrô/CloneSharepoint/SharePointCloner/scripts/Main.ps1"
```

### Execução de Scripts Individuais
```powershell
# Apenas listas e bibliotecas
. "d:/Metrô/CloneSharepoint/SharePointCloner/scripts/Clone-ListsAndLibraries.ps1"

# Apenas arquivos
. "d:/Metrô/CloneSharepoint/SharePointCloner/scripts/Clone-Files.ps1"
```

## Logs
Os logs são salvos automaticamente em `logs/execution-log-YYYYMMDD_HHMMSS.log` e incluem:
- Timestamp de cada operação
- Nível de log (INFO, WARNING, ERROR, SUCCESS)
- Detalhes de erros e avisos
- Resumo de itens processados

## Limitações Conhecidas

### Site Pages (Páginas ASPX)
**Não suportado** devido a limitações de segurança do SharePoint Online:
- Requer permissões especiais não disponíveis via PnP PowerShell
- Erro: "Access denied" mesmo com Full Control
- **Solução**: Copiar páginas manualmente ou usar SharePoint Migration Tool

### Campos de Lookup
- Campos de lookup requerem mapeamento manual dos IDs
- Atualmente ignorados durante a clonagem

### Campos de Usuário
- ✅ Campos de usuário único: Suportado
- ✅ Campos de múltiplos usuários: Suportado
- ⚠️  Usuários devem existir no site de destino

### Permissões
- Permissões de item não são copiadas
- Apenas a estrutura e conteúdo são replicados

## Solução de Problemas

### Erro: "List does not exist"
**Causa**: Contexto de conexão incorreto após alternar entre sites
**Solução**: O script já inclui reconexões automáticas. Se persistir, execute os scripts individualmente.

### Erro: "Access denied"
**Causa**: Permissões insuficientes
**Solução**: 
1. Verifique se você é Site Collection Administrator
2. Verifique as permissões da aplicação Azure AD
3. Para Site Pages, veja documentação em `/docs/CORREÇÕES-ASPX.md`

### Campos de usuário não mapeados
**Causa**: Usuário não existe no site de destino
**Solução**: Certifique-se de que os usuários existem em ambos os sites

## Segurança
- ⚠️  **Nunca commite credenciais no código**
- Use Azure Key Vault para secrets em produção
- Mantenha o Client ID e Tenant ID em variáveis de ambiente
- Logs podem conter informações sensíveis - revise antes de compartilhar

## Contribuindo
1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

## Licença
Este projeto é de uso interno.

## Suporte
Para dúvidas ou problemas, abra uma issue no repositório ou entre em contato com a equipe de desenvolvimento.

## Atualização: Caminhos Relativos

O script foi atualizado para utilizar caminhos relativos ao diretório do script (`$PSScriptRoot`), garantindo maior portabilidade. Isso significa que você pode clonar o repositório em qualquer local do sistema e executar os scripts sem necessidade de ajustes nos caminhos.

### Como Usar

1. **Clone o Repositório**
   ```bash
   git clone <URL_DO_REPOSITORIO>
   cd SharePointCloner
   ```

2. **Configure o App Registration**
   - Preencha o arquivo `config/AppConfig.ps1` com as informações do Azure AD App Registration:
     ```powershell
     $global:AppClientId = "<seu-client-id>"
     $global:AppTenantId = "<seu-tenant-id>"
     $global:CertificatePath = "<caminho-relativo-para-certificado>.pfx"
     $global:CertificatePassword = "<senha-do-certificado>"
     ```

3. **Execute o Script Principal**
   - Navegue até o diretório `scripts` e execute o script principal:
     ```powershell
     pwsh -File "./Main.ps1"
     ```

4. **Logs**
   - Os logs serão gerados automaticamente no diretório `logs` dentro do repositório.

5. **Execução de Scripts Individuais**
   - Você também pode executar scripts específicos, como:
     ```powershell
     . ./Clone-ListsAndLibraries.ps1
     . ./Clone-Files.ps1
     ```

### Observações
- Certifique-se de que o módulo `PnP.PowerShell` está instalado:
  ```powershell
  Install-Module -Name PnP.PowerShell -Force -AllowClobber
  ```
- Caso encontre erros de execução, ajuste a política de execução temporariamente:
  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  ```

### Publicação no GitHub
- Este repositório está pronto para ser publicado em um Git público. Certifique-se de remover ou proteger informações sensíveis, como credenciais ou certificados, antes de compartilhar.