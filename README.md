# Dotfiles

Linux and macOS dotfiles. Forked from [Cowboy's dotfiles](https://github.com/cowboy/dotfiles), by way of [ASharpe's dotfiles](https://github.com/asharpe/dotfiles). A more detailed background is in [HISTORY][HISTORY].

[HISTORY]: HISTORY.md


## About this project

[dotfiles]: bin/dotfiles

A single command, [dotfiles][dotfiles], to "bootstrap" a new `${HOME}` directory and pull down personal dotfiles and config's, as well as install the tools I commonly use. 

[dotfiles][dotfiles] may be re-executed at any time to synchronize anything that might have changed (e.g. after a `git pull` of this repo, or to install a new tool listed in one of the Init steps).

Additionally, having this on a central github repo makes it easy to re-integrate changes back in (via `git push`) so that other machines can be updated by re-synchronizing.


## How the "dotfiles" command works

When [dotfiles][dotfiles] is run for the first time, it does a few things:

1. If necessary, **git** is installed via the native OS package manager
1. This repo is cloned into your `${HOME}` directory (`~/`), under `${DOTFILES}` (`~/.dotfiles/`, unless you change it in [dotfiles](bin/dotfiles#L24)).
1. Files in `copy/` are copied into `~/`. ([read more](#the-copy-step))
1. Files in `link/` are symlinked into `~/`. ([read more](#the-link-step))
1. You are prompted to choose scripts in `init/` to be executed. The installer attempts to only select relevant scripts, based on the detected OS and the script filename.
1. Your chosen init scripts are executed (in alphanumeric order, hence the funky names). ([read more](#the-init-step))

On subsequent runs, step 1 is skipped, step 2 just updates the already-existing repo, and step 5 remembers what you selected the last time. The other steps are the same.


### Other subdirectories

* The `backups/` directory gets created when necessary. Any files in `~/` that would have been overwritten by files in `copy/` or `link/` get backed up here.
* The `bin/` directory contains executable shell scripts (including the [dotfiles][dotfiles] script) and symlinks to executable shell scripts. This directory is added to the `$PATH`.
* The `caches/` directory contains cached files, used by some scripts or functions.
* The `conf/` directory just exists. If a config file doesn't **need** to go in `~/`, reference it from the `conf/` directory.
* The `source/` directory contains files that are `source`d whenever a new shell is opened (in alphanumeric order, hence the funky names).
* The `test/` directory contains unit tests for especially complicated bash functions.
* The `vendor/` directory contains third-party libraries.


### The "copy" step
Any file in the `copy/` subdirectory will be copied into `~/`. Any file that _needs_ to be modified with **personal or private information** (like [copy/.gitconfig](copy/.gitconfig) which contains an email address and private key) should be _copied_ into `~/`, and then updated _manually_ to add the private information.  Because the file you'll be editing is a _copy_ and no longer in `~/.dotfiles/`, it's less likely to be accidentally committed into your public dotfiles repo.


### The "link" step
Any file in the `link/` subdirectory gets symlinked into `~/` with `ln -s`. Edit one or the other, and you change the file in both places. **Don't link files containing sensitive data**, or you might accidentally commit those data! If you're linking a directory that might contain sensitive data (like `~/.ssh/`) add the sensitive files to your [.gitignore](.gitignore) file!


### The "init" step
Scripts in the `init/` subdirectory will be executed whenever [dotfiles][dotfiles] is executed.  A whole bunch of things will be installed, but _only_ if they aren't already.

#### macOS (OS X)

* Minor XCode init via the [init/10_osx_xcode.sh](init/10_osx_xcode.sh) script
* Homebrew via the [init/20_osx_homebrew.sh](init/20_osx_homebrew.sh) script
* Homebrew recipes via the [init/30_osx_homebrew_recipes.sh](init/30_osx_homebrew_recipes.sh) script
* Homebrew casks via the [init/30_osx_homebrew_casks.sh](init/30_osx_homebrew_casks.sh) script
* [Fonts](/cowboy/dotfiles/tree/master/conf/osx/fonts) via the [init/50_osx_fonts.sh](init/50_osx_fonts.sh) script


#### Ubuntu
* APT packages and git-extras via the [init/20_ubuntu_apt.sh](init/20_ubuntu_apt.sh) script


#### Both
* System-wide iPython, pip, virtualenv, and other tools via the [init/50_python.sh](init/50_python.sh) script
* Node.js, npm and nave via the [init/50_node.sh](init/50_node.sh) script
* Ruby, gems and rbenv via the [init/50_ruby.sh](init/50_ruby.sh) script
* Vim plugins via the [init/50_vim.sh](init/50_vim.sh) script


## Hacking dotfiles

Because the [dotfiles][dotfiles] script is completely self-contained, you should be able to delete everything else from your dotfiles repo fork, and it will still work. The only thing it really cares about are the `copy/`, `link/` and `init/` subdirectories, which will be ignored if they are empty or don't exist.

If you modify things and notice a bug or an improvement, [file an issue](https://github.com/cowboy/dotfiles/issues) or [a pull request](https://github.com/cowboy/dotfiles/pulls) and let Cowboy know (better that you fork from [Cowboy's repo](https://github.com/cowboy/dotfiles) than mine as well, by the way).

Also, before installing, be sure to [read the gently-worded note](#heed-this-critically-important-warning-before-you-install).


## Installation


### macOS Notes

You need to have [XCode](https://developer.apple.com/downloads/index.action?=xcode) or, at the very minimum, the [XCode Command Line Tools](https://developer.apple.com/downloads/index.action?=command%20line%20tools), which are available as a much smaller download.

The easiest way to install the XCode Command Line Tools in OSX 10.9+ is to open up a terminal, type `xcode-select --install` and [follow the prompts](http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/).

_Tested in OSX 10.10_


### Ubuntu Notes

You might want to set up your ubuntu server [like Cowboy does it](https://github.com/cowboy/dotfiles/wiki/ubuntu-setup), but then again, you might not.

Either way, you should at least update/upgrade APT with `sudo apt-get -qq update && sudo apt-get -qq dist-upgrade` first.

_Tested in Ubuntu 14.04 LTS_


### Heed this critically important warning before you install

**If you're not me, please _do not_ install dotfiles directly from this repo!**

Why? Because I often completely break this repo while updating. Which means that if I do that and you run the `dotfiles` command, your home directory will burst into flames, and you'll have to go buy a new computer. No, not really, but it will be very messy.


### Actual installation (for you)

1. [Read the gently-worded note](#heed-this-critically-important-warning-before-you-install)
1. Fork [Cowboy's dotfiles](https://github.com/cowboy/dotfiles)
1. Open a terminal/shell and do this:
```sh
export github_user=YOUR_GITHUB_USER_NAME

bash -c "$(curl -fsSL https://raw.github.com/$github_user/dotfiles/master/bin/dotfiles)" && source ~/.bashrc
```

Since you'll be using the [dotfiles][dotfiles] command on subsequent runs, you'll only have to export the `github_user` variable for the initial install.

There's a lot of stuff that requires admin access via `sudo`, so be warned that you might need to enter your password here or there.

There's an optional step you can do after installing: you can add this repo as a git remote, so that you can look at my own changes which are different to Cowboy's, and cherry pick commits or just copy in the parts you like:
```sh
git remote add sinewalker git@github.com:sinewalker/dotfiles.git
```
 (There are other remotes that you may find interesting too, see [remotes.txt][remotes.txt], which was produced from the following git command)
```sh
git remote -v > remotes.txt
```
[remotes.txt]:remotes.txt


### Actual installation (for me)

1. Download [dotfiles][dotfiles] and source it:

  ```sh
  bash -c "$(curl -fsSL https://goo.gl/PR0ocr)" && source ~/.bashrc
  ```
  
2. Add my [git remotes][remotes.txt] to the new clone:

  ```sh
  cd ${DOTFILES}
  awk '/fetch/{print "git remote add " $1 " " $2}' < remotes.txt | bash
  ```
  
3. Edit [copied files](copy) (see `${DOTFILES}/copy` for which files in `${HOME}` will require edits). **Or** restore these from a **private backup**.


## Aliases and Functions

To keep things easy, the `~/.bashrc` and `~/.bash_profile` files are extremely simple, and should never need to be modified.  Instead, aliases, functions, settings, etc are sourced from one of the files in the `source/` subdirectory. They're all automatically sourced when a new shell is opened. Take a look, there are [a lot of aliases and functions](source).  There is even a [fancy prompt](source/50_prompt.sh) that shows the current directory, time and current git/svn repo status.


## Scripts
In addition to the [dotfiles][dotfiles] script, there are a few other [bin scripts](bin). This includes [nave](https://github.com/isaacs/nave), which is a [git submodule](vendor).

* [dotfiles][dotfiles] - (re)initialize dotfiles. It might ask for your password (for `sudo`).
* [src](link/.bashrc#L8-18) - (re)source all files in `source/` directory
* Look through the [bin](bin) subdirectory for a few more.


## Prompt
[Cowboy's bash prompt](source/50_prompt.sh) is awesome. It shows git and svn repo status, a timestamp, error exit codes, and even changes color depending on how you've logged in.

Git repos display as **[branch:flags]** where flags are:

**?** untracked files  
**!** changed (but unstaged) files  
**+** staged files

SVN repos display as **[rev1:rev2]** where rev1 and rev2 are:

**rev1** last changed revision  
**rev2** revision

Check it out:

![Cowboy's bash prompt](http://farm8.staticflickr.com/7142/6754488927_563dd73553_b.jpg)


## Inspiration
<https://github.com/gf3/dotfiles>  
<https://github.com/mathiasbynens/dotfiles>  
(and 15+ years of accumulated crap)


## License
Copyright © 2014,2016 "Cowboy" Ben Alman
Licensed under the [MIT license][LICENSE-MIT].
[LICENSE-MIT]: LICENSE-MIT

_Identified Portions_ Copyright © 2005,2007-2009,2013,2014,2016-2017 Michael Lockhart
Licensed under the [Creative Commons CC-by-4.0 License](https://creativecommons.org/licenses/by/4.0/)
