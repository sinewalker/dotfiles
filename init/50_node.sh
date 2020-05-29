#!/usr/bin/env bash

source ${DOTFILES}/source/10_meta.sh
source ${DOTFILES}/source/50_node.sh


### Check for node/npm and abort if it's not installed
if ! is_exe node && ! is_exe nodejs; then
    e_error "Aborting: install Node for your operating system first"
    return 1
fi


### Node Version Manager

# NVM_DIR is defined in source/50_node.sh.  Also that source module arranges to
# have NVM and the node binaries in the $PATH.

if ! [[ -f ${NVM_DIR}/nvm.sh ]]; then
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
    #undo the "install" of NVM that the script performs: This is in source/50_node.sh
    git checkout -- ${DOTFILES}/link/.bashrc
fi

[ -d ${NODE_DIR}/bin ] || mkdir -p ${NODE_DIR}/bin
npm config set prefix ${NODE_DIR}
