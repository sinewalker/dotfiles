# Where the magic happens.
export DOTFILES=~/.dotfiles

# Add binaries into the path
PATH=${DOTFILES}/bin:${PATH}
export PATH

# Source all files in "source"
function src() {
  local file
  if [[ "$1" ]]; then
    source "${DOTFILES}/source/${1}.sh"
  else
    for file in ${DOTFILES}/source/*.sh; do
      source "$file"
    done
  fi
}

alias lssrc='\ls ${DOTFILES}/source/|egrep "\.sh$"|sed "s/\.sh//g"'

# Run dotfiles script, then source.
function dotfiles() {
  ${DOTFILES}/bin/dotfiles "$@" && src
}

src

# Completion for src function (requires bash_rompletion)
_src() {
  local cur sources
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  pushd ${DOTFILES}/source > /dev/null
  sources="$(\ls *.sh|sed 's/\.sh$//g')"
  popd > /dev/null

  COMPREPLY=( $(compgen -W "${sources}" -- ${cur}) )
  return 0
}
complete -F _src src

# fix SSH connections
bind '"\e[1;5D": backward-word'
bind '"\e[1;5C": forward-word'
