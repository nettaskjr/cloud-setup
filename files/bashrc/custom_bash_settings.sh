# *********************************************
# * ~/.bashrc Personalizado para Debian/Ubuntu*
# * local: /home/user/.bashrc                 *
# *                                           *
# * Author: Thiago Nalli Valentim             *
# * E-Mail: thiago.nalli@gmail.com            *
# * Date: 2012-05-24                          *
# * Modificação por: Nestor Junior            *
# * E-Mail: nestor.junior@gmail.com           *
# * Date: 2019-11-15                          *
# *********************************************
# ======================================================================
# Adaptado do original de Edinaldo P. Silva para Arch Linux
# URL: http://gnu2all.blogspot.com.br/2011/10/arch-linux-bashrc.html
# ======================================================================

#-----------------------------------------------
# Configurações Gerais
#-----------------------------------------------

# Se não estiver rodando interativamente, não fazer nada
[ -z "$PS1" ] && return

# Não armazenar as linhas duplicadas ou linhas que começam com espaço no historico
HISTCONTROL=ignoreboth

# Adicionar ao Historico e não substitui-lo
shopt -s histappend

# Definições do comprimento e tamnho do historico.
HISTSIZE=1000
HISTFILESIZE=2000

# Mostra branch atual do git no terminal
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }

#-----------------------------------------------
# Váriavies com as Cores
#-----------------------------------------------
NONE="\[\033[0m\]" # Eliminar as Cores, deixar padrão)

## Cores de Fonte
K="\[\033[0;30m\]" # Black (Preto)
R="\[\033[0;31m\]" # Red (Vermelho)
G="\[\033[0;32m\]" # Green (Verde)
Y="\[\033[0;33m\]" # Yellow (Amarelo)
B="\[\033[0;34m\]" # Blue (Azul)
M="\[\033[0;35m\]" # Magenta (Vermelho Claro)
C="\[\033[0;36m\]" # Cyan (Ciano - Azul Claro)
W="\[\033[0;37m\]" # White (Branco)

## Efeito Negrito (bold) e cores
BK="\[\033[1;30m\]" # Bold+Black (Negrito+Preto)
BR="\[\033[1;31m\]" # Bold+Red (Negrito+Vermelho)
BG="\[\033[1;32m\]" # Bold+Green (Negrito+Verde)
BY="\[\033[1;33m\]" # Bold+Yellow (Negrito+Amarelo)
BB="\[\033[1;34m\]" # Bold+Blue (Negrito+Azul)
BM="\[\033[1;35m\]" # Bold+Magenta (Negrito+Vermelho Claro)
BC="\[\033[1;36m\]" # Bold+Cyan (Negrito+Ciano - Azul Claro)
BW="\[\033[1;37m\]" # Bold+White (Negrito+Branco)

## Cores de fundo (backgroud)
BGK="\[\033[40m\]" # Black (Preto)
BGR="\[\033[41m\]" # Red (Vermelho)
BGG="\[\033[42m\]" # Green (Verde)
BGY="\[\033[43m\]" # Yellow (Amarelo)
BGB="\[\033[44m\]" # Blue (Azul)
BGM="\[\033[45m\]" # Magenta (Vermelho Claro)
BGC="\[\033[46m\]" # Cyan (Ciano - Azul Claro)
BGW="\[\033[47m\]" # White (Branco)

#-----------------------------------------------
# Descrição dos comandos para conf. o terminal
#-----------------------------------------------

#“\u:\w\\$ “ = Exibe usuário atual (dois pontos), caminho do diretório atual e 
#      # para usuário root ou $ para usuário comum.
#Lista de parâmetros:
#\d A data atual no formato “Dia_da_semana Mês Dia”
#\h Nome da máquina até o primeiro . (ponto)
#\n Nova linha
#\s Nome do shell
#\t A hora atual no formato de 24 horas hh:mm:ss
#\u O nome do usuário atual
#\w Caminho completo do diretório de trabalho atual
#\W Nome do diretório atual
#\! O número do comando no histórico
#\# O número do comando na sessão atual do shell
#\$ Caractere que diferencia um usuário comum do super-usuário
#\\ Uma barra
#\[ Inicia uma seqüencia de caracteres que não serão impressos na tela para
#       poder incluir uma sequência de controle do terminal
#\] Fim da seqüencia de caracteres que não serão impressos

#-----------------------------------------------
# Configurações referentes ao usuário
#-----------------------------------------------

### Verifica se é usuário root (UUID=0) ou usuário comum
#if [ $UID -eq "0" ]; then

## Verifica se é usuário root (UUID=0) ou usuário comum
#info=<<TXT>>

if [ $UID -eq "0" ]; then

## Cores e efeitos do Usuario root
    PS1="
  $BR┌─[\u]$BY@-$info-@$BR[$BW${HOSTNAME%%.*}$BR]$BR[\$(parse_git_branch)]$B:\w\n$BR  └─>$BR \\$ $NONE"

else

## Cores e efeitos do usuário comum
    PS1="
  $BG┌─[$G\u$BG]$BY@-$info-@$BG[$W${HOSTNAME%%.*}$BG][$G\$(parse_git_branch)$BG]$B:\w\n$BG  └─> \\$ $NONE"

fi

## Exemplos de PS1
#PS1="\e[01;31m┌─[\e[01;35m\u\e[01;31m]──[\e[00;37m${HOSTNAME%%.*}\e[01;32m]:\w$\e[01;31m\n\e[01;31m└──\e[01;36m>>\e[00m"
#PS1='\[\e[m\n\e[1;30m\][$$:$PPID \j:\!\[\e[1;30m\]]\[\e[0;36m\] \T \d \[\e[1;30m\][\[\e[1;34m\]\u@\H\[\e[1;30m\]:\[\e[0;37m\]${SSH_TTY} \[\e[0;32m\]+${SHLVL}\[\e[1;30m\]] \[\e[1;37m\]\w\[\e[0;37m\] \n($SHLVL:\!)\$ '}
#PS1="\e[01;31m┌─[\e[01;35m\u\e[01;31m]──[\e[00;37m${HOSTNAME%%.*}\e[01;32m]:\w$\e[01;31m\n\e[01;31m└──\e[01;36m>>\e[00m"
#PS1="┌─[\[\e[34m\]\h\[\e[0m\]][\[\e[32m\]\w\[\e[0m\]]\n└─╼ "
#PS1='[\u@\h \W]\$ '

#-----------------------------------------------
# Cores para o man
#-----------------------------------------------

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

#-----------------------------------------------
# Aliases para uso no dia-a-dia e testes
#-----------------------------------------------

## Habilitando suporte a cores para o ls e outros aliases
## Vê se o arquivo existe
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    ## Aliases (apelidos) para comandos
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias dir='dir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi # Fim do if do dircolor

# Testar conexão com ping
alias google='ping -t 3 www.google.com.br' # Ping ao google a cada 3 segundos
alias uol='ping -t 3 www.uol.com.br' # Ping ao UOL a cada 3 segundos

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
