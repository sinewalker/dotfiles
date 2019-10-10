[[ $(hostname) =~ milo ]] || return

# Override my preferred, more stringent umask with a Squiz-friendly one
umask 0022

# to make SQ_CONF_ROOT_URLS into wiki urls
# just enter the URLS followed by EOF
alias wiki_urls='cat <<EOF | sed -re "s^(.*)^|| http://\1 ||^"'

# according to https://opswiki.squiz.net/Policies/Password_Guidelines#GeneralPasswordGuidelines
alias pwgen='pwgen -1 -c -n -y 12'


function __cdpath_add(){
    [[ -d "${1}" ]] && export CDPATH="${CDPATH}:${1}"
}
function __add_cdpath(){
    [[ -d "${1}" ]] && export CDPATH="${1}:${CDPATH}"
}
__add_cdpath ~/Work
__cdpath_add ~/Work/svn
__cdpath_add ~/Work/lab
__add_cdpath ~/Work/lab/mlockhart
__cdpath_add ~/Work/lab/ops
__add_cdpath ~/Work/Projects
__add_cdpath ~/Work/Documents
__add_cdpath .

# we want colour and paging in svn diff commands
svn () {
  # bail if the user didnt specify which subversion command to invoke
  if (( $# < 1 )) || ! [[ -t 1 ]]
  then
    command svn "$@"
    return
  fi

  local sub_cmd=$1
  local pager=cat
  shift

  # abbreviations stolen from 'svn help'
  case $sub_cmd in
    st*|di*|log|blame|praise|ann*|h*|?) pager='less -Rf'
  esac

  #intercept svn diff commands
  if [[ $sub_cmd == diff ]]
  then

    # colorize the diff
    # remove stupid ^M dos line endings
    # page it if there's more one screen
    command svn diff "$@" | colordiff | sed -e "s/\\\r//g"

  # add some color to svn status output and page if needed:
  # M = blue
  # A = green
  # D/!/~ = red
  # C = magenta
  #
  #note that C and M can be preceded by whitespace - see $svn help status
  elif [[ $sub_cmd =~ ^(status|st)$ ]]
  then
    command svn status "$@" | sed -e 's/^\(\([A-Z]\s\+\(+\s\+\)\?\)\?C .*\)$/\[1;35m\1[0m/' \
        -e 's/^\(\s*M.*\)$/\[1;34m\1[0m/' \
        -e 's/^\(A.*\)$/\[1;32m\1[0m/' \
        -e 's/^\(\(D\|!\|~\).*\)$/\[1;31m\1[0m/'

  # page some stuff I often end up paging manually
# elif [[ $sub_cmd =~ ^(blame|help|h|cat)$ ]]
# then
#   command svn $sub_cmd "$@"

  # colorize and page svn log
  # rearrange the date field from:
  #  2010-10-08 21:19:24 +1300 (Fri, 08 Oct 2010)
  # to:
  #  2010-10-08 21:19 (Fri, +1300)
  elif [[ $sub_cmd == log ]]
  then
    command svn log "$@" | sed -e 's/^\(.*\)|\(.*\)| \(.*\) \(.*\):[0-9]\{2\} \(.*\) (\(...\).*) |\(.*\)$/\[1;32m\1[0m|\[1;34m\2[0m| \[1;35m\3 \4 (\6, \5)[0m |\7/'

  #let svn handle it as normal
  else
    command svn "$sub_cmd" "$@"

  # TODO we don't want to page the update command
  fi | $pager
}


function wiid() {
    ssh squiz-cru01.hba.squiz.net.au "su - wiid -c '~/whyisitdown/whyisitdown $1 "$2"'"
}
export -f wiid

function testmx() {
    if test -z ${1}; then
        error "${FUNCNAME}: must supply the domain of a Matrix to test"
        local FUNCDESC="Test a Squiz Matrix with specified test level, defaults to 1"
        FUNCDESC=${FUNCDESC}+" With optional 3rd param 's' will use HTTPS."
        usage "${FUNCNAME} <matrix.fqdn> [test-level] [s]" ${FUNCDESC}
        return 1
    fi
    local level=1
    [[ -z ${2} ]] || level=${2}
    local scheme="http"
    [[ -z ${3} ]] || scheme="https"
    local test_url="${scheme}://${1}/__lib/web/test_message.php?interrogate=${level}"
    echo Testing ${test_url}
    time http ${test_url}
}

#MJL20170216 squizisms from 2014

export SQUIZAU_SVN=~/Work/svn
export SQUIZUK_SVN=~/Work/uksvn

alias squizau='pushd ${SQUIZAU_SVN}; svn update; popd'
alias squizuk='pushd ${SQUIZUK_SVN}; svn update; popd'
alias squizup='squizau; squizuk'
alias squizwords='gpg -d ${SQUIZAU_SVN}/sysadmin/support-passwords.txt.gpg|less'
alias infrawords='gpg -d ${SQUIZAU_SVN}/sysadmin/cru-infrastructure-passwords.txt.gpg|less'
alias edpass='pushd ${SQUIZAU_SVN}/sysadmin; svn up; emacsclient support-passwords.txt.gpg; popd'

#bounce to the UK
alias bounce="ssh bounce.squiz.co.uk -lmlockhart -o ForwardAagent=yes"

#better rdesktop experience for Squiz (uploads from \\tsclient\upload)
# (see https://opswiki.squiz.net/Clients/CSU ):
alias rdp="rdesktop -g 1200x800 -a 15 -z -x b -P -r disk:upload=${HOME}/Uploads -rclipboard:PRIMARYCLIPBOARD"

export PATH=${SQUIZAU_SVN}/ovirt/scripts:${PATH}

#MJL20180618 squiz secrets

export SQUIZ_KEYS=~/key/squiz
export SQUIZ_SSH=${SQUIZ_KEYS}/ssh-mlockhart-hobart.pub
export SQUIZ_SSH_PRIVATE=${SQUIZ_KEYS}/ssh-mlockhart-hobart
export SQUIZ_NETBOX=${SQUIZ_KEYS}/netbox.token
export SQUIZ_GITLAB=~/Work/lab
export SQUIZ_PUPPET=${SQUIZ_GITLAB}/ops/puppet4

#MJL20190210 squiz hosting API

export SQUIZ_API_AU=https://hosting-api.squiz.net/api/v1/
export SQUIZ_API_UK=https://hosting-api.squiz.co.uk/api/v1/
export SQUIZ_API_US=https://hosting-api01.sac1.squiz.systems/api/v1
export SQUIZ_USER=mlockhart

#MJL20180828 Squiz variables
# Some infra/hosting scripts use globals with different names to mine.
# I /could/ rename mine, or just have two names...

export SQUIZAUSVNDIR=${SQUIZAU_SVN}
export SQUIZUKSVNDIR=${SQUIZUK_SVN}
export SQUIZNETBOXTOKENFILE=${SQUIZ_NETBOX}
export SQUIZP4GITDIR=${SQUIZ_PUPPET}
#MJL20190615 username on Squiz hosts -- used for C7 Makefiles
alias c7='export SERVERUSER=${SQUIZ_USER}'
alias sl6='unset SERVERUSER'

#MJL20190711 Squiz Edge
export SQUIZ_EDGE_STAGING_IP=202.9.94.180
export SQUIZ_EDGE_PROD_IP=202.9.95.188

#MJL20190904 Edit eyaml
#  https://opswiki.squiz.net/asharpe/workstation/walkthrough#Edit_eyaml

#TODO:  completion doesn't work.  I'd like to complete files in $SQUIZ_PUPPET/hieradata from anywhere
#  see https://stackoverflow.com/questions/44453510/how-to-autocomplete-a-bash-commandline-with-file-paths-from-a-specific-directory
#  for now:  cd $SQUIZ_PUPPET  and then use default file completion

function _sq_hieradata(){
    COMPREPLY=()
    local cur yaml
    cur="${COMP_WORDS[COMP_CWORD]}"
    yaml=\
     "$(find ${SQUIZ_PUPPET}/hieradata -name *.yaml)"
#         -exec realpath --relative-to ${SQUIZ_PUPPET} {} \;)"
    COMPREPLY=($(compgen -W "${yaml}" -- ${cur}))
    return 0
}
function eyaml_sq_edit() {
    local FUNCDESC="Edit a file with eyaml, encrypted for the squiz sysadmins group"

   pushd ${SQUIZ_PUPPET}  #so that the right rbenv activates
   echo editing ${@} with ${EDITOR}
   eyaml edit -n gpg --gpg-always-trust \
     --gpg-recipients-file=${SQUIZ_PUPPET}/hieradata/allsysadmins.gpg-recipients "$@"
   popd
}
#complete -F _sq_hieradata eyaml_sq_edit

function eyaml_sq_recrypt() {
    local FUNCDESC="Recrypt a file with eyaml, encrypted for the squiz sysadmins group"

   pushd ${SQUIZ_PUPPET}  #so that right rbenv activates
   echo recrypting ${@}
   eyaml recrypt -d gpg -n gpg --gpg-always-trust \
     --gpg-recipients-file=${SQUIZ_PUPPET}/hieradata/allsysadmins.gpg-recipients "$@"
   popd
}
#complete -F _sq_hieradata eyaml_sq_recrypt

#MJL20191010 - web shortcuts

alias howtoedge='open https://opswiki.squiz.net/HowTo/Edge/edge-config#Make_your_changes_in_Staging'
alias ohshitgit='open https://ohshitgit.com/'
alias sslcheat='open https://opswiki.squiz.net/dbelcher/OpenSSL_Cheats'

function jira(){
  local FUNCDESC="Open a JIRA ticket"

  if test -z "${1}"; then
    error "${FUNCNAME}: Error: no ticket supplied"
    usage "${FUNCNAME} <ticket-id>" ${FUNCDESC}
    return 1
  fi

  open https://jira.squiz.net/browse/${1}
}