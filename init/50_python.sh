# Load python and virualenv-related functions.
source ${DOTFILES}/source/10_meta.sh
source ${DOTFILES}/source/50_python.sh

is_exe pyenv || curl https://pyenv.run | bash

