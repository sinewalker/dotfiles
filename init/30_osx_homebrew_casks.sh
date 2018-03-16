# OSX-only stuff. Abort if not OSX.
is_osx || return 1

# Exit if Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Brew casks need Homebrew to install." && return 1

# Ensure the cask keg and recipe are installed.
KEGS=(caskroom/cask)
brew_tap_kegs


# Install Brew command for updating casks
# https://github.com/buo/homebrew-cask-upgrade
brew tap buo/cask-upgrade

# Exit if, for some reason, cask is not installed.
brew cask list > /dev/null 2>&1 ||  (e_error "Brew-cask failed to install." && return 1)

# Homebrew casks
CASKS=(
    # apps
    aerial
    anaconda
    android-file-transfer
    atom
    clementine
    enpass
    etcher
    flux
    gpgtools
    hammerspoon
    iterm2
    karabiner
    keepassx
    keybase
    netbeans
    netbeans-java-se
    spotify
    vagrant
    virtualbox
    visual-studio-code
    vlc
    xquartz
    todoist
    # Quick Look plugins
    suspicious-package
    webpquicklook
#    wireshark-chmodbpf

)

# Install Homebrew casks.
CASKS=($(setdiff "${CASKS[*]}" "$(brew cask list 2>/dev/null)"))
if (( ${#CASKS[@]} > 0 )); then
  e_header "Installing Homebrew casks: ${CASKS[*]}"
  for CASK in "${CASKS[@]}"; do
    brew cask install ${CASK}
  done
  brew cask cleanup
fi

