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

function analyse-web() {
    #runs a real-time analysis on a web server's access logs
    #requires goaccess -  http://goaccess.io/
    #
    #Params:  $1:  server name (you must be able to read the web logs on this server)
    #         $2:  path to the access log on the server (default /var/log/openresty/access.log)
    #         $3:  (optional) if set, remove the local log copy after quitting
    [[ -z ${1} ]] && return 1
    SERVER=${1}
    LOG=${2}
    [[ -z ${LOG} ]] && LOG=/var/log/openresty/access.log
    LOCAL=$(mktemp -t "analysis-XXX")
    echo "Tailing to ${LOCAL}..."
    ssh ${SERVER} "tail -f ${LOG}" > ${LOCAL} &
    LOGGER=$!
    sleep 3
    [[ -s ${LOCAL} ]] && goaccess -f ${LOCAL} -a
    kill $LOGGER
    [[ -z ${3} ]] || (rm ${LOCAL}; echo "${LOCAL} removed")
}

function check-tls() {
    local FUNCDESC="Connect to a web server and report TLS details."
    [[ -z ${1} ]] && error "${FUNCNAME}: must supply a DNS name to connect to." \
        && usage "${FUNCNAME} <domainname> [<servername>]" ${FUNCDESC} \
        && return 1
    local domain=${1}
    local server=${2}
    [[ -z ${2} ]] && server=${1}

    echo | openssl s_client -connect ${domain}:443 -servername ${server} | openssl x509 -noout -subject -dates
}
