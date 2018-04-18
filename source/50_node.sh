#TODO - work out if there's more to do here. Probably there is a lot of npm
#stuff I could set up

export NVM_DIR="${LIBRARY}/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

path_add ${LIBRARY}/nvm
path_add ${LIBRARY}/node/bin
