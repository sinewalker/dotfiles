# Files will be created with these permissions:
# files 644 -rw-r--r-- (666 minus 022)
# dirs  755 drwxr-xr-x (777 minus 022)
umask 022

# Always use color output for `ls`
if is_osx; then
  alias ls="command ls -G"
else
  alias ls="command ls --color"
  export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
fi

# Directory listing
# use GNU ls on macOS, if we have it
is_osx && [[ "$(type -P gls)" ]] && alias ls='gls'
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

alias wrap="fold -sw ${1:-$COLUMNS}"

# Bashmarks directory bookmarks
source ${DOTFILES}/vendor/bashmarks/bashmarks.sh

# Fast directory switching

# TODO: the manual page for z needs to be linked or copied somewhere that will
# be picked up by the man command, e.g:
#
# ln -fs ${DOTFILES}/vendor/z/z.1 /usr/local/share/man/man1/
#
# but doing that every time this file is sourced would be silly.
# (and setting $MANPATH overrides /etc/man.conf)

mkdir -p ${DOTFILES}/caches/z
#_Z_NO_PROMPT_COMMAND=1
_Z_DATA=${DOTFILES}/caches/z/z
source ${DOTFILES}/vendor/z/z.sh

#MJL20170214 also use CDPATH. Between above vendor tools and this bash-feature,
#I should be able to quickly move around now.
export CDPATH=.:~:~/Projects:~/Documents:~/net:~/Grid:~/Uploads:~/Downloads:~/dev:~/tmp

[[ -d ~/Work ]] && CDPATH=~/Work:$CDPATH
[[ -d ~/Work/svn ]] && CDPATH=$CDPATH:~/Work/svn
[[ -d ~/Work/lab ]] && CDPATH=$CDPATH:~/Work/lab
[[ -d ~/Work/Projects ]] && CDPATH=~/Work/Projects:$CDPATH
[[ -d ~/Work/Documents ]] && CDPATH=~/Work/Documents:$CDPATH

alias rd=rmdir
alias rrm='rm -r'

function rmrf() {
    echo "Recursively REMOVE $@ and ALL CHILD iNODES"; echo
    [[ "$(type -P tree)" ]] && tree -d -L 3 $@
    echo -n "ARE YOU CERTAIN (y/N)? "
    read DOIT
    [[ $DOIT =~ y ]] && rm -rf $@ || echo "Aborted."
}

function du-no-traverse() {
    $FUNCDESC="show disk space usage, do not traverse filesystems, works with wildcard"
    [[ -z ${1} ]] && error "Must specify a path" && usage $FUNCNAME $FUNCDESC && return

    for X in ${1}; do
        mountpoint -q -- ${X} || du -shx ${X}
    done
}

function cpmod {
    FUNCDESC="Set a file's access mode to that of another"

    [[ -z ${2} ]] && \
        error "Must specify a template and a target" \
        && usage "${FUNCNAME} $<template> <target>" \
                 "Where <template> is a file with mode bits to copy and apply to <target>."\
                 ${FUNCDESC} && return 1

    local statcmd=stat; is_osx && statcmd=gstat
    local src_mode=$(exec ${statcmd} -c "%a" ${1})

    chmod ${src_mode} ${2}
}

function backup {
    FUNCDESC="Backup and change mode of files before editing (as required by NBR change process). The backup will be named with -dateTtime.bak and have mode changed +w -x to prevent accidental execution."

    [[ -z ${1} ]] && error "No file specified" \
        && usage "${FUNCNAME} <filename> [<filename> ...]" "where <filename> is the file(s) to back up." \
                 ${FUNCDESC} && return 1

	  local THEDATE=$(date +"%Y%m%d")
    local THETIME=$(date +"%H%M%S")
    for n ; do
        NEWNAME="${n}-${THEDATE}T${THETIME}.bak"
        mv ${n} ${NEWNAME}
        cp -p ${NEWNAME} ${n}
        [[ -x ${NEWNAME} ]] && chmod -x ${NEWNAME}
        [[ -w ${NEWNAME} ]] || chmod +w ${NEWNAME}
    done
}

function backout {
    FUNCDESC="Reverses a backup by putting the backup back to the original name. CAUTION: the mode is NOT reset to what it was before backup, rather the mode of the restored file is set to that of the file it's replacing.  The new file will be renamed '<filename>.keep'"

    local ret=0

    [[ -z ${1} ]] && ret=1 && error "${FUNCNAME}: no file specified"
    [[ -f ${1} ]] || ret=2 && error "${FUNCNAME}: not found: ${1}"

    [[ ${ret} -gt 0 ]] && usage "${FUNCNAME} <filename>" ${FUNCDESC} \
        && return ${ret}

    mv ${1} ${1}.keep
    mv ${1}-*T*.bak ${1}

    cpmod ${1}.keep ${1}
    [[ -x ${1}.keep ]] && chmod -x ${1}.keep
}
