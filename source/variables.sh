export EDITOR=vim

# see http://www.starling-software.com/en/blog/sysadmin/2009/02/24.alternate-window-managers-under-gnome-2.24.html
#export WINDOW_MANAGER=xmonad

# see http://thinkingeek.com/2011/11/21/simple-guide-configure-xmonad-dzen2-conky/
#export PATH=$HOME/.cabal/bin:$PATH

# used in ~/.vimrc (at least)
export TMPDIR=/tmp

# mv /usr/local/bin ahead of the others to pick up homebrew
old_path=( $(IFS=$':'; echo ${PATH[*]}) )
new_path=()
for dir in "${old_path[@]}"
do
	[[ $dir = /usr/local/bin ]] && continue
	new_path+=("$dir")
done

# join it all back up
export PATH=$HOME/bin:/usr/local/bin:$(IFS=$':'; echo "${new_path[*]}")

# clean up
unset old_path new_path

