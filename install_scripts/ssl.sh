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
app = "ssl"  # Substitua 'xxxx' pelo nome do aplicativo que está sendo instalado.
app_extenso="$app" # Substitua ${app} pelo nome completo do aplicativo, se necessário.

log "Iniciando a instalação do(a) ${app_extenso}"

# Verifica se o app já está instalado.
# validar como será feito o teste de instalação

file="docker-compose/${app}.yml"

geml="nestor.junior@gmail.com"
gdns="nettask.com.br" 

# atualiza as informações para geração do certificado SSL
sed -i "s/<<EMAIL>>/${geml}/g" "${file}"
sed -i "s/<<HOST>>/${gdns}/g" "${file}"

sudo docker-compose -f "${file}" up -d

success "Instalação do ${app_extenso} concluída com sucesso.}."