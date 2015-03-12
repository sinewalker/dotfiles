# see http://hackercodex.com/guide/python-development-environment-on-mac-osx/

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true

gpip() {
	PIP_REQUIRE_VIRTUALENV="" pip "$@"
}

