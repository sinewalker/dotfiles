# see http://hackercodex.com/guide/python-development-environment-on-mac-osx/

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true

gpip() {
	PIP_REQUIRE_VIRTUALENV="" pip "$@"
}

#### virtualenv-wrapper work-alike

#this is where Python Virtual Environments belong
export VIRTUALENV_BASE=${HOME}/lib

error() {
    >&2 echo $@
}

usage() {
    USAGE=${1}; shift
    MESSAGE=$@
    error Usage: ${USAGE}
    echo ${MESSAGE}
}

mkvenv() {
    FUNCDESC="Makes a Python Virtual env in ${VIRTUALENV_BASE}."
    [ -z ${1} ] && usage "$FUNCNAME <venv> [virtualenv options]" $FUNCDESC && return 1
    VENV=${VIRTUALENV_BASE}/${1}
    [ -d ${VENV} ] && error "$FUNCNAME: Directory exists: ${VENV}" && return 1
    shift
    virtualenv $@ ${VENV}
}

rmvenv() {
    FUNCDESC="Interactively removes a Python Virtual env from ${VIRTUALENV_BASE}"
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
    [ -z ${1} ] && usage "$FUNCNAME <venv>" $FUNCDESC && return 1
    VENV=${VIRTUALENV_BASE}/${1}
    if [ -f ${VENV}/bin/activate ]; then
        type deactivate &> /dev/null && deactivate
        source ${VENV}/bin/activate
    else
        error "$FUNCNAME: No such Venv: ${1}"
        echo "Available Python Venvs are:"
        lsvenv
        return 1
    fi
}

alias workon=activate
