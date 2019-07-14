# Passing the "source" arg tells it to only define functions, then quit.
source ${DOTFILES}/bin/dotfiles "source"

function dotfiles() {
    local FUNCDESC="Run dotfiles refresh script, then reload.
This causes the Copy, Link and Init step to be run."
    ${DOTFILES}/bin/dotfiles "${@}" && src
}
