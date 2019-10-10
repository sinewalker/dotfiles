# Bash Run Commands

# Run by login or interactive shells, and also by Bash when called as /bin/sh in
# some situations. So this needs to be POSIX syntax or guard Bashisms

# have we been here before? (SUSE /etc/profile will source $HOME/.bashrc)
type -p usage && return

# Source system global definitions
test -f /etc/bashrc && source /etc/bashrc

# Unless in POSIX mode, load the rest of the Dotfiles bash modules into the
# environment. (POSIX will fail)
if kill -l|grep SIG &> /dev/null; then #is not POSIX?
  # Where the magic happens
  export DOTFILES=~/.dotfiles
  export BASH_MODULES=${DOTFILES}/source

  PATH=${DOTFILES}/bin:${PATH}
  export PATH
  source ${BASH_MODULES}/00_modules.sh
  __bootstrap_modules
#  eval "$(rbenv init -)"
fi
