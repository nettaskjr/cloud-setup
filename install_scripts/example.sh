#!/usr/bin/env bash

# install_scripts/xxxx.sh - Instala o(a) xxxx.
# Este script é chamado por cloud_setup.sh se o app 'xxxx' for solicitado.

# Segurança: sair em caso de erro.
set -e
set -o pipefail
set -u

# --- CARREGANDO A BIBLIOTECA COMPARTILHADA ---
# Encontra o diretório do script atual para poder voltar um nível (../)
# e encontrar a biblioteca de forma confiável.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/../lib_utils.sh"

log "Iniciando a instalação do(a) xxxx..."

# Verifica se o xxxx já está instalado.
if command -v xxxx &> /dev/null; then
    error "xxxx já parece estar instalado. Verificando a versão."
    xxxx --version
    log "Nenhuma ação necessária."
    exit 0
fi