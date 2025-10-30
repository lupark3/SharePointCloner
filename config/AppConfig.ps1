# ═══════════════════════════════════════════════════════════════
# CONFIGURAÇÕES DO SHAREPOINT CLONER
# ═══════════════════════════════════════════════════════════════
# 
# INSTRUÇÕES: 
# Altere os valores abaixo com as informações do seu ambiente
# 
# ═══════════════════════════════════════════════════════════════

# ┌───────────────────────────────────────────────────────────────┐
# │  CONFIGURAÇÕES DO AZURE AD APP REGISTRATION                   │
# └───────────────────────────────────────────────────────────────┘
# 
# Obtenha estas informações em:
# Portal Azure > Azure Active Directory > App registrations > Seu App
#

# >>> SUBSTITUA PELO SEU APPLICATION (CLIENT) ID <<<
$global:AppClientId = ""

# >>> SUBSTITUA PELO SEU DIRECTORY (TENANT) ID <<<
$global:AppTenantId = ""


# Para autenticação com certificado, configure os valores abaixo:
# (Deixe em branco para usar autenticação interativa via browser)
#

# Caminho completo para o arquivo .pfx do certificado
# Exemplo: "C:\Certificados\MeuApp.pfx"
$global:CertificatePath = ""

# Senha do certificado (se aplicável)
# Exemplo: "MinhaS3nh@Segur@"
$global:CertificatePassword = ""


# ┌───────────────────────────────────────────────────────────────┐
# │  CONFIGURAÇÕES DE TENANT (AUTOMÁTICO)                         │
# └───────────────────────────────────────────────────────────────┘
#
# O nome do tenant será extraído automaticamente da URL do site
# Não é necessário alterar esta seção
#

# Esta variável será preenchida automaticamente
$global:TenantName = ""


# ═══════════════════════════════════════════════════════════════
# NOTAS IMPORTANTES:
# ═══════════════════════════════════════════════════════════════
#
# 1. PERMISSÕES NECESSÁRIAS NO AZURE AD:
#    • Sites.FullControl.All
#    • User.Read.All
#
# 2. CONFIGURAÇÃO DO APP REGISTRATION:
#    • Platform: Mobile and desktop applications
#    • Redirect URI: http://localhost
#
# 3. AUTENTICAÇÃO INTERATIVA (PADRÃO):
#    • Não requer certificado
#    • Abre o browser para login
#    • Recomendado para uso manual
#
# 4. AUTENTICAÇÃO COM CERTIFICADO (AVANÇADO):
#    • Requer certificado .pfx
#    • Recomendado para automação
#    • Configure $CertificatePath e $CertificatePassword
#
# ═══════════════════════════════════════════════════════════════
