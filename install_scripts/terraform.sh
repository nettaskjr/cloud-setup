#!/usr/bin/env bash

# install_scripts/terraform.sh - Instala o(a) terraform.
# Este script é chamado por cloud_setup.sh se o app 'terraform' for solicitado.

# Sai imediatamente se um comando falhar.
set -e
# Trata erros em pipelines.
set -o pipefail

# --- CARREGANDO A BIBLIOTECA COMPARTILHADA ---
# Encontra o diretório do script atual para poder voltar um nível (../)
# e encontrar a biblioteca de forma confiável.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/../lib_utils.sh"
app="terraform"  # Substitua 'xxxx' pelo nome do aplicativo que está sendo instalado.
app_extenso="$app" # Substitua ${app} pelo nome completo do aplicativo, se necessário.

log "Iniciando a instalação do(a) ${app_extenso}"

# Verifica se o app já está instalado.
if command -v ${app} &> /dev/null; then
    error "${app_extenso} parece estar instalado! Verificando a versão."
    ${app} --version
    log "Nenhuma ação necessária."
    exit 0
fi

# Verifica se as dependências (curl, jq, unzip) estão instaladas, se nao estiver instala
for cmd in curl jq unzip wget; do
    if ! command -v "$cmd" &> /dev/null; then
        log "Instalando a dependência: $cmd"
        apt install -y "$cmd"
    fi
done

log "Buscando a última versão do Terraform..."
# Obtém a versão mais recente da API de checkpoint da HashiCorp.
TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)

if [[ -z "$TERRAFORM_VERSION" ]]; then
    error "Erro: Não foi possível obter a última versão do Terraform." >&2
    exit 1
fi

log "A versão mais recente do Terraform é: ${TERRAFORM_VERSION}"

OS="linux"
ARCH="amd64"
NOME_ARQUIVO="terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip"
URL_DOWNLOAD="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${NOME_ARQUIVO}"

# Cria um diretório temporário para o download e garante sua limpeza ao final.
DIR_TEMP=$(mktemp -d)
trap 'rm -rf -- "$DIR_TEMP"' EXIT

log "Baixando o Terraform ${TERRAFORM_VERSION}..."
wget -q -c -P "$DIR_TEMP" "$URL_DOWNLOAD"

log "Extraindo o arquivo..."
unzip -q "${DIR_TEMP}/${NOME_ARQUIVO}" -d "$DIR_TEMP"

log "Movendo o binário 'terraform' para /usr/local/bin..."
sudo mv "${DIR_TEMP}/terraform" "/usr/local/bin/terraform"

log "Instalação do Terraform v${TERRAFORM_VERSION} concluída com sucesso!"

log "Verificação da instalação:"
${app} --version

success "Instalação do ${app_extenso} concluída com sucesso."