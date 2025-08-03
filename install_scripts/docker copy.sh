#!/usr/bin/env bash

# install_scripts/docker.sh - Instala o Docker Engine.
# Este script é chamado por cloud_setup.sh se o app 'docker' for solicitado.

# Sai imediatamente se um comando falhar.
set -e
# Trata erros em pipelines.
set -o pipefail

# --- CARREGANDO A BIBLIOTECA COMPARTILHADA ---
# Encontra o diretório do script atual para poder voltar um nível (../)
# e encontrar a biblioteca de forma confiável.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/../lib_utils.sh"

log "Iniciando a instalação do Docker Engine..."

# Verifica se o Docker já está instalado.
if command -v docker &> /dev/null; then
    error "Docker parece que já está instalado. Verificando a versão."
    docker --version
    log "Nenhuma ação necessária."
    exit 0
fi

# Verifica se as dependências (curl, jq, unzip) estão instaladas, se nao estiver instala
for cmd in ca-certificates curl gnupg; do
    if ! command -v "$cmd" &> /dev/null; then
        log "Instalando a dependência: $cmd"
        apt install -y "$cmd"
    fi
done

# Adiciona a chave GPG oficial do Docker.
install -m 0755 -d --preserve-context /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Adiciona o repositório do Docker ao Apt.
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualiza a lista de pacotes com o novo repositório.
apt update -y

# Instala a versão mais recente do Docker.
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

success "Docker Engine instalado com sucesso."

# Adiciona os usuários do sistema ao grupo 'docker'.
log "Adicionando usuários do sistema ao grupo 'docker'..."
# Obtém a lista de usuários com diretórios home válidos, excluindo 'nologin'.
awk -F: '$6 ~ /^\/home\// && $6 != "/home/nologin" { print $1 }' /etc/passwd | while read -r username; do

  # Verifica se o usuário já está no grupo docker
  if groups "$username" | grep -q '\bdocker\b'; then
    error "O usuário '$username' já pertence ao grupo docker. Nenhuma ação necessária."
  else
    log "Adicionando o usuário '$username' ao grupo 'docker'..."
    # Adiciona o usuário ao grupo docker usando usermod
    # -a (append): adiciona o usuário a grupos suplementares sem removê-lo de outros
    # -G (groups): especifica o grupo (docker)
    sudo usermod -aG docker "$username"

    # Verifica se o comando foi bem-sucedido 
    if [ $? -eq 0 ]; then
      success ">>> Usuário '$username' adicionado com sucesso."
    else
      error "Falha ao adicionar o usuário '$username'."
    fi
  fi
done

log "Verificação da instalação:"
docker --version

success "Instalação do Docker concluída."