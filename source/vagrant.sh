vagrant_init ()
{
	[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" || return 1;
	[[ -f ./.rvmrc ]] && {
		source ./.rvmrc;
		return 0
	};
	[[ -z "$1" ]] && {
		echo "Project name required";
		return 1
	};
	local PROJECT_DIR="$1";
	local RVMRC="$PROJECT_DIR"/.rvmrc;
	! [[ -d "$PROJECT_DIR" ]] && mkdir -p "$PROJECT_DIR";
	cat  > "$RVMRC" <<-EOF
# see https://rvm.io/rvm/best-practices#no-3-use-per-project-gemsets
rvm use "ruby-1.9.3@${PROJECT_DIR}" --create
alias vagrant="bundle exec vagrant"
alias irb="bundle exec irb"
EOF

	cd $PROJECT_DIR;
	source "$(basename "$RVMRC")";
	cat  > Gemfile <<-EOF
source 'http://rubygems.org'
gem 'vagrant', :git => 'https://github.com/mitchellh/vagrant.git', :tag => 'v1.3.5'
gem 'vagrant-env', :git => 'https://git.bne.squiz.net.au/vagrant-env'
gem 'vagrant-scp', :git => 'https://github.com/asharpe/vagrant-scp.git'
EOF

	bundle install
}
