#!/usr/bin/env bash

# cloud_setup.sh - Script de provisionamento e atualização para Debian/Ubuntu.
# Otimizado para execução não-interativa em ambientes de nuvem.

# --- Configurações de Segurança e Robustez ---
# Sai imediatamente se um comando falhar.
set -e
# Trata erros em pipelines.
set -o pipefail
# Ativa as opções de padrões estendidos para o shell atual
#shopt -s extglob

# --- Variáveis Globais ---
# Diretório onde os scripts de instalação customizados estão localizados.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
readonly CUSTOM_SCRIPTS_DIR="${SCRIPT_DIR}/install_scripts"

# Carrega a biblioteca de utilitários.
source "${SCRIPT_DIR}/lib_utils.sh"

# Exibe a ajuda do script.
show_help() {
  cat << EOF
Uso: ${0##*/} [-u] [-a app1] [-a app2] ... [-h]

Este script automatiza a instalação e atualização de aplicativos em sistemas Debian-like.

Opções:
  -a, --app <nome>    Especifica um aplicativo para instalar. Pode ser um pacote 'apt'
                      ou um script customizado em './install_scripts/<nome>.sh'.
                      Esta opção pode ser usada várias vezes. Requer 'sudo'.

  -b, --base          Instala a base do sistema, incluindo aplicativos essenciais.
                      Requer 'sudo'.

  -u, --update-all    Atualiza a lista de pacotes e todos os pacotes já instalados
                      no sistema para suas versões mais recentes. Requer 'sudo'.

  -h, --help          Mostra esta mensagem de ajuda.

Exemplos:
  # Obter ajuda:
  ./${0##*/} --help

  # Apenas atualizar o sistema (precisa de sudo):
  sudo ./${0##*/} --update-all

  # Instalar nginx (via apt) e docker (via script customizado):
  sudo ./${0##*/} --app nginx --app docker
EOF
}

# Atualiza o sistema (apt update e apt upgrade).
update_system() {
  log "Iniciando a atualização completa do sistema..."
  # Garante que o frontend do apt seja não-interativo. Essencial para a nuvem.
  export DEBIAN_FRONTEND=noninteractive
  apt  update -y
  # A opção --with-new-pkgs lida com novas dependências de forma inteligente.
  apt upgrade -y --with-new-pkgs
  apt autoremove -y
  apt clean
  success "Atualização do sistema concluída."
}

# Instala os aplicativos base, altera o prompt e atualiza o timezone, além de outros aplicativos essenciais.
base() {
  local custom_script_base="${CUSTOM_SCRIPTS_DIR}/base.sh"

  log "Iniciando a instalação da base do sistema..."

  log "Atribuindo permissão de execução para ${custom_script_base}"
  chmod +x "${custom_script_base}"

  # Executa o script de instalação do base
  "${custom_script_base}"

  success "Instalação da base do sistema concluída."
}

# Instala um aplicativo.
# Verifica se existe um script de instalação customizado, senão, usa apt.
install_app() {
  local app_name=$(echo -n "$argumento_original" | sed -e 's/^[[:space:]]*//') # Remove espaços a esquerda
  local custom_script_path="${CUSTOM_SCRIPTS_DIR}/${app_name}.sh"

  log "Processando a instalação de '${app_name}'..."

  if [[ -f "${custom_script_path}" ]]; then
    log "Encontrado script de instalação customizado para '${app_name}'. Executando..."
    if [[ ! -x "${custom_script_path}" ]]; then
        log "Atribuindo permissão de execução para ${custom_script_path}"
        chmod +x "${custom_script_path}"
    fi
    "${custom_script_path}"
    log "Script customizado para '${app_name}' concluído."
  else
    log "Nenhum script customizado encontrado. Tentando instalar '${app_name}' via apt..."
    export DEBIAN_FRONTEND=noninteractive
    apt install -y "${app_name}"
    success "Instalação de '${app_name}' via apt concluída."
  fi
}

# --- Função Principal ---
main() {
  local do_base=false
  local do_update=false
  local apps_to_install=()

  # Define as opções curtas e longas.
  local options
  options=$(getopt -o a:buh --long app:,base,update-all,help -n "${0##*/}" -- "$@")
  if [[ $? -ne 0 ]]; then
      show_help
      exit 1
  fi
  eval set -- "${options}"

  # Loop para processar os argumentos.
  while true; do
    case "$1" in
      -a | --app)
        apps_to_install+=("$2")
        shift 2
        ;;
      -b | --base)
        do_base=true
        shift
        ;;
      -u | --update-all)
        do_update=true
        shift
        ;;
      -h | --help)
        show_help
        exit 0
        ;;
      --)
        shift
        break
        ;;
      *)
        error "Erro interno de parsing!"
        ;;
    esac
  done

  # Verifica se alguma ação *real* foi solicitada.
  if ${do_update} && ${do_base} && [[ ${#apps_to_install[@]} -eq 0 ]]; then
    log "Nenhuma ação solicitada. Use -u para atualizar ou -a para instalar. Use -h para ajuda."
    exit 0
  fi

  # --- PONTO DE VERIFICAÇÃO DE ROOT ---
  if [[ "$(id -u)" -ne 0 ]]; then
    error "As opções --update-all, --app e --base requerem privilégios de root. Use 'sudo'."
    exit 0
  fi

  # --- Execução das Tarefas ---

  # 1. Atualizar o sistema, se solicitado.
  if ${do_update}; then
    update_system
  fi

  # 2. Instalar a base do sistema, se solicitado.
  if ${do_base}; then
    # Garante que o update foi executado mesmo que o usuário não tenha solicitado.
    update_system
    
    base
  fi

  # 3. Instalar os aplicativos solicitados.
  if [[ ${#apps_to_install[@]} -gt 0 ]]; then
    log "Iniciando a instalação de ${#apps_to_install[@]} aplicativo(s)..."
  
    # Garante que o update foi executado mesmo que o usuário não tenha solicitado.
    update_system

    for app in "${apps_to_install[@]}"; do
      install_app "${app}"
    done
    success "Todos os aplicativos solicitados foram processados."
  fi

  success "Script concluído com successo!"
}

# --- Ponto de Entrada ---
main "$@"
