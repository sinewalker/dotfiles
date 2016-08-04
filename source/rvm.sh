#[[ $EUID -ne 0 ]] && [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

function rvm_init() {
	[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" || return 1

   [[ -f ./.rvmrc ]] && {
      source ./.rvmrc
      return 0
   }

	[[ -z "$1" ]] && {
		echo "Project name required"
		return 1
	}

	local PROJECT_DIR="$1"
	local RVMRC="$PROJECT_DIR"/.rvmrc
	[[ -f "$RVMRC" ]] && return 0

	! [[ -d "$PROJECT_DIR" ]] && mkdir -p "$PROJECT_DIR"

	# TODO use project name for gemset (instead of veewee)
	cat <<-EOF > "$RVMRC"
		rvm use "ruby-1.9.2@${PROJECT_DIR}" --create
		alias veewee="bundle exec veewee"
		alias vagrant="bundle exec vagrant"
		alias irb="bundle exec irb"
	EOF

	cd $PROJECT_DIR
	source "$(basename "$RVMRC")"

	cat <<-EOF > Gemfile
		source 'http://rubygems.org'
		gem 'vagrant', :git => 'https://github.com/mitchellh/vagrant.git', :tag => 'v1.3.5'
		gem "veewee", :git => 'https://github.com/jedi4ever/veewee.git', :tag => 'v0.3.12'
		gem 'vagrant-hostmanager', :git => 'https://github.com/asharpe/vagrant-hostmanager.git'
		gem 'vagrant-env', :git => 'https://git.bne.squiz.net.au/vagrant-env'
		gem 'vagrant-scp', :git => 'https://github.com/asharpe/vagrant-scp.git'
	EOF
	bundle install
}
export -f rvm_init



