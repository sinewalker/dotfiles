# Load vagrant "environmental" variables and functions
source ${DOTFILES}/source/50_vagrant.sh

# No Vagrantfile linked yet? Abort!
[[ -f ${VAGRANT_HOME}/Vagrantfile ]] || exit

# Make sure there is a location for the boxes
[[ -d ${VAGRANT_BOXES} ]] || [[ -L ${VARGANT_BOXES} ]] || mkdir -p ${VAGRANT_BOXES}

# Link the boxes location into the vagrant home
#(allows storing boxes outside  the $VAGRANT_HOME)
if [[ ! -L ${VAGRANT_HOME}/boxes ]]; then
    ln -s ${VAGRANT_BOXES} ${VAGRANT_HOME}/boxes
fi
