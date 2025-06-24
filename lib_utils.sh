#!/usr/bin/env bash

# lib_utils.sh - Biblioteca de funções e variáveis úteis.
# Este arquivo deve ser "carregado" (sourced) e não executado diretamente.

# --- Definições de Cor ---
# Verifica se a saída é um terminal para decidir se usa cores.
if [[ -t 1 ]]; then
  readonly BOLD='\033[1m'
  readonly RED='\033[0;31m'
  readonly GREEN='\033[0;32m'
  readonly YELLOW='\033[0;33m'
  readonly NC='\033[0m' # No Color
else
  readonly BOLD=''
  readonly RED=''
  readonly GREEN=''
  readonly YELLOW=''
  readonly NC=''
fi

# --- Funções de Log ---

log() {
  echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

warn() {
  echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARN: $1${NC}"
}

success() {
  echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: $1${NC}"
}

error() {
  echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

debug() {
  echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ${BOLD}DEBUG:${RED} $1${NC}"
}
