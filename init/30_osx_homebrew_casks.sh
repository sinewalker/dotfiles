# OSX-only stuff. Abort if not OSX.
is_osx || return 1

# Exit if Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Brew casks need Homebrew to install." && return 1




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
    flux
    gpg-suite
    hammerspoon
    iterm2
    keybase
    osxfuse
    rectangle
#    spotify
#    vagrant
    virtualbox
#    visual-studio-code
    vlc
#    wireshark-chmodbpf

)

# Install Homebrew casks.
CASKS=($(setdiff "${CASKS[*]}" "$(brew cask list 2>/dev/null)"))
if (( ${#CASKS[@]} > 0 )); then
  e_header "Installing Homebrew casks: ${CASKS[*]}"
  for CASK in "${CASKS[@]}"; do
    brew cask install ${CASK}
  done
fi
