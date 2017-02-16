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
