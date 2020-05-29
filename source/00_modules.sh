#Module loading

# Note:- functions in this file are to do with loading bash modules only, and
#        are not meant to be utility functions for other modules.  Those belong
#        in 10_meta.sh

# Skip if already loaded
type -p __load_modules && return

# There's a lot of nonsense display logic. All of this is opinionated, so it's
# guarded with tests for flag files - by default you'll see nothing when bash
# loads

# bashrc flag functions

#MJL20190614 turn on my bashrc banner loading bells and whistles
function bashrc_pretty(){
  local FUNCDESC="Turn on all bash/module loading bells and whistles"
  touch ~/etc/.bashrc_banner ~/etc/.bashrc_loading ~/etc/.bashrc_lols
}
alias bashrc_lols=bashrc_pretty
function is_bashrc_pretty(){
  local FUNCDESC="Return 0 if bashrc banner, module loading and lolcat are on, 1 if not"

  test -f ~/etc/.bashrc_banner && \
  test -f ~/etc/.bashrc_loading && \
  test -f ~/etc/.bashrc_lols && return 0
  return 1
}
function bashrc_boring(){
  local FUNCDESC="Turn off all bashrc/module loding bells and whistles"
  rm -f ~/etc/.bashrc_*
}
function is_bashrc_boring(){
  local FUNCDESC="Return 0 if all the bashrc/module loading bells and whistles are off, 1 otherwise."
  is_bashrc_banner && return 1
  is_bashrc_loading && return 1
  test -f ~/etc/.bashrc_lols && return 1
  test -f ~/etc/.bashrc_amstrad && return 1
  return 0
}
function bashrc_banner(){
  local FUNCDESC="Turn on the bashrc banner display"
  touch ~/etc/.bashrc_banner ~/etc/.bashrc_loading
}
function is_bashrc_banner(){
  local FUNCDESC="Return 0 if the bashrc banner is on, 1 if not"
  test -f ~/etc/.bashrc_banner
}
function bashrc_loading(){
  local FUNCDESC="Turn on display of bash module looding in bashrc"
  touch ~/etc/.bashrc_loading
}
function is_bashrc_loading(){
  local FUNCDESC="Return 0 if bashrc module loading display is on, 1 if not"
  test -f ~/etc/.bashrc_loading
}
function cpcify(){
  local FUNCDESC="Make bashrc start up like an Amstrad CPC

Also enables and Amstrad 'Ready' prompt"
  bashrc_boring; bashrc_banner; touch ~/etc/.bashrc_amstrad; prompt_amstrad t
}
function is_cpcified(){
  local FUNCDESC="Return 0 if bash is behaving like an Amstrad CPC, 1 if not"
  is_bashrc_banner \
    && test -f ~/etc/.bashrc_amstrad && return 0
  return 1
}
function uncpcify(){
  local FUNCDESC="Turn off Amstrad CPCification of bash"
  bashrc_boring; prompt_reset
}
function bashrc_debug(){
  local FUNCDESC="Toggle bashrc module load debugging"

  if is_bashrc_debug; then
    rm -f ~/etc/.bashrc_debug
  else
    touch ~/etc/.bashrc_debug
    if ! is_bashrc_loading; then
      bashrc_loading  #need this too
    fi
  fi
}
function is_bashrc_debug(){
  local FUNCDESC="Return 0 if bashrc load debugging is on, 1 if not"

  test -f ~/etc/.bashrc_debug
}
alias bashrc_undebug="rm -f ~/etc/.bashrc_debug"

function bashrc_slow(){
  local FUNCDESC="Make bashrc module loading slower"
  touch ~/etc/.bashrc_slow
}
function is_bashrc_slow(){
  local FUNCDESC="Return 0 if slow bashrc module loading is on, 1 if not"
  test -f ~/etc/.bashrc_slow
}
function bashrc_fast(){
  local FUNCDESC="Make bashrc module loading fast"
  rm -f ~/etc/.bashrc_slow
}
function is_tty(){
  local FUNCDESC="Return 0 if connected to a TTY terminal, 1 if not"
  test -t 1
}

# loading modules

function __load_modules() {
  local MODULE
  if is_tty && is_bashrc_loading; then
    local HIGH='\033[1;32m' MED='\033[0;36m' LOW='\033[0;37m'

    echo -e " ${HIGH}Loading bash modules...${LOW}"
    local MODULES=(${BASH_MODULES}/*.sh)
    local WIDTH=$((${#MODULES[0]} - ${#BASH_MODULES} + 4))

    for MODULE in ${MODULES[@]}; do
      if is_bashrc_debug; then
        echo "${MODULE}"
        shopt -s extdebug
        set -x
        source "${MODULE}"
        set +x
        shopt -u extdebug
      else
        printf "\r%${WIDTH}s"
        WIDTH=$((${#MODULE} - ${#BASH_MODULES} + 4))
        printf "\r${MED}<-- $(basename -s .sh ${MODULE})${LOW}"
        source "${MODULE}"
        if is_bashrc_slow; then
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
  elif is_tty && is_bashrc_loading; then
    local TIMER=$(mktemp -t loadtimeXXX)
    local RED='\033[0;31m' GREEN='\033[0;32m' LOW='\033[0;37m'
    local PR_COLOUR=${RED}
    { time __load_modules; } 2> ${TIMER} && PR_COLOUR=${GREEN}
    local NOMODS=(${BASH_MODULES}/*.sh); NOMODS=${#NOMODS[@]}
    local SUMMARY=" (${NOMODS} modules, $(awk '/real/{print $2}' ${TIMER}))"
    rm ${TIMER}
    printf "\r${PR_COLOUR}${SUMMARY}${LOW}%$((${COLUMNS}-${#SUMMARY}))s\n";
  else # no TTY, just load
    __load_modules
  fi
}
function lssrc(){
    local FUNCDESC="List the Dotfiles bash modules available for the src function.
The .sh suffix is stripped."
    \ls ${BASH_MODULES}|awk '/.sh$/ { gsub(/\.sh/, ""); print }'
}
_src() {
  COMPREPLY=()
  local CUR="${COMP_WORDS[COMP_CWORD]}"
  local SOURCES="$(lssrc)"
  COMPREPLY=( $(compgen -W "${SOURCES}" -- ${CUR}) )
  return 0
}
complete -F _src src

function __bootstrap_modules(){
# Load my bash modules (if interactive shell).  For a login shell, also print a
# bash banner, à la the AMSTRAD CPC, if enabled. ;-)  If we're doing pretty
# bootloading then use lolcat for the banner.
    if ( shopt -q login_shell && is_bashrc_banner ); then

      local BANNER=$(bash --version|head -n2\
            |sed 's/Copyright (C) /©/'|awk '{print " " $0}')

      if is_cpcified; then
        printf " \033[0;33m$(hostname -s) $(uname -srm)\n\n${BANNER}\n"
      elif ( type -p lolcat &> /dev/null && is_bashrc_pretty ); then
        printf " $(hostname -s) $(uname -srm)\n\n"
        echo "${BANNER}"|lolcat
      else
        printf " $(hostname -s) $(uname -srm)\n\n${BANNER}\n"
      fi

      echo ' '
      src
      echo ' '
      is_cpcified && prompt_amstrad t

    elif [[ $- == *i* ]] ; then  # is interactive?
      src
    fi
}