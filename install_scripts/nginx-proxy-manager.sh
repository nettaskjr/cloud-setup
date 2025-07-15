#!/usr/bin/env bash

# install_scripts/nginx-proxy-manager.sh - Instala o Nginx Proxy Manager.
# Este script é chamado por cloud_setup.sh se o app 'nginx-proxy-manager' for solicitado.

# Sai imediatamente se um comando falhar.
set -e
# Trata erros em pipelines.
set -o pipefail

# --- CARREGANDO A BIBLIOTECA COMPARTILHADA ---
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/../lib_utils.sh"

log "Iniciando a instalação do Nginx Proxy Manager..."

# --- PRÉ-REQUISITOS ---
# 1. Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
    ./cloud_setup.sh --app docker
fi

# 2. Verificar se o Docker Compose (plugin ou standalone) está instalado
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    error "Docker Compose não está instalado. A instalação do Docker via cloud_setup deveria incluí-lo."
    error "Por favor, verifique sua instalação do Docker ou instale 'docker-compose-plugin'."
    exit 1
fi

# Variável para o comando do compose
DOCKER_COMPOSE_CMD="docker compose"
if ! docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
fi
log "Usando '${DOCKER_COMPOSE_CMD}' para o deploy."

# --- CONFIGURAÇÃO ---
readonly NPM_DIR="/opt/nginx-proxy-manager"
readonly COMPOSE_FILE="${NPM_DIR}/docker-compose.yml"

log "Configurando diretório de instalação em '${NPM_DIR}'..."
mkdir -p "${NPM_DIR}"

# Verifica se o container já está rodando
if [ -f "${COMPOSE_FILE}" ]; then
    # O comando ps -q retorna os IDs dos containers. Se não houver saída, os containers não estão rodando.
    if [[ -n "$(${DOCKER_COMPOSE_CMD} -f ${COMPOSE_FILE} ps -q 2>/dev/null)" ]]; then
        log "Nginx Proxy Manager parece já estar em execução em '${NPM_DIR}'."
        log "Nenhuma ação necessária."
        exit 0
    else
        warn "Arquivo docker-compose.yml encontrado, mas os containers não estão rodando. Tentando iniciá-los..."
    fi
else
    log "Criando o arquivo de configuração '${COMPOSE_FILE}'..."
    # Usando cat com EOF para criar o arquivo docker-compose.yml
    cat << EOF > "${COMPOSE_FILE}"
version: '3.8'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy-manager
    restart: unless-stopped
    ports:
      - '80:80'
      - '443:443'
      - '81:81'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
networks:
  default:
    name: nginx-proxy-net
EOF
    success "Arquivo docker-compose.yml criado com sucesso."
fi

# --- INICIALIZAÇÃO ---
log "Iniciando os containers do Nginx Proxy Manager..."
(cd "${NPM_DIR}" && ${DOCKER_COMPOSE_CMD} up -d)

# --- MENSAGEM FINAL ---
success "Nginx Proxy Manager instalado e iniciado com sucesso!"
log "=========================================================================="
log "  Acesse a interface de administração para configurar seus domínios."
log ""
log "  URL:      http://<IP_DO_SEU_SERVIDOR>:81"
log ""
log "  Credenciais Padrão:"
log "  Email:    admin@example.com"
log "  Senha:    changeme"
log ""
log "  IMPORTANTE: Altere a senha padrão no seu primeiro login!"
log "=========================================================================="

success "Instalação do Nginx Proxy Manager concluída."