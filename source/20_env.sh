#show where a command comes from
alias whence='type -a'
complete -F _command whence

#nice commands
alias que=${PLAYER}
alias view=${VIEWER}
alias web=${BROWSER}


#doo eet
alias fuck='sudo $(history -p \!\!)'
alias sammich='sudo $(history -p \!\!)'
alias please=sudo

is_osx || is_exe tracepath && alias traceroute=tracepath
alias tracert=traceroute

#terminals
alias kons="konsole --profile $1 2> /dev/null"
alias kons-show="konsole --list-profiles"
alias root="konsole --profile 'Root Shell'"


#MJL20170213 misc bash controls
# this is to allow incremental forward search on the command line using ^S
# (the test checks that stdin is a terminal. see: http://tldp.org/LDP/abs/html/intandnonint.html#II2TEST)
[[ -t 0 ]] && stty stop 

#MJL20170216 temporary files
export TMP=${HOME}/tmp
export TEMP=${TMP}
export TMPDIR=${TMP}
#MJL20170226 in case ~/tmp is missing...
[[ -d ${TMP} ]] || mkdir ${TMP}
