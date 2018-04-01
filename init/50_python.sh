# Load python and virualenv-related functions.
source ${DOTFILES}/source/50_python.sh

# Make sure there is a virtualenv base scrdirectory
[[ -d ${VIRTUALENV_BASE} ]] || mkdir -p ${VIRTUALENV_BASE}


# Install latest stable virtualenv, install global python modules
# see http://hackercodex.com/guide/python-development-environment-on-mac-osx/
# (which ideas are more widely applicable than just macOS)

e_header "Installing system-wide Python tools"
cat <<EOM
You may need to enter a password for root access (either your own or
the system root password) depending on the system's sudo configuration.

If you don't know the root password, just press Enter to skip these.

EOM
gpip install --upgrade pip setuptools wheel virtualenv
gpip install --upgrade isort ipython
if type -p hg > /dev/null; then
    gpip install --upgrade hg-git
fi
