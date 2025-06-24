#!/usr/bin/env bash

set -e # Sai imediatamente se um comando falhar

# --- CARREGANDO A BIBLIOTECA COMPARTILHADA ---
# Encontra o diretório do script atual para poder voltar um nível (../)
# e encontrar a biblioteca de forma confiável.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
readonly CUSTOM_BASHRC_DIR="${SCRIPT_DIR}"
source "${SCRIPT_DIR}/../../lib_utils.sh"

# --- Verificação de Segurança ---
if [[ "$(id -u)" -ne 0 ]]; then
  error "Este script precisa ser executado como root. Use 'sudo ./install.sh'"

  exit 0
fi

# --- Definição de Arquivos ---
readonly SOURCE_FILE="${CUSTOM_BASHRC_DIR}/custom_bash_settings.sh"
readonly DEST_FILE="/etc/profile.d/custom_bash_settings.sh"
readonly SYSTEM_BASHRC="/etc/bash.bashrc"

# Verifica se o arquivo de origem existe
if [ ! -f "$SOURCE_FILE" ]; then
    error "O arquivo de origem '${SOURCE_FILE}' não foi encontrado."
fi

# ==============================================================================
# --- INÍCIO DA EXECUÇÃO ---
# ==============================================================================

log "Iniciando a instalação das configurações globais do Bash..."

# --- PASSO 1: Copiando o arquivo de configurações ---
warn "==> Passo 1: Copiando configurações para ${DEST_FILE}"
cp "${SOURCE_FILE}" "${DEST_FILE}"
chmod 644 "${DEST_FILE}"
success "Arquivo copiado com sucesso."
echo ""

# --- PASSO 2: Configurando o bash.bashrc global ---
warn "==> Passo 2: Garantindo que ${SYSTEM_BASHRC} carregue o novo arquivo"
if grep -q "source " "${SYSTEM_BASHRC}"; then
    log "Configuração já existe em ${SYSTEM_BASHRC}. Nenhuma alteração necessária."
else
    echo -e "\n# [CUSTOM] Carrega configurações de shell globais customizadas\nif [ -f \"${DEST_FILE}\" ]; then\n    source \"${DEST_FILE}\"\nfi" >> "${SYSTEM_BASHRC}"
    success "Configuração adicionada com sucesso a ${SYSTEM_BASHRC}."
fi
echo ""

# --- PASSO 3: Verificação informativa do /etc/skel ---
warn "==> Passo 3: Verificando /etc/skel para novos usuários"
if grep -q "/etc/bash.bashrc" "/etc/skel/.bashrc"; then
    log "Configuração para novos usuários (/etc/skel) parece estar correta."
else
    warn "/etc/skel/.bashrc não parece carregar /etc/bash.bashrc. Novos usuários podem não receber as configurações."
fi
echo ""

# --- PASSO 4: Modificando os .bashrc locais para evitar conflitos ---
warn "==> Passo 4: Verificando e corrigindo os arquivos .bashrc dos usuários existentes..."

# Define os textos de início e fim do bloco a ser comentado
TEXTO_INICIO="force_color_prompt=yes"
TEXTO_COMENTADO="##force_color_prompt=yes" # por padrão, o bloco PS1 já vem comentado
TEXTO_FIM="unset color_prompt force_color_prompt"

# Itera sobre o diretório home do root e de todos os outros usuários em /home
for user_home in /root /home/*; do
    # Verifica se é um diretório válido
    if [ ! -d "${user_home}" ]; then
        continue
    fi

    local_bashrc="${user_home}/.bashrc"

    # Verifica se o .bashrc do usuário existe
    if [ -f "${local_bashrc}" ]; then
        log "Analisando arquivo: ${local_bashrc}"

        # VERIFICAÇÃO CHAVE:
        # 1. Procura pelo padrão inicial (o bloco de PS1 existe?)
        # 2. Se existir, verifica se ele JÁ NÃO ESTÁ comentado.
        # A combinação dos dois garante que só agimos se o bloco estiver ativo.
        if grep -q "$TEXTO_INICIO" "${local_bashrc}" && ! grep -q "$TEXTO_COMENTADO" "${local_bashrc}"; then
            # Se o bloco PS1 ativo for encontrado, comentamos ele.
            success "Bloco PS1 ativo encontrado em ${local_bashrc}. Comentando agora..."
            # O COMANDO MÁGICO DO SED:
            # -i.bak   => Edita o arquivo no local e cria um backup com a extensão .bak
            # s/^/#/   => Comando de substituição: substitui o início da linha (^) por '# '
            sed -i.bak "/$TEXTO_INICIO/,/$TEXTO_FIM/s/^/#/" "${local_bashrc}"
            success "Backup ${local_bashrc}.bak criado e arquivo modificado."
        else
            success "Nenhum bloco PS1 ativo encontrado ou já comentado. Nenhuma ação necessária."
        fi
    fi
done

# --- Finalização ---
log "Para que as alterações tenham efeito, usuários logados precisam:"
log "1. Fechar e reabrir o terminal, OU"
log "2. Executar o comando: source ~/.bashrc"
