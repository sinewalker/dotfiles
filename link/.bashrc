# Bash Run Commands

# Run by login or interactive shells, and also by Bash when called as /bin/sh in
# some situations. So this needs to be POSIX syntax or guard Bashisms

# There's a lot of nonsense display logic. All of this is opinionated, so it's
# guarded with tests for flag files - by default you'll see nothing when bash
# loads. See ${BASH_MODULES}/20_env.sh for bashrc_ aliases to turn it on.

# Source system global definitions
test -f /etc/bashrc && source /etc/bashrc

# Where the magic happens
export DOTFILES=~/.dotfiles
export BASH_MODULES=${DOTFILES}/source

PATH=${DOTFILES}/bin:${PATH}
export PATH

function __load_modules() {
  local MODULE
  if test -t 1 && test -f ~/etc/.bashrc_loading; then  # is a TTY and show?
    local HIGH='\033[1;32m' MED='\033[0;36m' LOW='\033[0;37m'

    echo -e " ${HIGH}Loading bash modules...${LOW}"
    local MODULES=(${BASH_MODULES}/*.sh)
    local WIDTH=$((${#MODULES[0]} - ${#BASH_MODULES} + 4))

    for MODULE in ${MODULES[@]}; do
      if test -f ~/etc/.bashrc_debug; then
        echo "${MODULE}"
        source "${MODULE}"
      else
        printf "\r%${WIDTH}s"
        WIDTH=$((${#MODULE} - ${#BASH_MODULES} + 4))
        printf "\r${MED}<-- $(basename -s .sh ${MODULE})${LOW}"
        source "${MODULE}"
        if test -f  ~/etc/.bashrc_slow ; then
          sleep 0.25
        fi
      fi
    done
  else # no TTY/show, just load
    for MODULE in ${BASH_MODULES}/*.sh; do
      source "${MODULE}"
    done
  fi
}
function src() {
  local FUNCDESC="Source all modules in ${BASH_MODULES}, or a specified module.

If there is a file ~/etc/.bashrc_loading then show the modules as they load,
with a summary at the end of how many modules there are, and how long they
took to load.

If there is a file ~/etc/.bashrc_debug then the module names will be listed
while sourced, instead of overwritten.

If no attached TTY, or no loading file, then just source the modules."
  if [[ "${1}" ]]; then
    source "${BASH_MODULES}/${1}.sh"
  elif test -t 1 && test -f ~/etc/.bashrc_loading; then # is a TTY and show?
    local TIMER=$(mktemp -t loadtimeXXX)
    local RED='\033[0;31m' GREEN='\033[0;32m' LOW='\033[0;37m'
    local PR_COLOUR=${RED}
    { time __load_modules; } 2> ${TIMER} && PR_COLOUR=${GREEN}
    local NOMODS=(${BASH_MODULES}/*.sh); NOMODS=${#NOMODS[@]}
    local SUMMARY=" (${NOMODS} modules, $(awk '/real/{print $2}' ${TIMER}))"
    rm ${TIMER}
    printf "\r${PR_COLOUR}${SUMMARY}${LOW}%$((${COLUMNS}/2-${#SUMMARY}))s\n";
  else # no TTY, just load
    __load_modules
  fi
}

function lssrc(){
    local FUNCDESC="List the Dotfiles bash modules available for the src function.
The .sh suffix is stripped."
    \ls ${BASH_MODULES}|awk '/.sh$/ { gsub(/\.sh/, ""); print }'
}

# Completion for src function (requires bash_completion)
_src() {
  COMPREPLY=()
  local CUR="${COMP_WORDS[COMP_CWORD]}"
  local SOURCES="$(lssrc)"
  COMPREPLY=( $(compgen -W "${SOURCES}" -- ${CUR}) )
  return 0
}
complete -F _src src

function dotfiles() {
    local FUNCDESC="Run dotfiles refresh script, then reload.
This causes the Copy, Link and Init step to be run."
    ${DOTFILES}/bin/dotfiles "${@}" && src
}

# In interactive shells, unless in POSIX mode, load the rest of the Dotfiles
# bash modules into the environment. (POSIX will fail, non-interactive shells
# don't need the Dotfiles bash modules)

#
# For a login shell, also print a bash banner, à la the AMSTRAD CPC if enabled
# by presence of ~/etc/.bashrc_banner ;-)
#
# If there's a ~/etc/.bashrc_lols file then use lolcat for the banner.
if kill -l|grep SIG &> /dev/null; then #is not POSIX?
    if ( shopt -q login_shell && test -f ~/etc/.bashrc_banner ); then

      BANNER=$(bash --version|head -n2\
            |sed 's/Copyright (C) /©/'|awk '{print " " $0}')

      if test -f ~/etc/.bashrc_amstrad; then
        printf " \033[0;33m$(hostname -s) $(uname -srm)\n\n${BANNER}\n"
      elif ( type -p lolcat &> /dev/null && test -f ~/etc/.bashrc_lols ); then
        printf " $(hostname -s) $(uname -srm)\n\n"
        echo "${BANNER}"|lolcat
      else
        printf " $(hostname -s) $(uname -srm)\n\n${BANNER}\n"
      fi

      unset BANNER
      echo ' '
      src
      echo ' '
      test -f ~/etc/.bashrc_amstrad && prompt_amstrad t

    elif [[ $- == *i* ]] ; then  # is interactive?
      src
    fi
fi
