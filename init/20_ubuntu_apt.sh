# Ubuntu-only stuff. Abort if not Ubuntu.
is_ubuntu || is_raspbian || return 1

# If the old files isn't removed, the duplicate APT alias will break sudo!
local SUDOERS_OLD="/etc/sudoers.d/sudoers-cowboy"; [[ -e "${SUDOERS_OLD}" ]] && sudo rm "${SUDOERS_OLD}"

# Installing this sudoers file makes life easier.
local SUDOERS_FILE="sudoers-dotfiles"
local SUDOERS_SRC=${DOTFILES}/misc/ubuntu/${SUDOERS_FILE}
local SUDOERS_DEST="/etc/sudoers.d/${SUDOERS_FILE}"
if is_ubuntu && [[ ! -e "${SUDOERS_DEST}" || "${SUDOERS_DEST}" -ot "${SUDOERS_SRC}" ]]; then
  cat <<EOM
The sudoers file can be updated to allow "sudo apt-get" to be executed
without asking for a password. You can verify that this worked correctly by
running "sudo -k apt-get". If it doesn't ask for a password, and the output
looks normal, it worked.

THIS SHOULD ONLY BE ATTEMPTED IF YOU ARE LOGGED IN AS ROOT IN ANOTHER SHELL.

This will be skipped if "Y" isn't pressed within the next $prompt_delay seconds.
EOM
  read -N 1 -t ${prompt_delay} -p "Update sudoers file? [y/N] " UPDATE_SUDOERS; echo
  if [[ "${UPDATE_SUDOERS}" =~ [Yy] ]]; then
    e_header "Updating sudoers"
    visudo -cf "${SUDOERS_SRC}" &&
    sudo cp "${SUDOERS_SRC}" "${SUDOERS_DEST}" &&
    sudo chmod 0440 "${SUDOERS_DEST}" &&
    echo "File ${SUDOERS_DEST} updated." ||
    echo "Error updating ${SUDOERS_DEST} file."
  else
    echo "Skipping."
  fi
fi

# Update APT.
e_header "Updating APT"
sudo apt-get -qq update

# Install APT packages.
PACKAGES=(
  ansible
  build-essential
  cowsay
  git-core
  htop
  libssl-dev
  mercurial
  mc
  netcat
  nodejs
  nmap
  pass
  silversearcher-ag
  screen
  screenfetch
  sl
  tmux
  tree
)

PACKAGES=($(setdiff "${PACKAGES[*]}" "$(dpkg --get-selections | grep -v deinstall | awk '{print $1}')"))

if (( ${#PACKAGES[@]} > 0 )); then
  e_header "Installing APT packages: ${PACKAGES[*]}"
  for PACKAGE in "${PACKAGES[@]}"; do
    sudo apt-get -qq install "${PACKAGE}"
  done
fi

# Install Git Extras
if [[ ! "$(type -P git-extras)" ]]; then
  e_header "Installing Git Extras"
  (
    cd $DOTFILES/vendor/git-extras &&
    sudo make install
  )
fi
