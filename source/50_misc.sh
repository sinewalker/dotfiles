# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

export GREP_OPTIONS='--color=auto'

# Prevent less from clearing the screen while still showing colors.
export LESS=-XR

# Set the terminal's title bar.
function titlebar() {
  echo -n $'\e]0;'"$*"$'\a'
}

#MJL20170212 bash_completion using bash_completion package

# source System-wide completions (if installed)
local BC=/etc/bash_completion
is_osx && BC=/usr/local/etc/bash_completion
[[ -f ${BC} ]] && source ${BC}

# Personal completions (if any)
is_osx && XDG_CONFIG_HOME=${HOME}/.config
[[ -f ${XDG_CONFIG_HOME}/bash_completion ]] && source ${XDG_CONFIG_HOME}/bash_completion

# Disable ansible cows }:]
export ANSIBLE_NOCOWS=1
