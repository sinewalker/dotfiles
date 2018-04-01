# see http://hackercodex.com/guide/python-development-environment-on-mac-osx/

## This Python tool-chain is designed to be sourced by bash when it starts, from
## my dotfiles. It cannot yet be sourced without dotfiles. It relies on the following
## being available:
##
## virtualenv and pip installed globally
## (optional) anaconda installed normally
##
## dotfiles bash shell meta-functions:
##   usage
##   error
##   is_exe
##   path_add
##   path_remove
##
## dotfiles environment variables:
##   $LIB - location for library files.  Defaults to ~/lib

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true

#except when it shouldn't (e.g. to install virtualenv)
#so here's gpip (global pip)
gpip() {
    local FUNCDESC="Install python packages globally"
	  PIP_REQUIRE_VIRTUALENV="" sudo -H pip "${@}"
}


# hack in my 'hax' environment.
# This assumes a python venv called 'hax' with ipython, as well as ~/hax
alias hax='activate hax; cd ~/hax; ipython'

#### virtualenv-wrapper work-alike

#this is where Python Virtual Environments belong
export VIRTUALENV_BASE=${LIBRARY-$HOME/lib}/python
[[ -d ${VIRTUALENV_BASE} ]] || mkdir -p ${VIRTUALENV_BASE}

mkvenv() {
    local FUNCDESC="Makes a Python Virtual env in ${VIRTUALENV_BASE}."
    if test -z ${1}; then
        usage "${FUNCNAME} <venv> [virtualenv options]" ${FUNCDESC}
        return 1
    fi
    if is_exe conda; then
        error "${FUNCNAME}: Warning! Anaconda is active."
        error "This wrapper will use conda to create ${1}, but it is only very basic."
        conda create -n "${1}"
        return ${?}
    fi

    VENV=${VIRTUALENV_BASE}/${1}
    if test -d ${VENV}; then
        error "${FUNCNAME}: Directory exists: ${VENV}"
        return 2
    fi

    shift
    virtualenv $@ ${VENV}
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

_venvs() {
    COMPREPLY=()
    local CUR VENVS
    CUR="${COMP_WORDS[COMP_CWORD]}"
    VENVS="$(lsvenv)"
    COMPREPLY=( $(compgen -W "${VENVS}" -- ${CUR}) )
    return 0
}

rmvenv() {
    local FUNCDESC="Interactively remove a Python Virtual env from ${VIRTUALENV_BASE}"
    if test -z ${1}; then
        usage "${FUNCNAME} <venv>" ${FUNCDESC}
        return 1
    fi
    if is_exe conda; then
        error "${FUNCNAME}: Warning! Anaconda is active."
        error "Consider using 'conda remove -all -n ${1}' instead."
        error "Aborting."
        return 3
    fi
    VENV=${VIRTUALENV_BASE}/${1}
    if test -f ${VENV}/bin/activate; then
        read -r -p "Remove Venv: ${1}? [y/N] " REMOVE
        REMOVE=${REMOVE,,} #to-lower
        if [[ ${REMOVE} =~ ^(yes|y)$ ]]; then
            rm -rf ${VENV}
        else
            echo "${FUNCNAME}: aborted"
        fi
    else
        error "${FUNCNAME}: No such Venv: ${1}"
        return 2
    fi
}
complete -F _venvs rmvenv

activate() {
    local FUNCDESC="Activte a Python Virtual env that's in ${VIRTUALENV_BASE}

(will deactivate current Venv if one is active).

If Anaconda is active (conda command is in the PATH) then source the 'anaconda'
script instead, per conda practice. Bail after sourcing."

    local RET=0
    local DOCONDA=0
    if is_exe conda; then
        DOCONDA=1
        if source $(conda info|awk '/root env/{print $4}')/bin/activate "${@}"; then
            #make Anaconda's deactivate less clunky
            alias deactivate='unalias deactivate; source deactivate'
        else
            RET=1
            echo
        fi
    fi
    if [[ ${DOCONDA} -eq 0 ]]; then
        if test -z "${1}"; then
            usage "${FUNCNAME} <venv>" ${FUNCDESC}
            return 1
        fi
        VENV="${VIRTUALENV_BASE}/${1}"
        if test -f ${VENV}/bin/activate; then
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
complete -F _venvs activate
alias workon=activate


#### Anaconda

sucuri() {
    FUNCDESC='Activate or deactivate Anaconda by inspecting and changing $PATH'
    if [[ ${PATH} =~ anaconda ]]; then
        [[ ${CONDA_DEFAULT_ENV} ]] && source deactivate
        path_remove ${LIB-$HOME/lib}/anaconda/bin
        is_exe deactivate && unalias deactivate
        echo "Anaconda: deactivated"
    else
        local SNAKE WARN; SNAKE='(S)'; WARN='[!]'
        ! [[ ${TERM} =~ linux ]] && [[ -z ${SSH_TTY} ]] && [[ -z ${WINDOW} ]] && \
            SNAKE="🐍" && WARN="⚠"
        path_add ${LIB-$HOME/lib}/anaconda/bin PREPEND
        if [[ ${PATH} =~ anaconda ]]; then
            echo "Anaconda: ACTIVATED ${SNAKE}"
        else
            echo "Anaconda: NOT FOUND ${WARN}"
            return 1
        fi
    fi
}
