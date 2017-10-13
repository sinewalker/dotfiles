#MJL20170212 bash_completion using bash_completion package

# source System-wide completions (if installed)
local BC=/etc/bash_completion
is_osx && BC=/usr/local/etc/bash_completion
[[ -f ${BC} ]] && source ${BC}

# Personal completions (if any)
is_osx && XDG_CONFIG_HOME=${HOME}/.config
BC=${XDG_CONFIG_HOME}/bash_completion
[[ -f ${BC} ]] && source ${BC}
