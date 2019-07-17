    # By default, we want umask to get set. This sets it for non-login shell.
    # Current threshold for system reserved uid/gids is 200
    # You could check uidgid reservation validity in
    # /usr/share/doc/setup-*/uidgid file
    if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
      # Mortal users - Files will be created with these permissions:
      # files 664 -rw-r--r-- (666 minus 002)
      # dirs  775 drwxr-xr-x (777 minus 002)
       umask 002
    else
      # System users - Files will be created with these permissions:
      # files 644 -rw-r--r-- (666 minus 022)
      # dirs  755 drwxr-xr-x (777 minus 022)
       umask 022
    fi



# Always use color output for `ls`
is_linux && alias ls="command ls --color"
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'


# Directory listing
# use GNU ls on macOS, if we have it
is_osx && [[ "$(type -P gls)" ]] && alias ls='gls --color'
alias l='ls -F'
alias la='ls -a'
alias ll='ls -l'
alias lh='ll -h'
alias lk='ll -sk'
alias lt='ll -t'
alias lr='ll -tr'

alias lth='lt -h'
alias lrh='lr -h'
alias ltk='lt -k'
alias lrk='lr -sk'

alias lla='ll -a'
alias lll='ll -ah'
alias llh='lh'
alias llk='ll -ask'

alias ld='CLICOR_FORCE=1 lla | sort -r'
alias d='CLICOLOR_FORCE=1 lla | grep --color=never "^d"'
# optional override with tree
if [[ "$(type -P tree)" ]]; then
  alias ld='tree --dirsfirst -aLpughDFiC 1'
  alias d='ld -d'
fi

# Easier navigation: .., ..., -
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'
alias ..........='cd ../../../../../../../../..'
alias ...........='cd ../../../../../../../../../..'

#this aliases '-' to go back to previous directory
alias -- -='cd -'

# File size
alias fs="stat -f '%z bytes'"
alias df="df -h"

# Recursively delete `.DS_Store` files
alias dsstore="find . -name '*.DS_Store' -type f -ls -delete"
# ... and probes.json files
alias probes="find . -name 'probes.json' -type f -ls -delete"

# Aliasing eachdir like this allows you to use aliases/functions as commands.
alias eachdir=". eachdir"

# Create a new directory and enter it
function md() {
  mkdir -p "$@" && cd "$@"
}

alias wrap='fold -sw ${1:-$COLUMNS}'

function page() {
    local FUNCDESC="View specified file through the system pager, word-wrapped to the console width."
    if  [[ -z ${1} ]]; then
        cat - |fold -s -w ${COLUMNS}|${PAGER}
    else
        cat "${1}"|fold -s -w ${COLUMNS}|${PAGER}
    fi
}

# Bashmarks directory bookmarks
load ${DOTFILES}/vendor/bashmarks/bashmarks.sh

mkdir -p ${DOTFILES}/caches/z
#_Z_NO_PROMPT_COMMAND=1
_Z_DATA=${DOTFILES}/caches/z/z
load ${DOTFILES}/vendor/z/z.sh

#MJL20170214 also use CDPATH. Between above vendor tools and this bash-feature,
#I should be able to quickly move around now.
export CDPATH=.:~:~/Projects:~/Documents:~/net:~/Grid:~/Uploads:~/Downloads:~/dev:~/tmp

alias rd=rmdir
alias rrm='rm -r'

function rmrf() {
    echo "Recursively REMOVE ${@} and ALL CHILD iNODES"; echo
    [[ "$(type -P tree)" ]] && tree -d -L 3 ${@}
    echo -n "ARE YOU CERTAIN (y/N)? "
    read DOIT
    [[ ${DOIT} =~ y ]] && rm -rf ${@} || echo "Aborted."
}

function du-no-traverse() {
    local FUNCDESC="show disk space usage, do not traverse filesystems, works with wildcard"
    [[ -z ${1} ]] && error "Must specify a path" && usage ${FUNCNAME} ${FUNCDESC} && return

    for X in ${1}; do
        mountpoint -q -- ${X} || du -shx ${X}
    done
}

function cpmod {
    local FUNCDESC="Set a file's access mode to that of another"

    [[ -z ${2} ]] && \
        error "Must specify a template and a target" \
        && usage "${FUNCNAME} $<template> <target>" \
                 "Where <template> is a file with mode bits to copy and apply to <target>."\
                 ${FUNCDESC} && return 1

    local STATCMD=stat; is_osx && STATCMD=gstat
    local SRC_MODE=$(exec ${STATCMD} -c "%a" ${1})

    chmod ${SRC_MODE} ${2}
}

function backup {
    local FUNCDESC="Backup and change mode of files before editing (as required by NBR change process). The backup will be named with -dateTtime.bak and have mode changed +w -x to prevent accidental execution."

    [[ -z ${1} ]] && error "No file specified" \
        && usage "${FUNCNAME} <filename> [<filename> ...]" "where <filename> is the file(s) to back up." \
                 ${FUNCDESC} && return 1

	  local THEDATE=$(date +"%Y%m%d")
    local THETIME=$(date +"%H%M%S")
    for N ; do
        NEWNAME="${N}-${THEDATE}T${THETIME}.bak"
        mv ${N} ${NEWNAME}
        cp -p ${NEWNAME} ${N}
        [[ -x ${NEWNAME} ]] && chmod -x ${NEWNAME}
        [[ -w ${NEWNAME} ]] || chmod +w ${NEWNAME}
    done
}

function backout {
    local FUNCDESC="Reverses a backup by putting the backup back to the original name. CAUTION: the mode is NOT reset to what it was before backup, rather the mode of the restored file is set to that of the file it's replacing.  The new file will be renamed '<filename>.keep'"

    local RET=0

    [[ -z ${1} ]] && RET=1 && error "${FUNCNAME}: no file specified"
    [[ -f ${1} ]] || RET=2 && error "${FUNCNAME}: not found: ${1}"

    [[ ${RET} -gt 0 ]] && usage "${FUNCNAME} <filename>" ${FUNCDESC} \
        && return ${RET}

    mv ${1} ${1}.keep
    mv ${1}-*T*.bak ${1}

    cpmod ${1}.keep ${1}
    [[ -x ${1}.keep ]] && chmod -x ${1}.keep
}

function fsync {
    local FUNCDESC="rsync <source> directory to <dest> so that <dest> is just like <source>, no extra files."
    local SRC="${1}"; shift
    local DST="${1}"; shift

    local RET=0
    if [[ -z ${SRC} ]] || [[ -z ${DST} ]]; then
        RET=1
        error "${FUNCNAME}: must specify a sync source and destination."
    fi
    if [[ ! -d ${SRC} ]] || [[ ! -d ${DST} ]]; then
        RET=1
        error "${FUNCNAME}: source and destination must be directories."
    fi

    if [[ ${RET} -gt 0 ]]; then
        usage "${FUNCNAME} <source> <dest>" ${FUNCDESC}
        return ${RET}
    else
        rsync --hard-links --partial --progress --verbose --archive --delete ${SRC}/ ${DST}/
    fi
}
alias pirate=fsync

# The PGP Web Of Trust is broken. Just trust your keys, or not.
alias gpgtrust='gpg --trust-model always'

function gpgd(){
    local FUNCDESC="GPG decript -- all errors to /dev/null "
    gpg -d "${@}" 2>/dev/null
}
