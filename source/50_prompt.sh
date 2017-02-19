# My awesome bash prompt
#
# Copyright (c) 2012,2017 "Cowboy" Ben Alman, Michael Lockhart [MJL]
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

if [[ ! "${prompt_colors[@]}" ]]; then
    prompt_colors=(
        "36;1" # information color
        "36" # bracket color
        "31;7" # error color
        "37;1" #paren colour
        "35" # jobs colour
        "33;1" #venv colour
        "44;33;1" #screen window colour
  )

  if [[ "$SSH_TTY" ]]; then
    # connected via ssh
      prompt_colors[0]="32;1"
      prompt_colors[1]="32"
  elif [[ "$USER" == "root" ]]; then
    # logged in as root
      prompt_colors[0]="31;1"
      prompt_colors[1]="31"
  fi
fi

# Inside a prompt function, run this alias to setup local $c0-$c9 color vars.
alias prompt_getcolors='prompt_colors[9]=; local i; for i in ${!prompt_colors[@]}; do local c$i="\[\e[0;${prompt_colors[$i]}m\]"; done'

# Exit code of previous command.
function prompt_exitcode() {
  prompt_getcolors
  [[ $1 != 0 ]] && echo "$c2 $1 $c9"
}

#MJL20170204 title bar
#see https://goo.gl/6E8a2u (SO: "Using git-prompt.sh PROMPT_COMMAND to change
# Cygwin Title Bar")
function prompt_titlebar() {
        case $TERM in
            *xterm*|ansi|rxvt)
                printf "\033]0;%s\007" "$*"
                ;;
        esac
}

#MJL20170204 jobs
function prompt_jobs() {
    prompt_getcolors
    local JOBCOUNT
    JOBCOUNT=$(jobs -r|awk 'END{print NR}')
    [[ ${JOBCOUNT} > 0 ]] && echo "$c3($c4${JOBCOUNT}$c3)$c9"
}

#MJL20170205 python virtual environment name
function prompt_venv() {
    prompt_getcolors
    [[ -z $VIRTUAL_ENV ]] || echo "$c3($c5$(basename $VIRTUAL_ENV)$c3)$c9"
}

#MJL20170205 screen window number
function prompt_screen() {
    prompt_getcolors
    [[ -z $WINDOW ]] || echo "$c6 $WINDOW $c9"
}

# Git status.
function prompt_git() {
  prompt_getcolors
  local status output flags branch
  status="$(git status 2>/dev/null)"
  [[ $? != 0 ]] && return;
  output="$(echo "$status" | awk '/# Initial commit/ {print "(init)"}')"
  [[ "$output" ]] || output="$(echo "$status" | awk '/# On branch/ {print $4}')"
  [[ "$output" ]] || output="$(git branch | perl -ne '/^\* \(detached from (.*)\)$/ ? print "($1)" : /^\* (.*)/ && print $1')"
  flags="$(
    echo "$status" | awk 'BEGIN {r=""} \
        /^(# )?Changes to be committed:$/        {r=r "+"}\
        /^(# )?Changes not staged for commit:$/  {r=r "!"}\
        /^(# )?Untracked files:$/                {r=r "?"}\
      END {print r}'
  )"
  if [[ "$flags" ]]; then
    output="$output$c1:$c0$flags"
  fi
  echo "$c1[$c0$output$c1]$c9"
}

# hg status.
function prompt_hg() {
  prompt_getcolors
  local summary output bookmark flags
  summary="$(hg summary 2>/dev/null)"
  [[ $? != 0 ]] && return;
  output="$(echo "$summary" | awk '/branch:/ {print $2}')"
  bookmark="$(echo "$summary" | awk '/bookmarks:/ {print $2}')"
  flags="$(
    echo "$summary" | awk 'BEGIN {r="";a=""} \
      /(modified)/     {r= "+"}\
      /(unknown)/      {a= "?"}\
      END {print r a}'
  )"
  output="$output:$bookmark"
  if [[ "$flags" ]]; then
    output="$output$c1:$c0$flags"
  fi
  echo "$c1[$c0$output$c1]$c9"
}

# SVN info.
function prompt_svn() {
  prompt_getcolors
  local info="$(svn info . 2> /dev/null)"
  local last current
  if [[ "$info" ]]; then
    last="$(echo "$info" | awk '/Last Changed Rev:/ {print $4}')"
    current="$(echo "$info" | awk '/Revision:/ {print $2}')"
    echo "$c1[$c0$last$c1:$c0$current$c1]$c9"
  fi
}

#MJL20170218 files and size count (from "monster prompt" in my ancient dotfiles)
function prompt_sizes() {
    #TODO: formatting/colouring and testing.
    is_osx && alias llssi='gls --si -sl' || alias llssi='ls --si -sl'
    llssi|awk '/total/{TOTAL=$2} /(.*) (-.*)/{FILES=FILES+1} END{print FILES " files, " TOTAL}'
    unalias lsssi
}

#MJL20170218 CPU load and uptime (from monster prompt -- DAFT)
function prompt_cpu() {
    #TODO: these are for Linux only
    $(cat /proc/loadavg)
    #TODO: and surely this date manipulation can be done by an existing tool,
    #      rather than this hand-crufted mess?
    $(temp=$(cat /proc/uptime) && upSec=${temp%%.*} ; let secs=$((${upSec}%60)) ; let mins=$((${upSec}/60%60)) ; let hours=$((${upSec}/3600%24)) ; let days=$((${upSec}/86400)) ; if [ ${days} -ne 0 ]; then echo -n ${days}d; fi ; echo -n ${hours}h${mins}m)

}
#MJL20170205 toggle using a simple prompt
# If an argument is supplied, force it to simple
function prompt_simple() {
    if [[ -z $simple_prompt || -n $1 ]]; then
        export simple_prompt=1
    else
        unset simple_prompt
    fi
}
alias simple_prompt=prompt_simple
alias awesome_prompt=prompt_simple

#MJL20170207 toggle command history trace
# sometimes this can be useful
function prompt_trace() {
    if [[ -z $trace_prompt || -n $1 ]]; then
        export trace_prompt=1
    else
        unset trace_prompt
    fi
}
alias trace_prompt=prompt_trace

# Maintain a per-execution call stack.
prompt_stack=()
trap 'prompt_stack=("${prompt_stack[@]}" "$BASH_COMMAND")' DEBUG

function prompt_command() {
  local exit_code=$?
  # If the first command in the stack is prompt_command, no command was run.
  # Set exit_code to 0 and reset the stack.
  [[ "${prompt_stack[0]}" == "prompt_command" ]] && exit_code=0
  prompt_stack=()

  # Manually load z here, after $? is checked, to keep $? from being clobbered.
  [[ "$(type -t _z)" ]] && _z --add "$(pwd -P 2>/dev/null)" 2>/dev/null

  #MJL20170207 disable the awesome prompt for basic environments
  [[ -n $ANDROID_ROOT ]] && prompt_simple 1

  # While the simple_prompt environment var is set, disable the awesome prompt.
  [[ "$simple_prompt" ]] && PS1='[\u@\h:\w]\$ ' && return

  prompt_getcolors
   if [[ -n $MC_SID ]]; then
      #MJL20170205 single-line prompt for Midnight Commander
      PS1="$(prompt_titlebar "MC - $USER@${HOSTNAME%%.*}")"
      #flags: screen venv
      PS1="$PS1$(prompt_screen)$(prompt_venv)"
      #path: [user@host:path]
      PS1="$PS1$c1[$c0\u$c1@$c0\h$c1:$c0\w$c1]$c9"
      #codes: (jobs)exitcode
      PS1="$PS1$(prompt_jobs)$(prompt_exitcode "$exit_code")"
      PS1="$PS1> "
  else
      #MJL20170207 Cowboy's Awesome prompt is the fall-through case
      # http://twitter.com/cowboy/status/150254030654939137
      PS1="\n"
      #MJL20170204 titlebar: [dir] - user@host:/full/working/dir
      PS1="$PS1$(prompt_titlebar "[${HOSTNAME%%.*}:$(basename $PWD)] - $USER@${HOSTNAME%%.*}:$PWD")"
      # svn: [repo:lastchanged]
      PS1="$PS1$(prompt_svn)"
      # git: [branch:flags]
      PS1="$PS1$(prompt_git)"
      # hg:  [branch:flags]
      PS1="$PS1$(prompt_hg)"
      # path: [user@host:path]
      PS1="$PS1$c1[$c0\u$c1@$c0\h$c1:$c0\w$c1]$c9"
      PS1="$PS1\n"

      #MJL20170205 screen: #
      PS1="$PS1$(prompt_screen)"
      #MJL20170207 turn on the command history trace if wanted
      if [[ -n $trace_prompt ]]; then
          # misc: [cmd#:hist#]
          PS1="$PS1$c1[$c0#\#$c1:$c0!\!$c1]$c9"
      fi
      # date: [HH:MM]
      PS1="$PS1$c1[$c0$(date +"%H$c1:$c0%M$c1")$c1]$c9"
      #MJL20170204 jobs: (#)
      PS1="$PS1$(prompt_jobs)"
      #MJL20170205 virtualenv: (name)
      PS1="$PS1$(prompt_venv)"
      # exit code: 127
      PS1="$PS1$(prompt_exitcode "$exit_code")"
      PS1="$PS1\$ "
  fi
}

PROMPT_COMMAND="prompt_command"
