 #!/bin/bash
# install_scripts/nginx.sh - Script de instalação do Nginx.
# Este script é chamado por cloud-setup.sh para instalar o Nginx.

# Sai imediatamente se um comando falhar.
set -e
# Trata erros em pipelines.
set -o pipefail

# --- CARREGANDO A BIBLIOTECA COMPARTILHADA ---
# Encontra o diretório do script atual para poder voltar um nível (../)
# e encontrar a biblioteca de forma confiável.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/../lib_utils.sh"

# Instala o Nginx via apt
log "Iniciando a instalação do Nginx..."
apt update -y
apt install nginx -y  
log "Nginx instalado com sucesso."

# A instalação do Nginx registra perfis de aplicação no UFW.
# 'Nginx Full' abre as portas 80 (HTTP) e 443 (HTTPS).
log "Configurando o firewall da instância (UFW)..."
ufw allow 'Nginx Full'
# Habilita o firewall sem pedir confirmação interativa.
ufw --force enable

log "Garantindo que o Nginx inicie com o sistema..."
# Habilita o serviço Nginx para iniciar automaticamente no boot.
systemctl enable nginx
# Reinicia o serviço para garantir que ele esteja em execução com a configuração mais recente.
systemctl restart nginx

log "Nginx instalado. Criando página de teste..."

# Cria uma página de teste personalizada para o Nginx para confirmar a instalação
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Nginx - Teste</title>
    <style>
        body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #f0f2f5; margin: 0; }
        .container { text-align: center; background-color: white; padding: 40px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        h1 { color: #009f6b; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Instalação Concluída!</h1>
        <p>Se você está vendo esta página, o Nginx foi instalado com sucesso na sua instância OCI via Terraform e cloud-init.</p>
    </div>
</body>
</html>
EOF

log "Página de teste criada. Script de inicialização concluído com sucesso."