# IP addresses
alias wanip="dig +short myip.opendns.com @resolver1.opendns.com"
# see https://opswiki.squiz.net/ncallahan
alias showip='curl http://ipecho.net/plain; echo'

# Flush Directory Service cache
alias dsflush="dscacheutil -flushcache"

# View HTTP traffic
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

alias vso='curl -vso /dev/null'
# the 'c' means 'bust cache'
alias vsoc='vso -H "Cache-Control: no-cache"'

#Show the time to load a web page, broken down by stages (e.g. webtime http://milosophical.me)
alias webtime="curl -so /dev/null -L -w 'DNS Lookup:\t%{time_namelookup}\nConnect:\t%{time_connect}\nApp Connect:\t%{time_appconnect}\nPre Transfer:\t%{time_pretransfer}\nStart Transfer:\t%{time_starttransfer}\n\nTOTAL Time:\t%{time_total}\nHTTP Response:\t%{http_code}\nDownload bytes:\t%{size_download}\n'"
# the 'c' again means 'bust cache'
alias webtimec='webtime -H "Cache-Control: no-cache" ${@}'
#always show the name server details when digging
alias digns='\dig ns'
#show only the IPs for the domain
alias digip='\dig +short'
#show the full name server trace from root
alias digtrace='\dig +trace'

function analyse-web() {
    local FUNCDESC="Run a real-time analysis on a web server's access logs.

Requires goaccess -  http://goaccess.io/

Params:  <server_name>:  server name (you must be able to read the web logs on this server)
         <path>:  path to the access log on the server (default /var/log/openresty/access.log)
         <remove>:  (optional) if set, remove the local log copy after quitting"

    if [[ -z ${1} ]]; then
        error "${FUNCNAME}: must supply at least a server_name to connect to."
        usage "${FUNCNAME} <server_name> [<path/to/log>] [<keep-after-quit>]" ${FUNCDESC}
        return 1
    fi

    SERVER=${1}
    LOG=${2}
    [[ -z ${LOG} ]] && LOG=/var/log/openresty/access.log
    LOCAL=$(mktemp -t "${FUNCNAME}")
    ssh -S none ${SERVER} "tail -f ${LOG}" > ${LOCAL} &
    echo "Pre-loading  ${SERVER}:${LOG}"
    echo "to ${LOCAL} ..."
    until [[ -s ${LOCAL} ]]; do
        echo -n "."
        sleep 1
    done

    #get the SSH PID here.  Using $! after the ssh fork doesn't work
    LOGGER=$(ps|grep "[s]sh -S none ${SERVER}"|awk '{print $1}')

    goaccess -f ${LOCAL} -a

    kill -9 $LOGGER
    fg

    if [[ -z ${3} ]]; then
        rm ${LOCAL}
        echo "${LOCAL} removed"
    else
        echo "${LOCAL} kept"
    fi
}

function check-tls() {
    local FUNCDESC="Connect to a web server and report TLS details."
    if [[ -z ${1} ]]; then
        error "${FUNCNAME}: must supply a DNS name to connect to."
        usage "${FUNCNAME} <domainname> [<servername>]" ${FUNCDESC}
        return 1
    fi
    local domain=${1}
    local server=${2}
    [[ -z ${2} ]] && server=${1}

    echo | openssl s_client -connect ${domain}:443 -servername ${server} \
        | openssl x509 -noout -text |egrep 'Subject:|subject=|Before|After|DNS'
}

function tunnel-port() {
    local FUNCDESC="Tunnel a port locally via a jump box."
    if [[ ${#} -lt 3 ]]; then
        error "${FUNCNAME}: must supply port, jump-host and a target."
        usage "${FUNCNAME} <port> <jump-host> <target>" ${FUNCDESC}
        return 1
    fi
    local port="${1}"
    local jumpbox="${2}"
    local target="${3}"

    sudo ssh -v -F ${HOME}/.ssh/config -L ${port}:${target}:${port} ${jumpbox}
}

#common tunnels
alias tunnel-https='tunnel-port 443'
alias tunnel-http='tunnel-port 80'
alias tunnel-db='tunnel-port 5432'

#youtube downloads
alias tubevorbis='youtube-dl --extract-audio --audio-format vorbis -i -o "%(title)s.%(ext)s"'
alias tubeopus='youtube-dl --extract-audio --audio-format opus -i -o "%(title)s.%(ext)s"'
