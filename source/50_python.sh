# see http://hackercodex.com/guide/python-development-environment-on-mac-osx/

## This Python tool-chain is designed to be loaded by bash when it starts. It
## relies on the following being available:
##
## * virtualenv and pip installed globally, or with pipsi
## * (optional) anaconda installed normally
##
## These functions also use my bash shell meta-functions, which are in
## 10_meta.sh. These should be downloaded and kept together with this file, and
## loaded first. The required functions are:
##
##   usage
##   error
##   is_exe
##   path_add
##   path_remove
##
## The python tools will optionally use these dotfiles environment variables:
##   $LIBRARY - location for library files, defaults to ~/lib

#### Check for a required function and abort if not loaded.
#
# Be sure you've sourced 10_meta.sh first. We cannot automatically source
# sibling files reliably. See http://mywiki.wooledge.org/BashFAQ/028
#
# The best approach to loading all files successfully is:
# for X in path/to/bash_source_files; do source ${X}; done

if ! type -p usage; then
    echo "ERROR: Missing meta-functions. Aborting." >&2
    return 1
fi

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

# pipsi - install script venvs in ~/bin and venvs into a separate dir under lib
export PIPSI_BIN_DIR=${HOME}/bin
export PIPSI_HOME=${LIBRARY-$HOME/lib}/pipsi

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
    virtualenv --always-copy $@ ${VENV}
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
            return 4
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

If Anaconda is active (conda command is in the PATH) then load the 'anaconda'
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
            load ${VENV}/bin/activate
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

freezenv() {
    FUNCDESC='Freeze the active Python Environment pip requirements.

This stores the requirements.txt in the active $VIRTUAL_ENV or $CONDA_PREFIX
directory, overwriting any existing requirements file.'

    if [[ -z ${VIRTUAL_ENV-$CONDA_PREFIX} ]] ; then
        error "$FUNCNAME: no active python or conda venv"
        return 1
    fi
    local VENV_REQS=${VIRTUAL_ENV-$CONDA_PREFIX}/requirements.txt
    echo "Storing PIP package list into ${VENV_REQS}"
    pip freeze > ${VENV_REQS}
}

thawenv() {
    FUNCDESC='Restore a Python Environment and re-install pip requirements from freezenv.

This removes the active virtual environment, then re-creates it and re-installs
from the saved requirements.txt'

    if [[ -z ${VIRTUAL_ENV-$CONDA_PREFIX} ]] ; then
        error "$FUNCNAME: no active python venv"
        return 1
    fi
    if is_exe conda; then
        error "$FUNCNAME:  Annaconda is active. This is not supported, yet. Aborting"
        return 3
    fi

    local VENV_REQS=${VIRTUAL_ENV}/requirements.txt
    local VENV_NAME=$(basename ${VIRTUAL_ENV})
    local PYTHON_VER=$(readlink $(which python))

    if ! [[ -f ${VENV_REQS} ]]; then
        error "${FUNCNAME}:  No frozen requirements found for ${VENV_NAME}, sorry."
        return 2
    fi

    echo "${FUNCNAME}: rebuilding environment: ${VENV_NAME}"
    cp ${VENV_REQS} ${TMP}/${VENV_NAME}-requirements.txt
    rmvenv ${VENV_NAME} || return 0
    mkvenv ${VENV_NAME} --python=${PYTHON_VER}
    activate ${VENV_NAME}
    pip install -r ${TMP}/${VENV_NAME}-requirements.txt
    freezenv
}
#### Anaconda

sucuri() {
    FUNCDESC='Activate or deactivate Anaconda by inspecting and changing $PATH'
    if [[ ${PATH} =~ anaconda ]]; then
        [[ ${CONDA_DEFAULT_ENV} ]] && load deactivate
        path_remove ${LIB-$HOME/lib}/anaconda/bin
        is_exe deactivate && unalias deactivate
        export PIP_REQUIRE_VIRTUALENV=true
        echo "Anaconda: deactivated"
    else
        local SNAKE WARN; SNAKE='(S)'; WARN='[!]'
        ! [[ ${TERM} =~ linux ]] && [[ -z ${SSH_TTY} ]] && [[ -z ${WINDOW} ]] && \
            SNAKE="🐍" && WARN="⚠"
        path_add ${LIB-$HOME/lib}/anaconda/bin PREPEND
        if [[ ${PATH} =~ anaconda ]]; then
            export PIP_REQUIRE_VIRTUALENV=false
            echo "Anaconda: ACTIVATED ${SNAKE}"
        else
            echo "Anaconda: NOT FOUND ${WARN}"
            return 1
        fi
    fi
}

## PYENV

is_exe pyenv && export PYENV_ROOT=~/lib/python/pyenv
is_exe pyenv && eval "$(pyenv init -)"