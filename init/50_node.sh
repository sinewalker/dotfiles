#/usr/bin/env bash

source ${DOTFILES}/source/10_meta.sh
source ${DOTFILES}/source/50_node.sh


### Check for node/npm and abort if it's not installed
if ! is_exe node; then
    e_error "Aborting: install Node for your operating system first"
    return 1
fi


### Node Version Manager
export NVM_DIR=${LIBRARY}/nvm
if ! [[ -f ${NVM_DIR}/nvm.sh ]]; then
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
    #undo the "install" of NVM that the script performs: This is in source/50_node.sh
    git checkout -- ${DOTFILES}/link/.bashrc
fi
