#!/usr/bin/env bash

source ${DOTFILES}/source/10_meta.sh
source ${DOTFILES}/source/50_ruby.sh


# https://about.gitlab.com/handbook/git-page-update/  with some tweeks

gpg2 --list-keys|grep RVM || gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

echo RUBY_DIR: $RUBY_DIR
echo RVM_DIR:  $RVM_DIR

# Install RVM -- Note that source/50_ruby.sh sets RVM_DIR to the right place
curl -sSL https://get.rvm.io | bash -s stable

