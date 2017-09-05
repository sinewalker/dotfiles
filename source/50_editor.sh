################
# Editing

#We should have *something* for a default, I guess.  So 1970s
export EDITOR=vi
is_exe vim && EDITOR=vim

#Nano is like 1980s home computer editors, much friendlier than vi(m) and comes
#pre-installed usually
is_exe nano && EDITOR=nano

#But even better is 1990's style mcedit if you have it.
#Midnight Commander should be installed everywhere with this repo anyway
is_exe mcedit && EDITOR=mcedit

## WIMP text editors
if [[ ! "$SSH_TTY" ]]; then

    #Or, if we're on a 21st century computer, let's default to using Atom
    is_exe atom && EDITOR=atom

    #Or, if we have MS VS-code (and it's on the PATH), then that's better than atom
    is_exe code && EDITOR=code

    #My third-favorite editor is Kate for KDE. Use that over the others, if we have it.
    is_exe kate && EDITOR=kate

fi

#editing shortcuts
alias edit=${EDITOR}
alias ed=edit   #sorry /bin/ed, you're ancient history
alias e=edit

#if 'mc' can launch the whole Midnight Commander, why not these too?
if is_exe mcedit; then
    alias mce=mcedit
    alias mcv=mcview
    alias mcd=mcdiff
    alias mdiff=mcdiff
fi

########
# Emacs

# note: if you're primarily driving emacs from a shell instead of the other way
#       around, then you're Doing It Wrong, look at eshell. But it's sometimes
#       handy to be able to call to a running emacs from a terminal window, for
#       a few things: edit some files, diff/merge, or start dired

if is_exe emacsclient; then
    # various synonyms for emacsclient:
    alias ecedit='emacsclient -n'
    alias ec=ecedit
    alias em=ecedit

    # emacs 'commands'
    alias eedit='emacsclient -n'
    alias eed=eedit
    alias eexec='emacsclient -n -e -a $(which emacs)'
    alias ebatch='emacs --batch -e '
    alias elisp='emacs --script'

    alias pokemacs='pkill -SIGUSR2 emacs'

    function ediff() {
        local FUNCDESC="Compare two or three files with Emacs Diff"
        if [[ $# = 2 ]]; then
            emacsclient -n -e -a $(which emacs) '(ediff-files "'${1}'" "'${2}'")'  > /dev/null
        elif [[ $# = 3 ]]; then
            emacsclient -n -e -a $(which emacs) '(ediff-files3 "'${1}'" "'${2}'" "'${3}'")' > /dev/null
        else
            error "$FUNCNAME: Must specify 2 or 3 files to compare."
            usage "$FUNCNAME <fileA> <fileB> [<fileC>]" $FUNCDESC
            return 1
        fi
    }

    function emerge() {
        local FUNCDESC="Merge two specified files into a third with Emacs Merge"
        if [[ $# = 3 ]]; then
            emacsclient -n -e -a $(which emacs) '(emerge-files nil "'${1}'" "'${2}'" "'${3}'")' > /dev/null
        else
            error "$FUNCNAME: wrong number of arguments."
            usage "$FUNCNAME: <fileA> <fileB> <merge-output>" $FUNCDESC
            return 1
        fi
    }

    function edir() {
        local FUNCDESC="Open specified DIR (or CWD) in emacs' dired"
        DIR=${1}
        [[ -z ${DIR} ]] && DIR=${PWD}
        [[ -d ${DIR} ]] && emacsclient -n -e -a $(which emacs) '(dired "'${DIR}'")' > /dev/null
    }
fi

################
# Viewers

########
# generic

#mcview is better than vim's read-only mode (if we have it), because it has a
#hex mode and sane keys/commands from the 1990s, not the 1970s
is_exe mcview && alias view=mcview
alias v=view

#this is stupidly named in Linux/FreeDesktop:
is_osx || alias open=xdg-open
is_exe open && alias o=open

#other viewer vars
export PLAYER=play
is_exe vlcs && PLAYER=vlcs
is_exe clementine && PLAYER=clementine
export VIEWER=display
export BROWSER=firefox

# configure PAGER/LESS
# stolen from http://merlinmoncure.blogspot.com.au/2007/10/better-psql-with-less.html
export PAGER=less

# -i ignore case in search
# -M long prompt ?
# -S chop long lines
# -x4 tab stop at multiples of 4
# -F quit if one screen
# -X no (de)initialisation (avoids clearing screen etc)
# -R handle colours nicely
export LESS="-iMSx4 -FXR"

########
# osx
if is_osx; then
    PLAYER=vlc
    VIEWER=open
    BROWSER=open
fi

########
# KDE

if is_exe khelpcenter; then
    alias kman='khelpcenter man:/${@} 2> /dev/null'
    alias kinfo='khelpcenter info:/${@} 2> /dev/null'
    alias khelp='khelpcenter help:/${@} 2> /dev/null'
fi
