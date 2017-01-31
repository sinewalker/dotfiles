# Load python and virualenv-related functions.
source $DOTFILES/source/50_python.sh

# Install latest stable virtualenv, install global python modules
# see http://hackercodex.com/guide/python-development-environment-on-mac-osx/
# (which ideas are more widely applicable than just macOS)

gpip install --upgrade pip setuptools wheel virtualenv
gpip install --upgrade Mercurial hg-git
gpip install --upgrade isort ipython
