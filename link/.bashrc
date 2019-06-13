# Where the magic happens.
export DOTFILES=~/.dotfiles

PATH=${DOTFILES}/bin:${PATH}
export PATH

function src() {
  local FUNCDESC='Source all files in ${DOTFILES}/source/, or a specified file'
  local FILE
  if [[ "${1}" ]]; then
    source "${DOTFILES}/source/${1}.sh"
  else
    echo "Loading environment..."
    for FILE in ${DOTFILES}/source/*.sh; do
      printf "\r%${COLUNMS}s"
      printf "\r<-- ${FILE}"
      source "${FILE}"
    done
    printf "\rReady%$((${COLUMNS}-5))s"
  fi
}

function lssrc(){
    local FUNCDESC='List the Dotfiles source modules available for the src function.
The .sh suffix is stripped.'
    \ls ${DOTFILES}/source|awk '/.sh$/ { gsub(/\.sh/, ""); print }'
}

# Completion for src function (requires bash_completion)
_src() {
  COMPREPLY=()
  local CUR="${COMP_WORDS[COMP_CWORD]}"
  local SOURCES="$(lssrc)"
  COMPREPLY=( $(compgen -W "${SOURCES}" -- ${CUR}) )
  return 0
}
complete -F _src src

function dotfiles() {
    local FUNCDESC='Run dotfiles refresh script, then reload.
This causes the Copy, Link and Init step to be run.'
    ${DOTFILES}/bin/dotfiles "${@}" && src
}

#Load the rest of Dotfiles bash modules, unless in POSIX mode
if kill -l|grep SIG > /dev/null; then
    src
fi
