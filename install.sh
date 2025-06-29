#!/bin/bash

# install.sh - Script de instalação do pacote cloud-setup.
# Otimizado para execução não-interativa em ambientes de nuvem.

# --- Configurações de Segurança e Robustez ---
# Sai imediatamente se um comando falhar.
set -e
# Trata erros em pipelines.
set -o pipefail

# Instalando dependências necessárias
export DEBIAN_FRONTEND=noninteractive
echo $1
sudo apt install -y jq

# Pegando a ultima versão do repositório cloud-setup
TAG_NAME=$(curl -s https://api.github.com/repos/nettaskjr/cloud-setup/releases/latest | jq -r '.tag_name')
ASSET_URL="https://github.com/nettaskjr/cloud-setup/releases/download/${TAG_NAME}/cloud-setup_${TAG_NAME}.tar.gz"
FILE="cloud-setup-$TAG_NAME.tar.gz"
curl -L -o ${FILE} ${ASSET_URL}
tar -zxvf ${FILE}
cd cloud-setup
chmod +x *.sh



