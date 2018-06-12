# SUSE-only stuff. Abort if not SUSE.
is_suse || return 1


# Update Zypper.
e_header "Updating Zypper"
cat <<EOM
You will need to enter the root password for installing packages.

If you don't know the root password, just press Enter to skip these.

EOM

e_header "Refreshing Zypper repos"
sudo zypper --quiet refresh

#e_header "Upgrading installed packages"
#sudo zypper --quiet update -y

e_header "Installing SUSE Patterns"
sudo zypper install -y \
     pattern:console \
     pattern:devel_basis pattern:devel_python pattern:devel_python3

# Install RPM packages.
PACKAGES=(
    ansible
    cowsay
    xcowsay
    htop
    nano
    screen
    tmux
    libopenssl-devel
    password-store
    python3-virtualenv
    python-devel
    python3-pip
    git-core
    mercurial
    nmap
    telnet
    tree
    nodejs-common
)

PACKAGES=($(setdiff "${PACKAGES[*]}" "$(rpm -qa |awk --field-separator=-[0-9] '{print $1}')"))

if (( ${#PACKAGES[@]} > 0 )); then
  e_header "Installing RPM packages: ${PACKAGES[*]}"
  for PACKAGE in "${PACKAGES[@]}"; do
    echo "🡒 ${PACKAGE}"
    sudo zypper install -y "${PACKAGE}"
  done
fi

# Install Git Extras
if [[ ! "$(type -P git-extras)" ]] && [[ -d ${DOTFILES}/vendor/git-extras ]]; then
  e_header "Installing Git Extras"
  (
    cd $DOTFILES/vendor/git-extras &&
    sudo make install
  )
fi
