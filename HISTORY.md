
[The dotfiles project's  original author, Cowboy, had this design and history notes in his README.md.   All first-person referencs are to him. I, Mike ("sinewalker"), came aross it from a work colleage, who forked it from Cowboy and added work-specific things.  I forked it from him (asharpe) for the work things.  My own dotfiles are in GitHub too ("dotfiles-old") but are pretty sad. I think I'll adopt these instead and bring in any functions/aliases I still want.  I use a Mac at work (pretty new to it). The linux flavour I use is SUSE, which may impact my customisations too. Or may not.]

[This `HISTORY.md` file is a place for Cowboy's original design notes and history, which no longer properly belong in my README.md, but which may still be useful to refer to]

----


I've been using bash on-and-off for a long time (since Slackware Linux was distributed on 1.44MB floppy disks). In all that time, every time I've set up a new Linux or OS X machine, I've copied over my `.bashrc` file and my `~/bin` folder to each machine manually. And I've never done a very good job of actually maintaining these files. It's been a total mess.

I finally decided that I wanted to be able to execute a single command to "bootstrap" a new system to pull down all of my dotfiles and configs, as well as install all the tools I commonly use. In addition, I wanted to be able to re-execute that command at any time to synchronize anything that might have changed. Finally, I wanted to make it easy to re-integrate changes back in, so that other machines could be updated.

That command is [dotfiles][dotfiles], and this is my "dotfiles" Git repo.


## Installation


### Ubuntu Notes

You might want to set up your ubuntu server [like I do it](https://github.com/cowboy/dotfiles/wiki/ubuntu-setup), but then again, you might not.

Either way, you should at least update/upgrade APT with `sudo apt-get -qq update && sudo apt-get -qq dist-upgrade` first.

_Tested in Ubuntu 14.04 LTS_

### Heed this critically important warning before you install

**If you're not me, please _do not_ install dotfiles directly from this repo!**

Why? Because I often completely break this repo while updating. Which means that if I do that and you run the `dotfiles` command, your home directory will burst into flames, and you'll have to go buy a new computer. No, not really, but it will be very messy.


### Actual installation (for me)

```sh
bash -c "$(curl -fsSL https://bit.ly/cowboy-dotfiles)" && source ~/.bashrc
```

## Prompt
I think [my bash prompt](https://github.com/cowboy/dotfiles/blob/master/source/50_prompt.sh) is awesome. It shows git and svn repo status, a timestamp, error exit codes, and even changes color depending on how you've logged in.

Git repos display as **[branch:flags]** where flags are:

**?** untracked files  
**!** changed (but unstaged) files  
**+** staged files

SVN repos display as **[rev1:rev2]** where rev1 and rev2 are:

**rev1** last changed revision  
**rev2** revision

Check it out:

![Cowboy's bash prompt](http://farm8.staticflickr.com/7142/6754488927_563dd73553_b.jpg)
