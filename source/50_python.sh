# see http://hackercodex.com/guide/python-development-environment-on-mac-osx/

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true

#except when it shouldn't (e.g. to install virtualenv)
#so here's gpip (global pip)
gpip() {
	PIP_REQUIRE_VIRTUALENV="" sudo -H pip "$@"
}

#### virtualenv-wrapper work-alike

#this is where Python Virtual Environments belong
export VIRTUALENV_BASE=${HOME}/lib

mkvenv() {
    FUNCDESC="Makes a Python Virtual env in ${VIRTUALENV_BASE}."
    [ -z ${1} ] && usage "$FUNCNAME <venv> [virtualenv options]" $FUNCDESC \
        && return 1
    VENV=${VIRTUALENV_BASE}/${1}
    [ -d ${VENV} ] && error "$FUNCNAME: Directory exists: ${VENV}" && return 1
    shift
    virtualenv $@ ${VENV}
}

rmvenv() {
    FUNCDESC="Interactively remove a Python Virtual env from ${VIRTUALENV_BASE}"
    [ -z ${1} ] && usage "$FUNCNAME <venv>" $FUNCDESC && return 1
    VENV=${VIRTUALENV_BASE}/${1}
    if [ -f ${VENV}/bin/activate ]; then
        read -r -p "Remove Venv: ${1}? [y/N] " REMOVE
        REMOVE=${REMOVE,,} #to-lower
        if [[ ${REMOVE} =~ ^(yes|y)$ ]]; then
            rm -rf ${VENV}
        else
            echo "$FUNCNAME: aborted"
        fi
    else
        error "$FUNCNAME: No such Venv: ${1}"
        return 1
    fi
}

lsvenv() {
    local FUNCDESC="List Anaconda or Python Virtual Environments.

If Anaconda is active, use conda to show its venvs, otherwise list venvs
installed to ${VIRTUALENV_BASE}"

    if is_exe conda; then
        conda info --envs|awk '/^#/{next}/./{print $1}'
    else
        for FILESPEC in ${VIRTUALENV_BASE}/*/bin/activate; do
            [[ ${FILESPEC} =~ anaconda ]] || \
                basename $(dirname $(dirname ${FILESPEC}))
        done
    fi
}

activate() {
    local FUNCDESC="Activte a Python Virtual env that's in ${VIRTUALENV_BASE}

(will deactivate current Venv if one is active).

If Anaconda is active (conda command is in the PATH) then source the 'anaconda'
script instead, per conda practice. Bail after sourcing."

    local RET=0
    local DOCONDA=0
    if is_exe conda; then
        DOCONDA=1
        source $(conda info|awk '/root env/{print $4}')/bin/activate "${@}"
        RET=${?}
        [[ ${RET} -eq 0 ]] || echo
        #make Anaconda's deactivate less clunky
        [[ ${RET} -eq 0 ]] && \
            alias deactivate='unalias deactivate; source deactivate'
    fi
    if [[ ${DOCONDA} -eq 0 ]]; then
        [ -z "${1}" ] && usage "${FUNCNAME} <venv>" ${FUNCDESC} && return 1
        VENV="${VIRTUALENV_BASE}/${1}"
        if [ -f ${VENV}/bin/activate ]; then
            is_exe deactivate && deactivate
            source ${VENV}/bin/activate
            RET=${?}
        else
            RET=2
        fi
    fi
    if [[ ${RET} -gt 0 ]]; then
        error "${FUNCNAME}: Error activating Venv: ${1}"
        echo
        if [[ ${DOCONDA} -eq 0 ]]; then
            echo "Available Python Venvs are:"
        else
            echo "Available Conda envs are:"
        fi
        lsvenv
    fi
    return ${RET}
}
alias workon=activate

_activate() {
    COMPREPLY=()
    local CUR VENVS
    CUR="${COMP_WORDS[COMP_CWORD]}"
    VENVS="$(lsvenv)"
    COMPREPLY=( $(compgen -W "${VENVS}" -- ${CUR}) )
    return 0
}
complete -F _activate activate

#### Anaconda

sucuri() {
    FUNCDESC='Activate or deactivate Anaconda by inspecting and changing $PATH'
    if [[ ${PATH} =~ anaconda ]]; then
        [[ ${CONDA_DEFAULT_ENV} ]] && source deactivate
        path_remove ${VIRTUALENV_BASE}/anaconda/bin
        is_exe deactivate && unalias deactivate
        echo "Anaconda: deactivated"
    else
        local SNAKE WARN; SNAKE='(S)'; WARN='[!]'
        is_osx && [[ -z ${SSH_TTY} ]] && [[ -z ${WINDOW} ]] && \
            SNAKE="🐍";  WARN="⚠"
        path_add ${VIRTUALENV_BASE}/anaconda/bin PREPEND
        if [[ ${PATH} =~ anaconda ]]; then
            echo "Anaconda: ACTIVATED ${SNAKE}"
        else
            echo "Anaconda: NOT FOUND ${WARN}"
            return 1
        fi
    fi
}
