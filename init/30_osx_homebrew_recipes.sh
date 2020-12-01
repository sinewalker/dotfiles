# OSX-only stuff. Abort if not OSX.
is_osx || return 1

# Exit if Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Brew recipes need Homebrew to install." && return 1

# Ensure taps for recipes are installed.
KEGS=(d12frosted/emacs-plus
  amar1729/formulae
)

brew_tap_kegs

# Homebrew recipes
RECIPES=(
#  ansible
  asciinema
  bash
  browserpass
  cmatrix
  cowsay
  dos2unix
  git
  git-extras
  git-lfs
  htop
  hub
  id3tool
  lesspipe
  man2html
  nmap
  sl
  ssh-copy-id
  the_silver_searcher
  tree
  #MJL20170131 more by me
  apm-bash-completion
  bash-completion
  bash-git-prompt
#  clamav
#  clisp
#  clojure
  colordiff
  coreutils
  cpulimit
  exiftool
  flac
  fortune
  gawk
  git
  gnu-sed
  goaccess
  gpg
  grep
#  guile
  htop
  httpie
  httrack
  imagemagick
  ipcalc
  ispell
  jq
  lame
  libidn2
  libmikmod
  librsvg
  libvorbis
  lolcat
  markdown
  midnight-commander
#  node
  opencore-amr
#  openssl
  pass
  pcre
  proctools
  pwgen
  pygments
#  python
#  python3
  qcachegrind
  readline
  screenfetch
  socat
  sqlite
  sshfs
  sslscan
  tidy-html5
  tmux
  vorbis-tools
  watch
  wtf
  wget
  wireshark
  xz
  youtube-dl
  zlib

# former specials:
  ffmpeg
  curl
  sox
)

brew_install_recipes


#MJL20170216 Special recipes

#brew_install_special_recipe ffmpeg --with-libvorbis
#brew_install_special_recipe curl --with-openssl
#brew_install_special_recipe sox --with-libvorbis --with-flac --with-lame --with-opencore-amr

#MJL20180304 Emacs-plus (the latest preferred way to install emacs on macOS for spacemacs)
#            This is from the d12frosted tap, see above before call to brew_tap_kegs
#brew_install_special_recipe emacs-plus --with-natural-titlebar --with-24bit-color
#brew linkapps emacs-plus #linkapps is deprecated, no replacement

#brew_reinstall_special_recipe   homebrew/emacs/tern

# Misc cleanup!

# This is where brew stores its binary symlinks
local BINROOT="$(brew --config | awk '/HOMEBREW_PREFIX/ {print $2}')"/bin

# htop
if [[ "$(type -P ${BINROOT}/htop)" ]] && [[ "$(stat -L -f "%Su:%Sg" "${BINROOT}/htop")" != "root:wheel" || ! "$(($(stat -L -f "%DMp" "${BINROOT}/htop") & 4))" ]]; then
  e_header "Updating htop permissions"
  sudo chown root:wheel "${BINROOT}/htop"
  sudo chmod u+s "${BINROOT}/htop"
fi

# bash
if [[ "$(type -P ${BINROOT}/bash)" && "$(cat /etc/shells | grep -q "${BINROOT}/bash")" ]]; then
  e_header "Adding ${BINROOT}/bash to the list of acceptable shells"
  echo "${BINROOT}/bash" | sudo tee -a /etc/shells >/dev/null
fi
if [[ "$(dscl . -read ~ UserShell | awk '{print $2}')" != "${BINROOT}/bash" ]]; then
  e_header "Making ${BINROOT}/bash your default shell"
  sudo chsh -s "${BINROOT}/bash" "${USER}" >/dev/null 2>&1
  e_arrow "Please exit and restart all your shells."
fi
