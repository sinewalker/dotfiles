#Opinionated or personality environment settings

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize

alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

#show where a command comes from
alias whence='type -a'
complete -F _command whence

#nice commands
alias que=${PLAYER}
alias view=${VIEWER}
alias web=${BROWSER}


#doo eet
alias gah='sudo $(history -p \!\!)'
alias sammich='sudo $(history -p \!\!)'
alias please=sudo

is_osx || is_exe tracepath && alias traceroute=tracepath
alias tracert=traceroute

function wtfo(){
        FUNCDESC="Look up an abbreviation, including obscene meanings"
        wtf -o ${@}|sed 's/nothing appropriate/nothing inappropriate/'
}

#terminals
alias kons="konsole --profile $1 2> /dev/null"
alias kons-show="konsole --list-profiles"
alias root="konsole --profile 'Root Shell'"

alias x=exit
alias q=exit

#MJL20170213 misc bash controls
# this is to allow incremental forward search on the command line using ^S (the
# test checks that stdin is a terminal. see:
# http://tldp.org/LDP/abs/html/intandnonint.html#II2TEST)
[[ -t 0 ]] && stty stop 

#MJL20170216 temporary files
export TMP=${HOME}/tmp
export TEMP=${TMP}
export TMPDIR=${TMP}
#MJL20170226 in case ~/tmp is missing...
[[ -d ${TMP} ]] || mkdir ${TMP}

#MJL20190614 turn on my bashrc banner loading bells and whistles (see link/.bashrc)
alias bashrc_pretty="touch ~/etc/.bashrc_banner ~/etc/.bashrc_loading ~/etc/.bashrc_lols"
alias bashrc_boring="rm -f ~/etc/.bashrc_*"
alias bashrc_lols=bashrc_pretty
alias bashrc_banner="touch ~/etc/.bashrc_banner ~/etc/.bashrc_loading"
alias bashrc_loading="touch ~/etc/.bashrc_loading"
alias cpcify="bashrc_boring; bashrc_banner; touch ~/etc/.bashrc_amstrad; prompt_amstrad 1"
alias uncpcify="bashrc_boring; prompt_reset"
alias bashrc_debug="touch ~/etc/.bashrc_debug ~/etc/.bashrc_loading"
alias bashrc_undebug="rm -f ~/etc/.bashrc_debug"
alias bashrc_slow="touch ~/etc/.bashrc_slow"
alias bashrc_fast="rm -f ~/etc/.bashrc_slow"