# My awesome bash prompt
#
# Copyright (c) 2012,2017,2018 "Cowboy" Ben Alman, Michael Lockhart [MJL]
#
# Licensed under the MIT license.
# http://benalman.com/about/license/
#
# small changes identified with "MJL" are Licensed Creative Commons by 4.0
# https://creativecommons.org/licenses/by/4.0/
#
# Example:
# [master:!?][cowboy@CowBook:~/.dotfiles]
# [11:14:45] $
#
# Read more (and see a screenshot) in the "Prompt" section of
# https://github.com/cowboy/dotfiles

# ANSI CODES - SEPARATE MULTIPLE VALUES WITH ;
#
#  0  reset          4  underline
#  1  bold           7  inverse
#
# FG  BG  COLOR     FG  BG  COLOR
# 30  40  black     34  44  blue
# 31  41  red       35  45  magenta
# 32  42  green     36  46  cyan
# 33  43  yellow    37  47  white

if [[ ! "${PROMPT_COLORS[@]}" ]]; then
    PROMPT_COLORS=(
        "36;1" # information color
        "36" # bracket color
        "31;7" # error color
        "37;1" #paren colour
        "35" # jobs colour
        "33;1" #venv colour
        "44;33;1" #screen window colour
  )

  if [[ "${SSH_TTY}" ]]; then
    # connected via ssh
      PROMPT_COLORS[0]="32;1"
      PROMPT_COLORS[1]="32"
  elif [[ "${USER}" == "root" ]] || [[ "${UID}" == "0" ]]; then
    # logged in as root
      PROMPT_COLORS[0]="31;1"
      PROMPT_COLORS[1]="31"
  fi
fi

# Inside a prompt function, run this alias to setup local $c0-$c9 color vars.
alias __prompt_getcolors='PROMPT_COLORS[9]=; local I; for I in ${!PROMPT_COLORS[@]}; do local C${I}="\[\e[0;${PROMPT_COLORS[${I}]}m\]"; done'

# Exit code of previous command.
function __prompt_exitcode() {
  __prompt_getcolors
  [[ ${1} != 0 ]] && echo "${C2} ${1} ${C9}"
}

#MJL20170204 title bar
#see https://goo.gl/6E8a2u (SO: "Using git-prompt.sh PROMPT_COMMAND to change
# Cygwin Title Bar")
function __prompt_titlebar() {
        case ${TERM} in
            *xterm*|ansi|rxvt|*konsole*)
                printf "\033]0;%s\007" "$*"
                ;;
        esac
}

#MJL20170204 jobs
function __prompt_jobs() {
    local JOBCOUNT=$(jobs -r|awk 'END{print NR}')
    [[ ${JOBCOUNT} = 0 ]] && return
    echo "${C3}(${C4}${JOBCOUNT}${C3})${C9}"
}

#MJL20170205 python virtual environment name
function __prompt_venv() {
    [[ -z ${VIRTUAL_ENV} ]] && return
    local VENV=${VIRTUAL_ENV}
    is_exe conda && VENV=${CONDA_DEFAULT_ENV}
    echo "${C3}(${C5}$(basename ${VENV})${C3})${C9}"
}

#MJL20170205 screen window number
function __prompt_screen() {
    [[ -z ${WINDOW} ]] && return
    echo "${C6} ${WINDOW} ${C9}"
}

# Git status.
function __prompt_git() {
  local STATUS OUTPUT FLAGS BRANCH
  STATUS="$(git status 2>/dev/null)"
  [[ ${?} != 0 ]] && return;
  OUTPUT="$(echo "${STATUS}" | awk '/# Initial commit/ {print "(init)"}')"
  [[ "${OUTPUT}" ]] || OUTPUT="$(echo "${STATUS}" | awk '/# On branch/ {print $4}')"
  [[ "${OUTPUT}" ]] || OUTPUT="$(git branch | perl -ne '/^\* \(detached from (.*)\)$/ ? print "($1)" : /^\* (.*)/ && print $1')"
  FLAGS="$(
    echo "${STATUS}" | awk 'BEGIN {r=""} \
        /^(# )?Changes to be committed:$/        {r=r "+"}\
        /^(# )?Changes not staged for commit:$/  {r=r "!"}\
        /^(# )?Untracked files:$/                {r=r "?"}\
      END {print r}'
  )"
  if [[ "${FLAGS}" ]]; then
    OUTPUT="${OUTPUT}${C1}:${C0}${FLAGS}"
  fi
  echo "${C1}[${C0}${OUTPUT}${C1}]${C9}"
}

# hg status.
function __prompt_hg() {
  local SUMMARY OUTPUT BOOKMARK FLAGS
  SUMMARY="$(hg summary 2>/dev/null)"
  [[ ${?} != 0 ]] && return;
  OUTPUT="$(echo "${SUMMARY}" | awk '/branch:/ {print $2}')"
  BOOKMARK="$(echo "${SUMMARY}" | awk '/bookmarks:/ {print $2}')"
  FLAGS="$(
    echo "${SUMMARY}" | awk 'BEGIN {r="";a=""} \
      /(modified)/     {r= "+"}\
      /(unknown)/      {a= "?"}\
      END {print r a}'
  )"
  OUTPUT="${OUTPUT}:${BOOKMARK}"
  if [[ "${FLAGS}" ]]; then
    OUTPUT="${OUTPUT}${C1}:${C0}${FLAGS}"
  fi
  echo "${C1}[${C0}${OUTPUT}${C1}]${C9}"
}

# SVN info.
function __prompt_svn() {
  local INFO LAST CURRENT
  INFO="$(svn info . 2> /dev/null)"
  if [[ "${INFO}" ]]; then
    LAST="$(echo "${INFO}" | awk '/Last Changed Rev:/ {print $4}')"
    CURRENT="$(echo "${INFO}" | awk '/Revision:/ {print $2}')"
    echo "${C1}[${C0}${LAST}${C1}:${C0}${CURRENT}${C1}]${C9}"
  fi
}

#MJL20170223 show a snake if Anaconda is active
function __prompt_conda() {
    is_exe conda || return
    local SNAKE VENV
    SNAKE="\[\e[0;30;42m\]S"
    ! [[ ${TERM} =~ linux ]] && [[ -z ${SSH_TTY} ]] && [[ -z ${WINDOW} ]] && SNAKE="🐍 "
    [[ ${CONDA_DEFAULT_ENV} ]] && VENV="${C3}-${C5}${CONDA_DEFAULT_ENV}"
    echo "${C1}(${C9}${SNAKE}${VENV}${C1})${C9}"
}

#MJL20170218 files and size count (from "monster prompt" in my ancient dotfiles)
function __prompt_sizes() {
    echo "${C1}(${C9}$(ls --si -al|awk '/total/{TOTAL=$2} END{print NR-1 " files, " TOTAL}')${C1})${C9}"
}

#MJL20170218 CPU load and uptime (from monster prompt)
function __prompt_cpu() {
    local upt=$(uptime|awk '{gsub(",",""); printf "%d ",$3/NR}; /day/ {print $4",", $5}; /min/ {print $6}')
    local lda=$(uptime|awk --field-separator 'load' '{split($2, lds, " "); print lds[2]}')
    echo "${C1}[${C0}Up ${C4}${upt}${C0} Load ${C5}${lda}${C1}]${C9}"
}

function __prompt_ending(){
    [[ "${USER}" == "root" ]] || [[ "${UID}" == "0" ]] && __USER=root
    [[ -z ${SSH_TTY} ]] && [[ -z ${WINDOW} ]] && __TERM=smart

    if [[ ${__TERM} == smart  ]]; then
       if [[ "${__USER}" == "root" ]]; then
           __ENDING="Ω"
       else
           __ENDING="β"
       fi
    else
        if [[ "${__USER}" == "root" ]]; then
            __ENDING="#"
        else
            __ENDING="$"
        fi
    fi

    echo "${C9}${__ENDING} "
}

#MJL20170205 toggle using a simple prompt
# If an argument is supplied, force it to simple
function prompt_simple() {
    local FUNCDESC="Toggle using a simple prompt. If an argument is supplied, force to simple"
    if [[ -z ${__USE_SIMPLE_PROMPT} || -n "${1}" ]]; then
        export __USE_SIMPLE_PROMPT=1
    else
        unset __USE_SIMPLE_PROMPT
    fi
}
alias simple_prompt=prompt_simple
alias awesome_prompt=prompt_simple

#MJL20180402 toggle using monster prompt
# If an argument is supplied, force it to simple
function prompt_monster() {
    local FUNCDESC="Toggle using a monster prompt. If an argument is supplied, force to simple"
    if [[ -z ${__USE_MONSTER_PROMPT} || -n "${1}" ]]; then
        export __USE_MONSTER_PROMPT=1
    else
        unset __USE_MONSTER_PROMPT
    fi
}
alias monster_prompt=prompt_monster

#MJL20170207 toggle command history trace
# sometimes this can be useful
function prompt_trace() {
    local FUNCDESC="Toggle command history trace. Sometimes this can be helpful."
    if [[ -z ${__USE_TRACE_PROMPT} || -n "${1}" ]]; then
        export __USE_TRACE_PROMPT=1
    else
        unset __USE_TRACE_PROMPT
    fi
}
alias trace_prompt=prompt_trace

# Maintain a per-execution call stack.
__PROMPT_STACK=()
trap '__PROMPT_STACK=("${__PROMPT_STACK[@]}" "${BASH_COMMAND}")' DEBUG

function __prompt_command() {
  local EXIT_CODE=${?}
  # If the first command in the stack is prompt_command, no command was run.
  # Set exit_code to 0 and reset the stack.
  [[ "${__PROMPT_STACK[0]}" == "__PROMPT_COMMAND" ]] && EXIT_CODE=0
  __PROMPT_STACK=()

  # Manually load z here, after $? is checked, to keep $? from being clobbered.
  [[ "$(type -t _z)" ]] && _z --add "$(pwd -P 2>/dev/null)" 2>/dev/null

  #MJL20170207 disable the awesome prompt for basic environments
  [[ -n ${ANDROID_ROOT} ]] && prompt_simple 1

  # While the simple_prompt environment var is set, disable the awesome prompt.
  [[ "$__USE_SIMPLE_PROMPT" ]] && PS1='[\u@\h:\w]\$ ' && return

  __prompt_getcolors
   if [[ -n ${MC_SID} ]]; then
      #MJL20170205 single-line prompt for Midnight Commander
      PS1="$(__prompt_titlebar "MC - ${USER}@${HOSTNAME%%.*}")"
      #flags: screen venv
      PS1="${PS1}$(__prompt_screen)$(__prompt_venv)"
      #path: [user@host:path]
      PS1="${PS1}${C1}[${C0}\u${C1}@${C0}\h${C1}:${C0}\w${C1}]${C9}"
      #codes: (jobs)exitcode
      PS1="${PS1}$(__prompt_jobs)$(__prompt_exitcode "${EXIT_CODE}")"
      PS1="${PS1}> "
  else
      #MJL20170207 Cowboy's Awesome prompt is the fall-through case
      # http://twitter.com/cowboy/status/150254030654939137
      PS1=""
      #MJL20170204 titlebar: [dir] - user@host:/full/working/dir
      PS1="${PS1}$(__prompt_titlebar "[${HOSTNAME%%.*}:$(basename ${PWD})] - ${USER}@${HOSTNAME%%.*}:${PWD}")"
      # svn: [repo:lastchanged]
      PS1="${PS1}$(__prompt_svn)"
      # git: [branch:flags]
      PS1="${PS1}$(__prompt_git)"
      # hg:  [branch:flags]
      PS1="${PS1}$(__prompt_hg)"
      # path: [user@host:path]
      PS1="${PS1}${C1}[${C0}\u${C1}@${C0}\h${C1}:${C0}\w${C1}]${C9}"
      if [[ -n ${__USE_MONSTER_PROMPT} ]]; then
          PS1="${PS1}$(__prompt_sizes)"
      fi
      PS1="${PS1}\n"

      if [[ -n ${__USE_MONSTER_PROMPT} ]]; then
          PS1="${PS1}$(__prompt_cpu)"
      fi
      #MJL20170205 screen: #
      PS1="${PS1}$(__prompt_screen)"
      #MJL20170207 turn on the command history trace if wanted
      if [[ -n ${__USE_TRACE_PROMPT} ]]; then
          # misc: [cmd#:hist#]
          PS1="${PS1}${C1}[${C0}#\#${C1}:${C0}!\!${C1}]${C9}"
      fi
      # date: [HH:MM]
      PS1="${PS1}${C1}[${C0}$(date +"%H${C1}:${C0}%M${C1}")${C1}]${C9}"
      #MJL20170204 jobs: (#)
      PS1="${PS1}$(__prompt_jobs)"
      #MJL20170205 virtualenv: (name)
      PS1="${PS1}$(__prompt_venv)"
      #MJL20170223 anaconda: (S)
      PS1="${PS1}$(__prompt_conda)"
      # exit code: 127
      PS1="${PS1}$(__prompt_exitcode "${EXIT_CODE}")"
      PS1="${PS1}$(__prompt_ending)"
  fi
}

PROMPT_COMMAND="__prompt_command"
