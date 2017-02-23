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
    FUNCDESC="Lists Python Virtual envs installed to ${VIRTUALENV_BASE}"
    for FILESPEC in ${VIRTUALENV_BASE}/*/bin/activate; do
        basename $(dirname $(dirname ${FILESPEC}))
    done
}

activate() {
    read -d '' FUNCDESC <<EOV
Activtes a Python Virtual env that's in ${VIRTUALENV_BASE}
(will deactivate current Venv if one is active).
EOV
    #If Anaconda is active (conda command is in the PATH) then source the
    # 'anaconda' script instead, per conda practice. Bail after sourcing.
    if is_exe conda; then
        source $(conda info|awk '/root env/{print $4}')/bin/activate $@
        ret=$?
        #why is Anaconda's deactivate so unkind?
        alias deactivate='unalias deactivate; source deactivate'
        return $?
    fi
    [ -z ${1} ] && usage "$FUNCNAME <venv>" $FUNCDESC && return 1
    VENV=${VIRTUALENV_BASE}/${1}
    if [ -f ${VENV}/bin/activate ]; then
        type deactivate &> /dev/null && deactivate
        source ${VENV}/bin/activate
    else
        error "$FUNCNAME: No such Venv: ${1}"
        echo
        echo "Available Python Venvs are:"
        lsvenv|grep -v anaconda
        return 1
    fi
}
alias workon=activate

_activate() {
    COMPREPLY=()
    local cur venvs
    cur="${COMP_WORDS[COMP_CWORD]}"
    venvs="$(lsvenv|grep -v anaconda)"

    COMPREPLY=( $(compgen -W "${venvs}" -- ${cur}) )
    return 0
}
complete -F _activate activate

#### Anaconda

sucuri() {
    FUNCDESC='activate or deactivate Anaconda by inspecting and changing $PATH'
    if [[ $PATH =~ anaconda ]]; then
        [[ $CONDA_DEFAULT_ENV ]] && source deactivate
        export PATH=$(path_remove ${VIRTUALENV_BASE}/anaconda/bin)
        echo "Anaconda: deactivated"
    else
        path_add ${VIRTUALENV_BASE}/anaconda/bin PREPEND
        echo "Anaconda: ACTIVATED 🐍"
    fi
}
