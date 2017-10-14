# OSX-only stuff. Abort if not OSX.
is_osx || return 1

# Install Homebrew.
if [[ ! "$(type -P brew)" ]]; then
  e_header "Installing Homebrew"
  true | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Exit if, for some reason, Homebrew is not installed.
[[ ! "$(type -P brew)" ]] && e_error "Homebrew failed to install." && return 1

e_header "Updating Homebrew"
brew doctor
brew update

# Functions used in subsequent init scripts.

# Tap Homebrew kegs.
# ${KEGS} must be an array of Brew Kegs to Tap
function brew_tap_kegs() {
  KEGS=($(setdiff "${KEGS[*]}" "$(brew tap)"))
  if (( ${#KEGS[@]} > 0 )); then
    e_header "Tapping Homebrew kegs: ${KEGS[*]}"
    for KEG in "${KEGS[@]}"; do
      brew tap ${KEG}
    done
  fi
}

# Install Homebrew recipes.
# ${RECIPIES} MUST be an array of Brew Recipies to Install
function brew_install_recipes() {
  RECIPES=($(setdiff "${RECIPES[*]}" "$(brew list)"))
  if (( ${#RECIPES[@]} > 0 )); then
    e_header "Installing Homebrew recipes: ${RECIPES[*]}"
    for RECIPE in "${RECIPES[@]}"; do
      brew install ${RECIPE}
    done
  fi
}

#MJL20170216 Install a recipe with special options
function brew_install_special_recipe() {
    local FORMULA="${1}"
    pushd ${HOME} >/dev/null
    shift
    if [[ $(setdiff "${FORMULA}" "$(brew list)") ]]; then
        e_header "Installing Homebrew recipe: ${FORMULA}, special options: ${@}"
        brew install ${FORMULA} ${@}
    fi
    popd > /dev/null
}

#MJL20170216 force re-install a recipe with special options. Maybe I want this?
#            I worked this out before coming up with the simpler
#            brew_install_special_recipe...
function brew_reinstall_special_recipe() {
    local FORMULA="${1}"
    shift
    e_header "Re-installing Homebrew recipe: ${FORMULA}, special options: ${@}"
    local INSTALLED=$(brew ls --versions ${FORMULA})
    [[ -z ${INSTALLED} ]] && INSTALLED='(not installed)'
    echo "current ${FORMULA} version: ${INSTALLED}"
    local BREW_CMD="brew install ${FORMULA} ${@}"
    if [[ ${INSTALLED} =~ ${FORMULA} ]]; then
        BREW_CMD="brew uninstall ${FORMULA}; ${BREW_CMD}"
    fi
    echo ${BREW_CMD}
    eval ${BREW_CMD}
}

#MJL20170216 Install a recipe with special options
function brew_install_special_cask() {
    local FORMULA="${1}"
    shift
    if [[ $(setdiff "${FORMULA}" "$(brew list)") ]]; then
        e_header "Installing Homebrew cask: ${FORMULA}, special options: ${@}"
        brew cask install ${FORMULA} ${@}
    fi
}
