# Fix the shell path. Goes last of all because $PATH is set all over the place.
# I use this to stick in personal/local paths too


function dedupe_path() {
    local FUNCDESC='Removes duplicates from $PATH variable.
Call for side-effects, no parameters taken.'
    # see http://unix.stackexchange.com/questions/40749/remove-duplicate-path-entries-with-awk-command

    local oldPATH X
    if [ -n "${PATH}" ]; then
        old_PATH="${PATH}:"; PATH=
        while [ -n "${old_PATH}" ]; do
            X=${old_PATH%%:*}       # the first remaining entry
            case ${PATH}: in
                *:"${X}":*) ;;         # already there
                *) PATH=${PATH}:${X} ;;    # not there yet
            esac
            old_PATH=${old_PATH#*:}
        done
        PATH=${PATH#:}
    fi
}
alias path_dedupe=dedupe_path

path_add ~/bin PREPEND
path_add ~/Work/bin
path_add .

dedupe_path
export PATH
alias path='echo ${PATH}'
