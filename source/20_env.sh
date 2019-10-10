#Opinionated or personality environment settings

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize

alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias rgrep="egrep -iR"

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

# Super User

function super(){
        local FUNCDESC="Switch to a user and load your own bash environment.

If no user is specified, become 'root'.

Requires misc/loadenv as the replacement bash init file.

Note: because this uses an alternate bash init-file, it will not load that
users's environment.  Use the 'brc' or 'bp' aliases to load .bashrc or
.bash_profile"

#BUGS   if user's restricted (e.g. apache) then you get errors about
#       .bash_history

        local USER_ARG=""
        local LOADER=${DOTFILES}/misc/loadenv

        if [[ ! -f ${LOADER} ]]; then
            error "${FUNCNAME}: could not find super bootstrap: ${LOADER}"
            error Aborting
            usage "${FUNCNAME} [<user>]" ${FUNCDESC}
            return 1
        fi

        [[ ! -z "${1}" ]] && USER_ARG="-u ${1}"

        pushd ${HOME};
        chmod o+rx ${HOME}
        sudo ${USER_ARG} bash --init-file ${LOADER}
        cpmod /root ${HOME}
        sudo rm -f /tmp/${USER}.* #$> /dev/null
        popd
}
_super() {
    COMPREPLY=()
    local CUR USERS
    CUR="${COMP_WORDS[COMP_CWORD]}"
    USERS="$(awk -F : '{print $1}' /etc/passwd)"
    COMPREPLY=( $(compgen -W "${USERS}" -- ${CUR}) )
    return 0
}
complete -F _super super

alias bp='load ~/.bash_profile'
alias brc='load ~/.bashrc'
alias burp='load ~/.bash_profile ~/.bashrc'
alias brp=burp

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
