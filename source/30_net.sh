# IP addresses
function wanip(){
    FUNCDESC='Print Wide Area Network IP address'
    dig +short myip.opendns.com @resolver1.opendns.com
}

if is_linux; then
    function lanip(){
        FUNCDESC='Print Local Area Network IP address'
        hostname -I
    }
else
# see https://stackoverflow.com/a/13322667/776953
    function lanip(){
        FUNCDESC='Print Local Area Network IP address'
        local _ip _line
        while IFS=$': \t' read -a _line ;do
            [ -z "${_line%inet}" ] &&
               _ip=${_line[${#_line[1]}>4?1:2]} &&
               [ "${_ip#127.0.0.1}" ] && echo $_ip && return 0
        done< <(LANG=C /sbin/ifconfig)
    }
fi

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

function check-tls-web() {
    local FUNCDESC="Connect to a web server and report TLS details."
    if [[ -z ${1} ]]; then
        error "${FUNCNAME}: must supply a DNS name to connect to."
        usage "${FUNCNAME} <domainname> [<servername>]" ${FUNCDESC}
        return 1
    fi
    local domain="${1}"
    local server="${2}"
    [[ -z "${2}" ]] && server="${1}"

    echo | openssl s_client -connect ${server}:443 -servername ${domain} \
        | openssl x509 -noout -text | tr -s " " | tr ',' '\n' \
        | sed 's/ Issuer:/Issuer:/' | sed 's/ Subject:/Subject:/' \
        | sed 's/ DNS:/DNS: /g' \
        | \egrep -v 'X509|Public Key Info|CA Issuers' \
        | \egrep --color=auto 'Issuer|Subject|O=|C=|L=|OU=|ST=|CN=|Before|After|DNS:'
}

alias check-tls-csr="openssl req -text -noout -verify -in"
alias check-tls-key="openssl rsa -check -in"
alias check-tls-crt="openssl x509 -text -noout -in"
alias check-tls-pkcs="openssl pkcs12 -info -in"

# https://kb.wisc.edu/middleware/page.php?id=4064
function __check-tls-digest(){
    local KIND THING THINGS COUNT RET
    KIND="${1}"; shift
    THINGS="${@}"
    COUNT="$#"
    RET=0
    for THING in ${THINGS[@]}; do
        if  [[ ! -f ${THING} ]] || [[ ! -s ${THING} ]] ; then
            error "${FUNCNAME}(${KIND}): ${THING}: not found"
            RET=1
        fi

        [[ ${COUNT} -gt 1 ]] && echo -n "${THING}: "
        case ${KIND} in
            KEY)
                openssl rsa -noout -modulus -in ${THING} | openssl md5 \
                | sed 's/(stdin)= //g'
                ;;
            CRT)
                openssl x509 -noout -modulus -in ${THING} | openssl md5 \
                | sed 's/(stdin)= //g'
                ;;
        esac
    done
    return ${RET}
}

function check-tls-crt-digest(){
    local FUNCDESC="Output the MD5SUM of a TLS certificate's Modulus.

Use this to compare with a key's digest from check-tls-key-digest."

    if [[ -z "${1}" ]]; then
        error "${FUNCNAME}: must specify at least one certificate to summarise"
        usage "${FUNCNAME} <crt-file> [<crt-file>...]" ${FUNCDESC}
        return 1
    fi

    local CRTS="${@}"
    __check-tls-digest CRT ${CRTS}
}

function check-tls-key-digest(){
    local FUNCDESC="Output the MD5SUM of a TLS key's Modulus.

Use this to compare with a certificate's digest from check-tls-crt-digest."

    if [[ -z "${1}" ]]; then
        error "${FUNCNAME}: must specify at least one key to summarise"
        usage "${FUNCNAME} <key-file> [<key-file>...]" ${FUNCDESC}
        return 1
    fi

    local KEYS="${@}"
    __check-tls-digest KEY ${KEYS}
}

function check-tls-crt-matches-key(){
    local FUNCDESC="Compare the MD5 digests of a TLS key/certificate modulus pair.

Returns 0 if matching, 1 otherwise."

    if [[ -z "${2}" ]]; then
        error "${FUNCNAME}: must specify a certificate and key to compare"
        usage "${FUNCNAME} <crt-file> <key-file>" ${FUNCDESC}
        return 1
    fi

    local CRT_DIGEST KEY_DIGEST DIGESTS
    CRT_DIGEST=$(check-tls-crt-digest "${1}") || return 1
    KEY_DIGEST=$(check-tls-key-digest "${2}") || return 1

    # There can be only one!
    DIGESTS=$((printf "${CRT_DIGEST}\n${KEY_DIGEST}\n") | uniq | wc -l)
    if [[ ${DIGESTS} -eq "1" ]]; then
        echo "${FUNCNAME}: matching"
        return 0
    else
        echo "${FUNCNAME}: DIFFERENT"
        return 1
    fi
}

function create-csr-conf() {
    local FUNCDESC="Create a CSR openssl configuration from an existing web server certificate."
    if [[ -z "${1}" ]] ; then
        error "missing domain to generation config for"
        usage "${FUNCNAME} <somedomain>" ${FUNCDESC}
        return 1
    fi

    local domain="${1}" C ST OU O L CN subject
    subject=$(echo | openssl s_client -connect ${domain}:443 -servername ${domain} | openssl x509 -subject -noout)
    C=$(echo ${subject}  | grep -oP '\/C=.*?\/'  | tr -d /)
    ST=$(echo ${subject} | grep -oP '\/ST=.*?\/' | tr -d /)
    OU=$(echo ${subject} | grep -oP '\/OU=.*?\/' | tr -d /)
    O=$(echo ${subject}  | grep -oP '\/O=.*?\/'  | tr -d /)
    L=$(echo ${subject}  | grep -oP '\/L=.*?\/'  | tr -d /)
    CN=$(echo ${subject} | grep -oP '\/CN=.*'    | tr -d /)

    local outfile="${1}.conf"
    cat > ${outfile} <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
req_extensions = v3_req

[req_distinguished_name]
$C
$ST
$L
$O
$OU
$CN

[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
EOF
    local name count=1
    for name in $(check-tls-web "${1}" 2>/dev/null | awk '/DNS:/ {print $2}')
    do
        echo "DNS.${count}=${name}" >> ${outfile}
        ((count++))
    done
    echo; echo

    echo "${outfile} created"; echo
    cat ${outfile}

    local create
    read -p "Create CSR? (y/n) " create
    [[ $create == "y" ]] && create-csr ${outfile}
}
alias gencsr-conf=create-csr-conf

function create-csr() {
    local FUNCDESC="Create a TLS CSR from an openssl CSR configuration file."

    if [[ -z "${1}" ]]; then
        error "missing config file name"
        usage "${FUNCNAME} <openssl-csr-config-file>" ${FUNCDESC}
        return 1
    fi

    local name=$(echo "${1}" | awk -F'.' '{OFS='FS'} {$NF=""; print $0}')
    openssl req -new -newkey rsa:2048 -sha256 -nodes -keyout ${name}key -out ${name}csr -config "${1}" \
     && echo "${name}key and ${name}csr created"
}
alias gencsr=create-csr


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

function dl-av() {
    local FUNCDESC="Download audio and/or video from non-DRM streaming web services.

Requires youtube-dl.  Format conversion requires vorbis/opus codecs for ffmpeg."

    if [[ -z ${1} ]]; then
        error "${FUNCNAME}: must supply at least one argument."
        usage "${FUNCNAME} [audio|vorbis|opus|mp3] <URL>..."
        return 1
    fi
    local format=''
    local output="%(playlist_index)s-%(title)s.%(ext)s"

    case ${1} in
         vorbis|opus|mp3)
             format="--extract-audio --audio-format ${1}"
             shift
             ;;
         audio)
             format="--extract-audio"
             shift
             ;;
    esac

    if [[ -z ${format} ]]; then
        youtube-dl --ignore-errors --output ${output} ${@}
    else
        youtube-dl ${format} --ignore-errors --output ${output} ${@}
    fi
}

alias dl-vorbis='dl-av vorbis'
alias dl-opus='dl-av opus'
alias dl-mp3='dl-av mp3'
alias dl-audio='dl-av audio'
alias dl-video='dl-av'

function geoip(){
    local FUNCDESC="Get Geographic info for an IP address, or current WAN address.

Uses the JS API from geojs.io

https://www.geojs.io/docs/v1/endpoints/geo/"

    if [[ -z "${1}" ]]; then
        http https://get.geojs.io/v1/ip/geo.json
    else
        http "https://get.geojs.io/v1/ip/geo/${1}.json"
    fi
}