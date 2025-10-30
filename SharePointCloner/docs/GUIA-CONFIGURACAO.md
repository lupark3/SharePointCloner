# 🚀 Guia de Configuração - SharePoint Cloner

## 📋 Pré-requisitos

1. **PowerShell 7+** instalado
2. **Módulo PnP.PowerShell** instalado
3. **App Registration no Azure AD** configurado

---

## 🔧 Configuração Inicial

### 1. Instalar PnP PowerShell

```powershell
Install-Module -Name PnP.PowerShell -Force -AllowClobber
```

### 2. Criar App Registration no Azure AD

1. Acesse o **Portal Azure** (https://portal.azure.com)
2. Vá em **Azure Active Directory** > **App registrations** > **New registration**
3. Configure o aplicativo:
   - **Name**: SharePointCloner (ou nome de sua preferência)
   - **Supported account types**: Accounts in this organizational directory only
   - Clique em **Register**

4. Copie as seguintes informações:
   - **Application (client) ID**
   - **Directory (tenant) ID**

5. Configure autenticação:
   - Vá em **Authentication** > **Add a platform** > **Mobile and desktop applications**
   - Adicione a Redirect URI: `http://localhost`
   - Clique em **Configure**

6. Configure permissões:
   - Vá em **API permissions** > **Add a permission**
   - Selecione **Microsoft Graph**
   - Adicione as seguintes permissões **Delegated**:
     - `Sites.FullControl.All`
     - `User.Read.All`
   - Clique em **Grant admin consent** (requer admin do tenant)

### 3. Configurar o Script

1. Abra o arquivo `config/AppConfig.ps1`
2. Localize as linhas:
   ```powershell
   # >>> SUBSTITUA PELO SEU APPLICATION (CLIENT) ID <<<
   $global:AppClientId = "seu-client-id-aqui"
   
   # >>> SUBSTITUA PELO SEU DIRECTORY (TENANT) ID <<<
   $global:AppTenantId = "seu-tenant-id-aqui"
   ```
3. Substitua os valores pelos IDs copiados do Azure AD
4. Salve o arquivo

---

## 🎯 Uso do Script

### Execução Padrão (Interativa)

1. Abra o PowerShell
2. Navegue até a pasta do projeto:
   ```powershell
   cd "d:\Metrô\CloneSharepoint"
   ```
3. Execute o script principal:
   ```powershell
   pwsh -File "SharePointCloner\scripts\Main.ps1"
   ```

4. O script solicitará:
   - **Site de Origem**: URL completa do site fonte  
     Exemplo: `https://contoso.sharepoint.com/sites/origem`
   
   - **Site de Destino**: URL completa do site destino  
     Exemplo: `https://contoso.sharepoint.com/sites/destino`

5. Uma janela do navegador abrirá para autenticação
6. Faça login com uma conta que tenha permissões nos sites
7. Aguarde a conclusão do processo

### Exemplo de Execução

```
╔════════════════════════════════════════════════════════════════╗
║      SHAREPOINT CLONER - Clonagem de Sites SharePoint         ║
╚════════════════════════════════════════════════════════════════╝

📋 CONFIGURAÇÃO DA CLONAGEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 Site de Origem: (ex: https://tenant.sharepoint.com/sites/origem)
   : https://contoso.sharepoint.com/sites/origem

📍 Site de Destino: (ex: https://tenant.sharepoint.com/sites/destino)
   : https://contoso.sharepoint.com/sites/destino

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔗 Conectando ao SharePoint Online...
✅ Autenticação realizada com sucesso!
...
```

---

## 🔐 Autenticação com Certificado (Opcional/Avançado)

Para automação sem intervenção do usuário:

1. Gere um certificado autoassinado:
   ```powershell
   $cert = New-SelfSignedCertificate -Subject "CN=SharePointCloner" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature
   ```

2. Exporte o certificado:
   ```powershell
   $pwd = ConvertTo-SecureString -String "SuaSenhaForte!" -Force -AsPlainText
   Export-PfxCertificate -Cert $cert -FilePath "C:\Certificados\SharePointCloner.pfx" -Password $pwd
   ```

3. Configure no Azure AD:
   - Vá em **App registrations** > Seu App > **Certificates & secrets**
   - Upload o arquivo `.cer` (versão pública do certificado)

4. Configure no `AppConfig.ps1`:
   ```powershell
   $global:CertificatePath = "C:\Certificados\SharePointCloner.pfx"
   $global:CertificatePassword = "SuaSenhaForte!"
   ```

---

## 📊 O Que é Copiado

✅ **Listas e Bibliotecas**  
✅ **Campos personalizados**  
✅ **Estrutura de pastas**  
✅ **Itens de listas com metadados**  
✅ **Arquivos com metadados**  
✅ **Campos de usuário (User/UserMulti)**  

❌ **Site Pages** (limitação do SharePoint Online)  
❌ **Workflows**  
❌ **Permissões de item**  
❌ **Campos de lookup** (requerem mapeamento manual)

---

## 📝 Logs

Os logs são salvos automaticamente em:  
`SharePointCloner/logs/execution-log-YYYYMMDD_HHMMSS.log`

---

## ⚠️ Permissões Necessárias

### No SharePoint

O usuário que executar o script deve ter:
- **Site Collection Administrator** ou
- **Full Control** nos sites de origem e destino

### No Azure AD

O App Registration deve ter:
- `Sites.FullControl.All` (Delegated)
- `User.Read.All` (Delegated)
- Admin consent concedido

---

## 🔧 Solução de Problemas

### Erro: "Access denied"

**Solução**: Verifique se você tem permissões nos dois sites

### Erro: "The application '...' does not exist"

**Solução**: Verifique o Client ID em `AppConfig.ps1`

### Erro: "Invalid redirect URI"

**Solução**: Verifique se configurou `http://localhost` como Redirect URI no Azure AD

### Erro: "Consent not granted"

**Solução**: Peça ao admin do tenant para conceder consentimento nas permissões do app

---

## 📞 Suporte

Para dúvidas ou problemas, entre em contato com a equipe de desenvolvimento.

---

## 📄 Licença

Uso interno da organização.
