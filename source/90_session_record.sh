#session recording
SESSION_DIRECTORY=~/hax/sessions

function _set_sdir() {
    # function helper (DRY).  It checks for $SESSION_DIRECTORY
    # and uses that if set, or ~/hax/sessions if not.

    SDIR=; [[ -z ${SESSION_DIRECTORY} ]] &&
        SDIR=${HOME}/hax/sessions || SDIR=${SESSION_DIRECTORY}
}

function _list_avail_sessions() {
    # function helper (DRY). lists all the session files
    # in $SDIR. TODO: include the date/time in output

    echo "specify a session name:"
    for x in ${SDIR}/*.trans; do
        basename ${x} |sed 's/.trans//'
    done
}

function session() {
    #runs script, saving transcript and timing files to the specified
    #file pair.  e.g. session zen12345 will create a zen12345.trans
    #and zen12345.time in the ${SESSION_DIRECTORY} directory.
    #
    # can be played back with
    # scriptreplay -t zen12345.time zen12345.trans
    [[ -z ${1} ]] && echo "specify a session name" && return
    _set_sdir

    SESSION=${1}; shift
    [[ -e ${SDIR} ]] || mkdir -p ${SDIR}
    echo ${COLUMNS} ${LINES} > ${SDIR}/${SESSION}.dims
    script -a --timing=${SDIR}/${SESSION}.time ${SDIR}/${SESSION}.trans ${@}
}

function replay() {
    #Replays a session recorded with the session function
    #Just a nice convinience. You can use scriptreplay directly
    #
    # Optional 2nd+ params are more arguments to scriptreplay,
    # such as the playback divisor
    #
    _set_sdir
    [[ -z ${1} ]] && _list_avail_sessions && return

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

function pack() {
    #Prepairs a session for attaching to a ticket. Requires a player
    #script, assumes it's there and called "player"
    _set_sdir
    [[ -z ${1} ]] && _list_avail_sessions && return

    SESSION=${1}
    pushd ${SDIR} > /dev/null
    tar czf ${SDIR}/${SESSION}.tar.gz player ${SESSION}.!(tar.gz)* &&
        echo "packed session '${SESSION}' to ${SDIR}/${SESSION}.tar.gz"
    popd > /dev/null
}

function cleanup() {
    #remove session transcript/timing/dimensions files

    _set_sdir
    [[ -z ${1} ]] && _list_avail_sessions && return

    rm -f ${SDIR}/${1}.!(tar.gz)
}
