# https://about.gitlab.com/handbook/git-page-update/  with some tweeks

# Where to keep ruby
export RUBY_DIR=${LIBRARY}/ruby
[[ -d ${RUBY_DIR} ]] || mkdir -p ${RUBY_DIR}

# Ruby Version Manager and it's managed Rubys go here, thanks
export RVM_DIR="${LIBRARY}/ruby/rvm"

# Load RVM into a shell session *as a function*
[[ -s "${RVM_DIR}/scripts/rvm" ]] && source "${RVM_DIR}/scripts/rvm" 

# Add RVM to PATH for scripting.
path_add ${RVM_DIR}/bin
