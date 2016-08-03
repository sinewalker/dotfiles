# see http://hackercodex.com/guide/python-development-environment-on-mac-osx/

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true

gpip() {
	PIP_REQUIRE_VIRTUALENV="" pip "$@"
}

####

export VIRTUALENV_BASE=${HOME}/lib

workon() {
	if [ -d ${VIRTUALENV_BASE}/${1} ]; then
		source ${VIRTUALENV_BASE}/${1}/bin/activate
	else
		echo "No such env: ${1}"
	fi 
}

alias activate=workon

