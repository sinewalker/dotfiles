#alias current-song='wget http://localhost:8081/requests/status.xml -qO- | xmlstarlet sel -T -t -v //now_playing -'
#alias show-current-song='notify-send "$(current-song)" "\nCurrently playing"'

alias current-song='wget http://localhost:8080/requests/status.xml -qO- | xmlstarlet sel -T -t -v "//info[@name=\"filename\"]" -'
alias current-artist='wget http://localhost:8080/requests/status.xml -qO- | xmlstarlet sel -T -t -v "//info[@name=\"artist\"]" -'
alias show-current-song='notify-send "$(current-song)" "$(current-artist)"'

alias pause='echo pause | nc -U /tmp/.vlc.sock'

