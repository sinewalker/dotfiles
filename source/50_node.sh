#TODO - work out if there's more to do here. Probably there is a lot of npm
#stuff I could set up

# Node Version Manager and it's managed Nodes go here
export NVM_DIR="${LIB}/nvm"

# Load nvm functions and bash completion
for NVM_MODULE in ${NVM_DIR}/nvm.sh ${NVM_DIR}/bash_completion; do
    load "${NVM_MODULE}"
done

path_add ${NVM_DIR}

export NODE_DIR=${LIB}/node
path_add ${NODE_DIR}/bin
