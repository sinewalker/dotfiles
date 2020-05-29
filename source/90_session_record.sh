#session recording
SESSION_DIRECTORY=~/hax/sessions

function __set_sdir() {
    # function helper (DRY).  It checks for $SESSION_DIRECTORY
    # and uses that if set, or ~/hax/sessions if not.

    SDIR=; [[ -z ${SESSION_DIRECTORY} ]] &&
        SDIR=${HOME}/hax/sessions || SDIR=${SESSION_DIRECTORY}
}

function __list_avail_sessions() {
    # function helper (DRY). lists all the session files
    # in $SDIR. TODO: include the date/time in output

    echo "specify a session name:"
    for x in ${SDIR}/*.trans; do
        basename ${x} |sed 's/.trans//'
    done
}


function __session_completion(){
    # function helper (DRY) for session name completion
    # used by replay/cleanup/pack functions

    COMPREPLY=()

    __set_sdir
    local cur sessions
    cur="${COMP_WORDS[COMP_CWORD]}"
    sessions="$(find ${SDIR}/*.trans|xargs basename|set 's/.trans//')"

    COMPREPLY=( $(compgen -W "${sessions}" -- ${cur}) )
    return 0
}

function dims() {
    local FUNCDESC="print terminal dimensions WIDTH HEIGHT"
    echo ${COLUMNS} ${LINES}
}

function session() {
    local FUNCDESC="Save a shell session transcript with timing files to the specified file pair.

uses script utility.

e.g. session zen12345 will create a zen12345.trans
and zen12345.time in the SESSION_DIRECTORY directory.

can be played back with
    scriptreplay -t zen12345.time zen12345.trans"

    [[ -z ${1} ]] && echo "specify a session name" && return
    __set_sdir

    SESSION=${1}; shift
    [[ -e ${SDIR} ]] || mkdir -p ${SDIR}
    dims > ${SDIR}/${SESSION}.dims
    script -a --timing=${SDIR}/${SESSION}.time ${SDIR}/${SESSION}.trans ${@}
}

function replay() {
    local FUNCDESC="Replay a shell session recorded with the session function.

Just a nice convinience. You can use scriptreplay directly

Optional 2nd+ params are more arguments to scriptreplay,
such as the playback divisor"

    __set_sdir
    [[ -z ${1} ]] && __list_avail_sessions && return

    SESSION=${1}; shift
    DIMSTR=; [[ -e ${SDIR}/${SESSION}.dims ]] &&
        read SCOLS SLINES < ${SDIR}/${SESSION}.dims &&
        DIMSTR="(dimensions: ${SCOLS} cols X ${SLINES} lines) "
    echo "***** REPLAYING SESSION ${SESSION} $DIMSTR*****"
    echo
    scriptreplay --timing=${SDIR}/${SESSION}.time ${SDIR}/${SESSION}.trans ${@}
    echo
    echo "***** FINISHED SESSION REPLAY *****"
}
complete -F __session_completion replay

function pack() {
    local FUNCDESC="Prepairs a session for attaching to a ticket or email.

Requires a player script, assumes it's there and called 'player'"

    __set_sdir
    [[ -z ${1} ]] && __list_avail_sessions && return

    SESSION=${1}
    pushd ${SDIR} > /dev/null
    tar czf ${SDIR}/${SESSION}.tar.gz player ${SESSION}.!(tar.gz)* &&
        echo "packed session '${SESSION}' to ${SDIR}/${SESSION}.tar.gz"
    popd > /dev/null
}
complete -F __session_completion pack

function cleanup() {
    local FUNCDESC="remove session transcript/timing/dimensions files"

    __set_sdir
    [[ -z ${1} ]] && __list_avail_sessions && return

    rm -f ${SDIR}/${1}.!(tar.gz)
}
 complete -F __session_completion cleanup
