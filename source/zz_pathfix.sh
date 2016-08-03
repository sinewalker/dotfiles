# Fix the shell path. Goes last of all because $PATH is set all over the place.
# I use this to stick in personal/local paths too


function dedupe_path() {
    #removes duplicates from $PATH variable
    # see http://unix.stackexchange.com/questions/40749/remove-duplicate-path-entries-with-awk-command

    if [ -n "$PATH" ]; then
        old_PATH=${PATH}:; PATH=
        while [ -n "$old_PATH" ]; do
            x=${old_PATH%%:*}       # the first remaining entry
            case $PATH: in
                *:"$x":*) ;;         # already there
                *) PATH=${PATH}:${x} ;;    # not there yet
            esac
            old_PATH=${old_PATH#*:}
        done
        PATH=${PATH#:}
        unset old_PATH x
    fi
}

path_add() {
    #adds to path ONLY if dir exists AND not already in $PATH
    #if $2 is specifed, PREPEND rather than Append
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        if [ -z $2 ]; then
            PATH="${PATH:+"$PATH:"}$1"
        else
            PATH="${1}:${PATH}"
        fi
    fi
}


#path_add ~/lib/anaconda/bin 1
path_add ~/Squiz/bin
path_add .

dedupe_path
export PATH
