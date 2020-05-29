#MJL20170212 bash_completion using bash_completion package

# load System-wide completions (if installed)
local BC=/etc/bash_completion
is_osx && BC=/usr/local/etc/bash_completion
load ${BC}

# Personal completions (if any)
is_osx && XDG_CONFIG_HOME=${HOME}/.config
BC=${XDG_CONFIG_HOME}/bash_completion
load ${BC}

# SSH auto-completion based on entries in known_hosts.
if [[ -e ~/.ssh/known_hosts ]]; then
    complete -o default -W "$(cat ~/.ssh/known_hosts | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')" ssh scp sftp
fi
