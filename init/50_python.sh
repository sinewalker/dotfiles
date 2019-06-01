# Load python and virualenv-related functions.
source ${DOTFILES}/source/10_meta.sh
source ${DOTFILES}/source/50_python.sh

# Make sure there is a virtualenv base scrdirectory
[[ -d ${VIRTUALENV_BASE} ]] || mkdir -p ${VIRTUALENV_BASE}


# Install latest stable virtualenv, install global python modules
# see http://hackercodex.com/guide/python-development-environment-on-mac-osx/
# (which ideas are more widely applicable than just macOS)

e_header "Installing global Python tools"

if ! is_exe pipsi; then
  curl https://raw.githubusercontent.com/mitsuhiko/pipsi/master/get-pipsi.py \
  | python3
fi

local pipsi_pkgs=(\
  pip \
  virtualenv \
  pipsi \
  isort \
  ipython \
  pygments \
)

local pkg
for pkg in ${pipsi_pkgs[*]}; do
  pipsi install --python $(which python3) ${pkg}
  pipsi upgrade ${pkg}
done 

