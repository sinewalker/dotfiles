# OSX-only stuff. Abort if not OSX.
is_osx || return 1

# Exit if Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Brew recipes need Homebrew to install." && return 1

# Homebrew recipes
recipes=(
  ansible
  bash
  cowsay
  git
  git-extras
  htop-osx
  hub
  id3tool
  lesspipe
  man2html
  mercurial
  nmap
  sl
  ssh-copy-id
  the_silver_searcher
  tree
  #MJL20170131 more by me
  apm-bash-completion
  bash-completion
  bash-git-prompt
  colordiff
  coreutils
  flac
  gawk
  goaccess
  gnu-sed
  gnuplot
  graphviz
  guile
  homebrew/emacs/tern
  ipcalc
  ispell
  jq
  lame
  libvorbis
  midnight-commander
  opencore-amr
  openssl
  pcre
  proctools
  pwgen
  python
  python3
  qcachegrind
  rdesktop
  socat
  stunnel
  tidy-html5
  tinyproxy
  tmux
  watch
  wget
  wireshark
  xmlstarlet
  xz
)

brew_install_recipes

#MJL20170216 Special recipes

#MJL20170216 SOX will support libvorbis, but not by default in Homebrew
# which is a shame since it's my go-to codec
brew_install_special_recipe sox --with-libvorbis --with-flac --with-lame --with-opencore-amr

# Misc cleanup!

# This is where brew stores its binary symlinks
local binroot="$(brew --config | awk '/HOMEBREW_PREFIX/ {print $2}')"/bin

# htop
if [[ "$(type -P $binroot/htop)" ]] && [[ "$(stat -L -f "%Su:%Sg" "$binroot/htop")" != "root:wheel" || ! "$(($(stat -L -f "%DMp" "$binroot/htop") & 4))" ]]; then
  e_header "Updating htop permissions"
  sudo chown root:wheel "$binroot/htop"
  sudo chmod u+s "$binroot/htop"
fi

# bash
if [[ "$(type -P $binroot/bash)" && "$(cat /etc/shells | grep -q "$binroot/bash")" ]]; then
  e_header "Adding $binroot/bash to the list of acceptable shells"
  echo "$binroot/bash" | sudo tee -a /etc/shells >/dev/null
fi
if [[ "$(dscl . -read ~ UserShell | awk '{print $2}')" != "$binroot/bash" ]]; then
  e_header "Making $binroot/bash your default shell"
  sudo chsh -s "$binroot/bash" "$USER" >/dev/null 2>&1
  e_arrow "Please exit and restart all your shells."
fi
