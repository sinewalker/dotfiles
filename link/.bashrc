# Where the magic happens.
export DOTFILES=~/.dotfiles

# Add binaries into the path
PATH=${DOTFILES}/bin:${PATH}
export PATH

function src() {
  local FUNCDESC="Source all files in 'source', or a specified file"
  local FILE
  if [[ "${1}" ]]; then
    source "${DOTFILES}/source/${1}.sh"
  else
    for FILE in ${DOTFILES}/source/*.sh; do
      source "${FILE}"
    done
  fi
}

alias lssrc='\ls ${DOTFILES}/source/|egrep "\.sh$"|sed "s/\.sh//g"'

function dotfiles() {
  local FUNCDESC="Run dotfiles script, then source. This causes the Copy, Link and Init step to be run."
  ${DOTFILES}/bin/dotfiles "${@}" && src
}

#only source if in Bash-mode
kill -l|grep SIG > /dev/null && src

# Completion for src function (requires bash_rompletion)
_src() {
  local cur sources
  COMPREPLY=()
  local CUR="${COMP_WORDS[COMP_CWORD]}"
  pushd ${DOTFILES}/source > /dev/null
  local SOURCES="$(\ls *.sh|sed 's/\.sh$//g')"
  popd > /dev/null

  COMPREPLY=( $(compgen -W "${SOURCES}" -- ${CUR}) )
  return 0
}
complete -F _src src

function dotfiles() {
