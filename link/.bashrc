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

function lssrc(){
    local FUNCDESC='List the Dotfiles source modules available for the src function.
The .sh suffix is stripped.'
    \ls ${DOTFILES}/source|awk '/.sh$/ { gsub(/\.sh/, ""); print }'
}

#only source if in Bash-mode
kill -l|grep SIG > /dev/null && src

# Completion for src function (requires bash_completion)
_src() {
  local COMPREPLY=()
  local CUR="${COMP_WORDS[COMP_CWORD]}"
  local SOURCES="$(lssrc)"
  COMPREPLY=( $(compgen -W "${SOURCES}" -- ${CUR}) )
  return 0
}
complete -F _src src

function dotfiles() {
