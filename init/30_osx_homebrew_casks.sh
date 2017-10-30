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
    sourcetree
    spotify
    vagrant
    virtualbox
    visual-studio-code
    vlc
    xquartz
    # ## TODO: MJL20170131 - Maybe install these?
    #chromium
    #todoist
    # Quick Look plugins
    suspicious-package
    webpquicklook
#    wireshark-chmodbpf

    #TODO: MJL20170131 - All of these I have installed manually or Work has, and
    #      they do not appear in `brew cask list`, which means they will be
    #      downloaded *each time*, and then skipped, and then cleaned up... So I
    #      probably need to uninstall them manually, and then uncomment and
    #      install from Cask.

    # ## Applications
    # ### Free
    # dropbox

    # ### MJL20170131 Purchased on my own account
    # steam

    # ## Quick Look plugins
    # betterzipql
    # qlcolorcode
    # qlmarkdown
    # qlprettypatch
    # qlstephen
    # quicklook-csv
    # quicklook-json
    # quicknfo

    # ### MJL20170131 - Installed by Work
    # google-chrome
    firefox
    # the-unarchiver

    # ### MJL20170131 - deprecated and/or missing (I'm thinking to replace some
    #                   of these with Hammerspoon codes)
    # bettersnaptool (not in the main Caskroom?)
    # copyclip (not in the Caskroom?)
    # systempal (not in Cask )
    # MEGA NZ (not in Cask)
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

#MJL20170301 Emacs with more options
brew_install_special_cask emacs --with-imagemagick --with-librsvg --with-cocoa
