# Install fonts
# (I only know how to install fonts for these systems)
is_osx || is_suse || return 1

is_osx && FONTDIR=~/Library/Fonts/
is_suse && FONTDIR=~/.fonts
{
	pushd ${DOTFILES}/conf/fonts/; setdiffA=(*.ttf); popd
	pushd ${FONTDIR}; setdiffB=(*.ttf); popd
	setdiff
} >/dev/null

if (( ${#setdiffC[@]} > 0 )); then
  e_header "Copying fonts (${#setdiffC[@]})"
	for F in "${setdiffC[@]}"; do
	  e_arrow "${F}"
    ln -s "${DOTFILES}/conf/fonts/${F}" ${FONTDIR}
	done
  is_suse && su -c "fonts-config --verbose"
fi
