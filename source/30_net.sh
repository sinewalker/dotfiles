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

    echo | openssl s_client -connect ${server}:443 -servername ${domain} \
        | openssl x509 -noout -text | tr -s " " | tr ',' '\n'| \
        egrep --color=auto 'O=|C=|L=|OU=|ST=|CN=|Before|After|DNS:'
}

function createconf() {
        [[ -z $1 ]] && echo "missing domain to generation config for" && return
        subject=$(echo | openssl s_client -connect ${1}:443 -servername ${1} | openssl x509 -subject -noout)
        C=$(echo $subject | grep -oP '\/C=.*?\/' | tr -d /)
        ST=$(echo $subject | grep -oP '\/ST=.*?\/' | tr -d /)
        OU=$(echo $subject | grep -oP '\/OU=.*?\/' | tr -d /)
        O=$(echo $subject | grep -oP '\/O=.*?\/' | tr -d /)
        L=$(echo $subject | grep -oP '\/L=.*?\/' | tr -d /)
        CN=$(echo $subject | grep -oP '\/CN=.*' | tr -d /)

        outfile=${1}.conf
        echo "[req]" > $outfile
        echo "distinguished_name = req_distinguished_name" >> $outfile
        echo "x509_extensions = v3_req" >> $outfile
        echo "prompt = no" >> $outfile
        echo "req_extensions = v3_req" >> $outfile
        echo " " >> $outfile
        echo "[req_distinguished_name]" >> $outfile
        [[ ! -z $C ]] && echo $C >> $outfile
        [[ ! -z $ST ]] && echo $ST >> $outfile
        [[ ! -z $L ]] && echo $L >> $outfile
        [[ ! -z $O ]] && echo $O >> $outfile
        [[ ! -z $OU ]] && echo $OU >> $outfile
        [[ ! -z $CN ]] && echo $CN >> $outfile
        echo " " >> $outfile
        echo "[v3_req]" >> $outfile
        echo "keyUsage = keyEncipherment, dataEncipherment" >> $outfile
        echo "extendedKeyUsage = serverAuth" >> $outfile
        echo "subjectAltName = @alt_names" >> $outfile
        echo " " >> $outfile
        echo "[alt_names]" >>$outfile
        count=1
        for name in $(cert $1 names)
        do
                echo "DNS.${count}=$name" >> $outfile
                ((count++))
        done
        echo " "
        echo " "

        echo "$outfile created"
        echo " "
        cat $outfile

        read -p "Create CSR? (y/n) " create
        [[ $create == "y" ]] && createcsr $outfile
}
alias gencsr-conf=createconf

function createcsr() {
        [[ -z $1 ]] && echo 'missing config file name' && return
        name=$(echo $1 | awk -F'.' '{OFS='FS'} {$NF=""; print $0}')
        openssl req -new -newkey rsa:2048 -sha256 -nodes -keyout ${name}key -out ${name}csr -config ${1} && echo "${name}key and ${name}csr created"
}
alias gencsr=createcsr

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
