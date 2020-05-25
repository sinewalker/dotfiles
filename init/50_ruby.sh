#!/usr/bin/env bash

source ${DOTFILES}/source/10_meta.sh
source ${DOTFILES}/source/50_ruby.sh


# https://about.gitlab.com/handbook/git-page-update/  with some tweeks

# Install RVM -- Note that source/50_ruby.sh sets RVM_DIR to the right place
curl -sSL https://get.rvm.io | bash -s stable

