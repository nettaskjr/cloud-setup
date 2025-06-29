#!/usr/bin/env bash

# install_scripts/xxxx.sh - Instala o(a) xxxx.
# Este script é chamado por cloud_setup.sh se o app 'xxxx' for solicitado.

# Sai imediatamente se um comando falhar.
set -e
# Trata erros em pipelines.
set -o pipefail

# --- CARREGANDO A BIBLIOTECA COMPARTILHADA ---
# Encontra o diretório do script atual para poder voltar um nível (../)
# e encontrar a biblioteca de forma confiável.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/../lib_utils.sh"

log "Iniciando a instalação do(a) Github-cli..."

# Verifica se o xxxx já está instalado.
if command -v gh &> /dev/null; then
    error "Github-cli já parece estar instalado. Verificando a versão."
    gh --version
    log "Nenhuma ação necessária."
    exit 0
fi

(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# Para verificar o limite de tokens:
# Substitua a URL e o TOKEN
#  curl -i -H "Authorization: Bearer SEU_TOKEN_DO_GITHUB" https://api.github.com/users/google

log "Verificação da instalação:"
gh --version

log "Instalação do Docker concluída."