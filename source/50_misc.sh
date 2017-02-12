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

# SSH auto-completion based on entries in known_hosts.
#if [[ -e ~/.ssh/known_hosts ]]; then
#  complete -o default -W "$(cat ~/.ssh/known_hosts | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')" ssh scp sftp
#fi
#MJL20170212 proper bash_completion using bash_completion package
# System-wide completions
local BC=/etc/bash_completion
is_osx && BC=/usr/local/etc/bash_completion
source ${BC}
# Personal completions (if any)
is_osx && XDG_CONFIG_HOME=${HOME}/.config
[[ -f ${XDG_CONFIG_HOME}/bash_completion ]] && source ${XDG_CONFIG_HOME}/bash_completion

# Disable ansible cows }:]
export ANSIBLE_NOCOWS=1
