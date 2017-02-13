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
