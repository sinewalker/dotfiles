# OSX-only stuff. Abort if not OSX.
is_osx || return 1

# Exit if Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Brew casks need Homebrew to install." && return 1

# Ensure the cask keg and recipe are installed.
kegs=(caskroom/cask)
brew_tap_kegs

# Exit if, for some reason, cask is not installed.
brew cask list > /dev/null 2>&1 ||  (e_error "Brew-cask failed to install." && return 1)

# Homebrew casks
casks=(
  # Applications
  a-better-finder-rename
  bettertouchtool
  charles
  chromium
  chronosync
  dropbox
  fastscripts
  firefox
  google-chrome
  gyazo
  hex-fiend
  istat-menus
  iterm2
  launchbar
  macvim
  moom
  omnidisksweeper
  race-for-the-galaxy
  reaper
  remote-desktop-connection
  sonos
  spotify
  steam
  synology-assistant
  teamspeak-client
  the-unarchiver
  todoist
  totalfinder
  tower
  transmission-remote-gui
  vagrant
  virtualbox
  vlc
  # Quick Look plugins
  betterzipql
  qlcolorcode
  qlmarkdown
  qlprettypatch
  qlstephen
  quicklook-csv
  quicklook-json
  quicknfo
  suspicious-package
  webp-quicklook
  # Color pickers
  colorpicker-developer
  colorpicker-skalacolor
)

# Install Homebrew casks.
casks=($(setdiff "${casks[*]}" "$(brew cask list 2>/dev/null)"))
if (( ${#casks[@]} > 0 )); then
  e_header "Installing Homebrew casks: ${casks[*]}"
  for cask in "${casks[@]}"; do
    brew cask install $cask
  done
  brew cask cleanup
fi
