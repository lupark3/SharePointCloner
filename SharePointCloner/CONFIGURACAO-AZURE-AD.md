# Configuração do Azure AD App Registration

## Passo 1: Criar um Registro de Aplicação
1. Acesse o portal do Azure ([https://portal.azure.com](https://portal.azure.com)).
2. Navegue até **Azure Active Directory > App registrations** e clique em **New registration**.
3. Preencha os campos obrigatórios:
   - **Name**: Nome da aplicação (ex.: SharePointClonerApp).
   - **Supported account types**: Escolha "Accounts in this organizational directory only".
   - **Redirect URI**: Deixe em branco.
4. Clique em **Register**.
5. Anote o **Application (client) ID** e o **Directory (tenant) ID**.

## Passo 2: Configurar Permissões da Aplicação
1. Vá para **API permissions** e clique em **Add a permission**.
2. Escolha **SharePoint** e selecione **Application permissions**.
3. Adicione as permissões necessárias:
   - `Sites.FullControl.All`
4. Clique em **Grant admin consent** para conceder permissões.

## Passo 3: Configurar Certificado para Autenticação
1. Vá para **Certificates & secrets** e clique em **Upload certificate**.
2. Faça o upload do arquivo `.cer` correspondente ao certificado PFX que será usado nos scripts.

## Passo 4: Atualizar Configuração nos Scripts
No arquivo `AppConfig.ps1`, atualize as variáveis com as informações do registro da aplicação:
```powershell
$global:AppClientId = "<seu-client-id>"
$global:AppTenantId = "<seu-tenant-id>"
$global:CertificatePath = "<caminho-para-seu-certificado>.pfx"
$global:CertificatePassword = "<senha-do-certificado>"
```

## Referências
- [Documentação oficial do PnP PowerShell](https://pnp.github.io/powershell/)
- [Configuração de App Registration no Azure AD](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
