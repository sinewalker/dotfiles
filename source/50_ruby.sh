# https://about.gitlab.com/handbook/git-page-update/  with some tweeks

# Where to keep ruby
export RUBY_DIR=${LIB}/ruby
[[ -d ${RUBY_DIR} ]] || mkdir -p ${RUBY_DIR}

## RVM
# Ruby Version Manager and it's managed Rubys go here, thanks
#export RVM_DIR="${LIB}/ruby/rvm"

# Load RVM into a shell session *as a function*
#[[ -s "${RVM_DIR}/scripts/rvm" ]] && source "${RVM_DIR}/scripts/rvm" 

# Add RVM to PATH for scripting.
#path_add ${RVM_DIR}/bin

# rbenv is incompatible with RVM, but this is how to init it anyway
export RBENV_ROOT=${RUBY_DIR}/rbenv
path_add ${RBENV_ROOT}/bin
is_exe rbenv && eval "$(rbenv init -)"

alias bex='bundle exec'

#ruby-build installs a non-Homebrew OpenSSL for each Ruby version installed and these are never upgraded.
#
#To link Rubies to Homebrew's OpenSSL 1.1 (which is upgraded) add the following
#to your /Users/mjl/.bash_profile:

export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"

#Note: this may interfere with building old versions of Ruby (e.g <2.4) that use
#OpenSSL <1.1.