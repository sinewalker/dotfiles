# fix SSH connections
bind '"\e[1;5D": backward-word'
bind '"\e[1;5C": forward-word'

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

export SSH_KEYDIR=${HOME}/key/ssh
alias ssh-keys='find -L ${SSH_KEYDIR} -type f'

function ssh-pass() {
    local FUNCDESC="Add specified SSH keys to the SSH Agent, using the matching passphrase from pass(1).

Each key's passphrase is retrieved from the Unix password store (pass), and
given to ssh-add(1) via the SSH_ASKPASS mechanism. This relies upon the keys
having the same path names in both your key directory (${SSH_KEYDIR}), and
your password store."

    if test -z ${1}; then
        error "${FUNCNAME}: no SSH key specified."
        usage "${FUNCNAME} <key> [...]" ${FUNCDESC}
    return 1;
    fi

    test -z ${DISPLAY} && export DISPLAY=dummy

    pushd ${SSH_KEYDIR} > /dev/null

    local KEY
    for KEY in ${@}; do
        export SSH_ASKPASS=$(mktemp -t ssh-askpassXXX)
        cat > ${SSH_ASKPASS} << EOF
#!/bin/sh
pass ${KEY}|head -1
EOF
        chmod +x ${SSH_ASKPASS}
        ssh-add ${SSH_KEYDIR}/${KEY} < /dev/null
        rm ${SSH_ASKPASS}
    done
    unset SSH_ASKPASS

    popd > /dev/null
}
function _ssh-pass() {
    COMPREPLY=()
    local CUR KEYS
    CUR="${COMP_WORDS[COMP_CWORD]}"
    KEYS="$(find -L ${SSH_KEYDIR} -type f|awk -F ${SSH_KEYDIR}/ '{print $2}')"
    COMPREPLY=( $(compgen -W "${KEYS}" -- ${CUR}) )
    return 0
}
complete -F _ssh-pass ssh-pass

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
    FUNCDESC="interactively remove the SSH control-master for specified/matching hosts"

    if [[ -z ${1} ]]; then
        error "${FUNCNAME}: must specify a host to reset, or ALL for all hosts"
        usage "${FUNCNAME} <hostname>|ALL" ${FUNCDESC}
        return 1
    fi

    if [[ ${1} =~ ALL ]]; then
        #rm -fvi ~/.ssh/*master*
        local master
        for master in $(ssh-master); do
            echo -n "${master}: "
            ssh -O exit ${master}
            done
        return  0
    else
        # rm -fvi ~/.ssh/*master*${1}*
        echo -n "${1}: "
        ssh -O exit ${1}
    fi
}
_ssh-reset() {
    COMPREPLY=()
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "$(ssh-master)" -- ${cur}))
    return 0
}
complete -F _ssh-reset ssh-reset

function ssh-master() {
    local FUNCDESC="Show SSH control-masters."

    ls ~/.ssh/*master* |  awk -F @ '{gsub(/:22/, "", $2); print $2 }'
}

function ssh-find() {
    local FUNCDESC="search for a host in SSH config"

    for PATTERN in $*; do
        grep -i ${PATTERN} ~/.ssh/config || echo "${PATTERN}: not in config"
    done
}

#SSH without a ControlMaster
alias ssh-free="ssh -S none"

function ssh-proxy() {
    local FUNCDESC="TODO: THIS DOESN'T WORK. Connect to a host via a proxy"
    local proxy target
    proxy="${1}"; echo proxy: ${proxy}
    target="${2}"; echo target: ${target}
    ssh -S none -o 'ProxyCommand ssh ${proxy} nc %h %p' ${target}
}

# SSHFS

export SSHFS_MOUNT_POINT=~/mnt/sshfs
if [ ! -d ${SSHFS_MOUNT_POINT} ] ; then
    mkdir -p ${SSHFS_MOUNT_POINT}
fi
CDPATH=${SSHFS_MOUNT_POINT}:${CDPATH}

function ssh-mount() {
    local FUNCDESC="Mount a remote server directory with SSHFS.

The files within the <directory> on the <server> will be accessible locally at
${SSHFS_MOUNT_POINT}/<server>, via SSHFS.

If no <directory> is specified, the root directory is assumed.

If <sudo user> is specified, then files will be accessed using that user's
credentials (provided your user is on the sudoers list).

If no <server> is specified, list the current SSH mounts. Use -h or --help for
this help message."

    #TODO The sshfs calls rely on Host User mapping in your SSH config. So that
    #     you can simply go to the server without the user@ part. There SHOULD
    #     be a way to specify the connecting user


    if test -z "${1}"; then
        mount | grep ${SSHFS_MOUNT_POINT}
        return 0
    fi
    if [[ "${1}" =~ --help ]] || [[ "${1}" =~ -h ]]; then
        usage "${FUNCNAME} -h|--help|[<server>] [<directory>] [<sudo user>]" ${FUNCDESC}
        return 0
    fi
    local server mntdir sudoer
    server="${1}"
    mntdir="${2}"
    test -z $mntdir && mntdir=/
    sudoer="${3}"

    if [ ! -d ${SSHFS_MOUNT_POINT}/${server} ]; then
      mkdir -p ${SSHFS_MOUNT_POINT}/${server}
    fi

    if mount|grep ${SSHFS_MOUNT_POINT}/${server} > /dev/null; then
        error ${FUNCNAME}: ${server}: already mounted on ${SSHFS_MOUNT_POINT}/${server}
        return 1
    fi

    if test -z ${sudoer}; then
        sshfs ${server}:${mntdir} ${SSHFS_MOUNT_POINT}/${server}
    else
        sshfs -o sftp_server="sudo -u ${sudoer} /usr/libexec/openssh/sftp-server" \
            ${server}:${mntdir} ${SSHFS_MOUNT_POINT}/${server}
    fi
}

_sshmnts() {
    COMPREPLY=()
    local CUR SSHMNTS
    CUR="${COMP_WORDS[COMP_CWORD]}"
    SSHMNTS="$(ssh-mount|awk -F : '{print $1}')"
    COMPREPLY=( $(compgen -W "${SSHMNTS}" -- ${CUR}) )
    return 0
}
function ssh-umount(){
    FUNCDESC="Unmount an SSHFS server, clean up the mount point.

Specify the server to unmount, this function will determine the mount point
and release the SSH mount if possible.  If umount fails, it will search for
open files to help you close them."

    if test -z ${1}; then
        error "${FUNCNAME}: no server specified."
        usage "${FUNCNAME} <server> [...]" ${FUNCDESC}
        return 1
    fi

    local ret=0
    local server
    for server in ${@}; do
        local umntpoint=${SSHFS_MOUNT_POINT}/${server}
        if ! mount | grep ${umntpoint} > /dev/null; then
            error "${FUNCNAME}: ${server}: not mounted"
            ret=$(( $ret + 1 ))
            continue
        fi

        if umount ${umntpoint} 2> /dev/null; then
            rmdir ${umntpoint}
        else
            error "${FUNCNAME}: ${server}: device busy.  Searching for open files..."
            lsof | awk -v srvmnt=${umntpoint} 'NR==1{print $0}; $0 ~ srvmnt' >&2
            ret=$(( $ret + 2 ))
        fi
    done
    return $ret
}
complete -F _sshmnts ssh-umount

function ssh-clean-mounts(){
    local FUNCDESC="Remove all stale SSHFS mount-point directories."
    local MNT
    for MNT in ${SSHFS_MOUNT_POINT}/*; do
       [[ ${MNT} =~ '*' ]] && continue
       if ! mount | grep ${MNT}; then
           echo "Removing ${MNT} - not mounted"
           rmdir ${MNT}
        fi
    done
}

function ssh-lsof(){
    local FUNCDESC="List all open SSHFS files."

    is_osx && echo "Listing open SSHFS files, please wait..."
    lsof|awk -v srvmnt=${SSHFS_MOUNT_POINT}\
       'NR==1{print $0}; /DS_Store/{next}; $0 ~ srvmnt'
}

alias ssh-ls='ls -l ${SSHFS_MOUNT_POINT}'
alias lsssh=ssh-ls
alias lsshmnt=ssh-mount
alias lsofmnt=ssh-lsof
alias ssh-rmdir=ssh-clean-mounts

function ssh-rmknown-host(){
    local FUNCDESC="Remove a known_hosts entry by pattern (e.g. hostname or IP)

This will remove all lines from your ~/.ssh/known_hosts that match the pattern
you give it.  You may use egrep style regexps.  Useful for warnings about
changed host keys (after you have verified the new key, of course)"

    if [[ -z "${1}" ]] ; then
        error ${FUNCNAME}: must supply a pattern to remove
        usage "${FUNCNAME} <pattern>" ${FUNCDESC}
    fi

    local OLD_HOSTS=~/.ssh/known_hosts.$(date +%s)
    cp ~/.ssh/known_hosts ${OLD_HOSTS}
    egrep -v "${1}" ${OLD_HOSTS} > ~/.ssh/known_hosts
}

slurp_dotfiles() {
    local FUNCDESC="Upload selected dotfiles and bash modules to specified host

The files uploaded are the settings for most common Unix utilities, but not development chains like Python/Node, or OS customisations. These SHOULD be safe to include in any Linux-like system with the GNU tools and a bash shell."

    if [[ -z "{1}" ]]; then
        error "${FUNCNAME}: must specify where to slurp"
        usage "${FUNCNAME} <destination-host>" ${FUNCDESC}
        return 1
    fi

# see https://klaig.blogspot.com/2013/04/make-your-dotfiles-follow-you.html
# I could SCP, but this way is a template for adding into .ssh config
# (if I wanna go that radical).
    tar cz -C${HOME} .bashrc .psqlrc .screenrc .tmux.conf .toprc \
         .dotfiles/link/.bashrc \
         .dotfiles/link/.psqlrc \
         .dotfiles/link/.screenrc \
         .dotfiles/link/.toprc \
         .config/htop/htoprc \
         .dotfiles/bin/dotfiles \
         .dotfiles/misc/loadenv \
         .dotfiles/source/00_dotfiles.sh \
         .dotfiles/source/00_modules.sh \
         .dotfiles/source/10_meta.sh .dotfiles/source/20_completion.sh \
         .dotfiles/source/20_env.sh .dotfiles/source/20_history.sh \
         .dotfiles/source/30_editor.sh .dotfiles/source/30_net.sh \
         .dotfiles/source/30_file.sh \
         .dotfiles/source/99_path.sh  \
         | ssh "${1}" 'tar mxz -C${HOME}'
    ssh "${1}" '[[ -s ${HOME}/etc ]] || ln -s .config ${HOME}/etc'
}
