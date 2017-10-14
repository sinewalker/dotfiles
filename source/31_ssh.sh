function install_ssh_keys() {
	  [ -z "$1" ] && {
		    echo "Need a host to connect to"
		    return 1
	  }

    # TODO regex for IP address
    #	getent hosts "$1" || {
    #		echo "Cannot resolve $1 via DNS"
    #		return 2
    #	}

    #	cat ~/work/code/svn/ops/sysadmin/ssh_keys/squiz_bris/* | \
	      cat ~/.ssh/*.pub | \
		        ssh "${1}" 'mkdir .ssh >&/dev/null; [ -f .ssh/authorized_keys ] && mv .ssh/authorized_keys .ssh/authorized_keys.$(date +%s); cat > .ssh/authorized_keys; chmod 700 .ssh; chmod 600 .ssh/authorized_keys'
}
export -f install_ssh_keys

export KEYDIR=${HOME}/key
alias keys='ls ${KEYDIR}'

#TODO this doesn't quite work and causes more trouble than it saves if enabled
_ssh-add () {
    COMPREPLY=()
    local CUR KEYS
    CUR="${COMP_WORDS[COMP_CWORD]}"
    KEYS="$(keys|egrep -v '\.pub$')"

    COMPREPLY=( ${KEYDIR}/$(compgen -W "${KEYS}" -- ${CUR}) )
    return 0
}
#complete -F _ssh-add ssh-add

function ssh() {
    local FUNCDESC="Connect to a Secure SHell, disabling any Control Master if needed by 'Dynamic', 'Local', or 'Remote' options."
	  local ARGS=()
	  local DISABLE_CONTROL_PATH=0
	  local PORT_FORWARD_OPTION_RE="^-[DLR]"

	  for ARG
	  do
		    [[ ${ARG} =~ ${PORT_FORWARD_OPTION_RE} ]] && DISABLE_CONTROL_PATH=1
		    ARGS+=("${ARG}")
	  done
	  if ((disable_control_path))
	  then
		    echo "disabling control master..."
		    ARGS=(
			      -o
			      "ControlPath none"
			      "${ARGS[@]}"
		    )
	  fi

	  command ssh "${ARGS[@]}"
}
export -f ssh

ssh-reset() {
    #interactively remove the SSH control-master for specified/matching hosts
    [[ -z ${1} ]] && echo "Specify a host to reset, or ALL for all hosts" && return 1
    [[ ${1} =~ ALL ]] && rm -fvi ~/.ssh/*master* && return 0
    rm -fvi ~/.ssh/*master*${1}*
}

#show SSH control-master files
alias ssh-master='ls -so ~/.ssh/*master*'
alias ssh-ls=ssh-master

#search for a host in SSH config
function ssh-find() {
    for PATTERN in $*; do
        grep -i ${PATTERN} ~/.ssh/config || echo "${PATTERN}: not in config"
    done
}
