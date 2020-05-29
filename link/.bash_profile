test -f ~/.bashrc && source ~/.bashrc

#MJL20180331 iterm2 integration (macOS)
iterm2_integration="${HOME}/.iterm2_shell_integration.bash"
test -e ${iterm2_integration} && source ${iterm2_integration} || true

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
