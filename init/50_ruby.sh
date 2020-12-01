#!/usr/bin/env bash

source ${DOTFILES}/source/10_meta.sh
source ${DOTFILES}/source/50_ruby.sh

[[ -z ${RBENV_ROOT} ]] && exit 1

# Install RVM -- Note that source/50_ruby.sh sets RVM_DIR to the right place
#curl -sSL https://get.rvm.io | bash -s stable

# While https://about.gitlab.com/handbook/git-page-update/  recommended RVM,
# https://gitlab.com/gitlab-com/www-gitlab-com/-/blob/master/doc/development.md and
# https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/master/doc/prepare.md
# recommend rbenv instead.

# https://github.com/rbenv/rbenv-installer/blob/master/bin/rbenv-installer is 
# a good starting point, but it has a hard-coded install location, and it does
# too much :-\

if is_osx && is_exe brew;  then
    if is_exe rbenv; then
      echo "Updating rbenv and ruby-build with Homebrew..."
      brew update
      brew upgrade rbenv ruby-build
    else
      echo "Installing rbenv and ruby-build with Homebrew..."
      brew install rbenv ruby-build
    fi
else
    #TODO test this and make it re-runnable (or just ansiblize ffs)
    echo "Installing rbenv with git..."
    mkdir -p ${RBENV_ROOT}
    cd ${RBENV_ROOT}
    git init
    git remote add -f -t master origin https://github.com/rbenv/rbenv.git
    git checkout -b master origin/master

    echo "Installing ruby-build with git..."
    mkdir -p "${RBENV_ROOT}/plugins"
    git clone https://github.com/rbenv/ruby-build.git "${RBENV_ROOT}/plugins/ruby-build"
fi

# Enable caching of rbenv-install downloads
mkdir -p "${RBENV_ROOT}/cache"

echo "Running doctor script to verify installation..."
eval "$(rbenv init -)"
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash

#https://github.com/tpope/rbenv-communal-gems
communal_gems=${RBENV_ROOT}/plugins/rbenv-communal-gems

echo -n Communal gems...
if [[ -d ${communal_gems}  ]] ; then
  cd ${communal_gems}
  git pull
else
  mkdir -p ${RBENV_ROOT}/plugins
  git clone git://github.com/tpope/rbenv-communal-gems.git \
    ${RBENV_ROOT}/plugins/rbenv-communal-gems
fi
rbenv communize --all
