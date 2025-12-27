 #!/usr/bin/env bash

# install_scripts/base.sh - Instala o base Engine.
# Este script é chamado por cloud_setup.sh caso informado a opçao -b ou --base.

# Sai imediatamente se um comando falhar.
set -e
# Trata erros em pipelines.
set -o pipefail

# --- CARREGANDO A BIBLIOTECA COMPARTILHADA ---
# Encontra o diretório do script atual para poder voltar um nível (../)
# e encontrar a biblioteca de forma confiável.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/../lib_utils.sh"

# Instala os arquivos base do sistema
log "Iniciando a instalação dos apps base..."

# repositorio para fastfetch
log "Adicionando repositório PPA para fastfetch"
add-apt-repository ppa:zhangsongcui3371/fastfetch -y && apt update -y 

APPS="ca-certificates"          # autoridades certificadoras para autenticação SSL
APPS="${APPS} curl"             # cliente URL
APPS="${APPS} dirmngr"          # necessário para importar chave de assinatura do repositório
APPS="${APPS} gnupg"            # usado para comunicação e armazenamento seguro (criptografia)
APPS="${APPS} htop"             # um top metido a besta
APPS="${APPS} locate"           # localização de arquivos
APPS="${APPS} lsb-release"      # identifica a distribuição Linux (/etc/os-release)
APPS="${APPS} fastfetch"        # fetch de inicialização da distro (embelezamento)
APPS="${APPS} stress"           # script de teste de stress para o servidor
APPS="${APPS} tzdata"           # configuração de timezone
APPS="${APPS} unzip"            # compactador zip entre outros
APPS="${APPS} unrar-free"       # compactador RAR
APPS="${APPS} vim"              # vim melhorado
APPS="${APPS} wget"             # ferramenta de download
APPS="${APPS} xauth"            # utilitário de autenticação do X
APPS="${APPS} ncdu"             # analisador de uso de disco no terminal

apt install ${APPS} -y

# Atualiza os arquivos do sistema
log "Atualiza o banco de dados do locate"
# updatedb  # não é recomendado usar com wsl, pois irá indexar todo o sistema de arquivos do computador hospedeiro

# Inclui o fastfetch na inicialização do sistema
log "Cria um arquivo de perfil para exibir o fasttech na inicialização"
echo 'fastfetch' > /etc/profile.d/mymotd.sh && sudo chmod +x /etc/profile.d/mymotd.sh

# Atualiza o timezone do sistema
log "Atualiza o timezone do sistema para America/Sao_Paulo"
mv /etc/localtime /etc/localtime.old
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Instala o script de configuração do bashrc
INSTALL_BASHRC="${SCRIPT_DIR}/../files/bashrc/install-bash-settings.sh"
chmod +x ${INSTALL_BASHRC}
exec ${INSTALL_BASHRC}
