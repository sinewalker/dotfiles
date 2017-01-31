# Load python and virualenv-related functions.
source $DOTFILES/source/50_python.sh

# Install latest stable virtualenv, install global python modules
# see http://hackercodex.com/guide/python-development-environment-on-mac-osx/
# (which ideas are more widely applicable than just macOS)

#TODO BUG: permissions error on Linux (because it tries to install to global locations)
#          it may be better to do global installs using the OS package manager
gpip install --upgrade pip setuptools wheel virtualenv
gpip install --upgrade Mercurial hg-git
gpip install --upgrade isort ipython
