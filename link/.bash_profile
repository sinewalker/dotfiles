if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi

#MJL20170905 installed via curl -L https://iterm2.com/misc/install_shell_integration_and_utilities.sh | bash
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
