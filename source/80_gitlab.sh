[[ $(hostname) =~ jazz ]] || return

path_add /usr/local/opt/postgresql@11/bin /usr/local/opt/node@12/bin
export PKG_CONFIG_PATH="/usr/local/opt/icu4c/lib/pkgconfig:$PKG_CONFIG_PATH"

function __cdpath_add(){
    [[ -d "${1}" ]] && export CDPATH="${CDPATH}:${1}"
}
function __add_cdpath(){
    [[ -d "${1}" ]] && export CDPATH="${1}:${CDPATH}"
}
__cdpath_add ~/lab
__cdpath_add ~/lab/gdk
__add_cdpath .
__cdpath_add ~

# web shortcuts

alias ohshitgit='open https://ohshitgit.com/'
alias devcheat='open https://about.gitlab.com/handbook/engineering/development/dev/create-static-site-editor/developer-cheatsheet/'

function _chk_search_args(){
  local func="${1}"; shift
  local descr="${1}"; shift
  local noun="${1}"; shift
  if test -z "${1}"; then
    error "${func}: Error: no ${noun} supplied"
    usage "${func} <${noun}>" ${descr}
    return 1
  fi
}

function zen(){
  local FUNCDESC="Open a Zendesk ticket"
  _chk_search_args ${FUNCNAME} ${FUNCDESC} ticket "${@}"

  open "https://gitlab.zendesk.com/agent/tickets/${1}"
}

function glhb(){
  local FUNCDESC="Search the GitLab Handbook"
  _chk_search_args ${FUNCNAME} ${FUNCDESC} search_terms "${@}"

  local terms="${@}"
  open "https://about.gitlab.com/handbook/#stq=${terms}"
}


function gld(){
  local FUNCDESC="Search the GitLab Documentation"
  _chk_search_args ${FUNCNAME} ${FUNCDESC} search_terms "${@}"

  open "https://docs.gitlab.com/search/?q=${@}"
}

