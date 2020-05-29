# Install fonts
# (I only know how to install fonts for these systems)
is_osx || is_suse || is_raspbian || is_ubuntu || return 1

is_osx && FONTDIR=~/Library/Fonts/
is_suse || is_raspbian || is_ubuntu && FONTDIR=~/.fonts
[[ -d ${FONTDIR} ]] || mkdir -p ${FONTDIR}

{
	pushd ${DOTFILES}/misc/fonts/; setdiffA=(*.ttf); popd
	pushd ${FONTDIR}; setdiffB=(*.ttf); popd
	setdiff
} >/dev/null

if (( ${#setdiffC[@]} > 0 )); then
  e_header "Copying fonts (${#setdiffC[@]})"
	for F in "${setdiffC[@]}"; do
	  e_arrow "${F}"
    ln -s "${DOTFILES}/misc/fonts/${F}" ${FONTDIR}
	done
  is_suse && su -c "fonts-config --verbose"
  is_raspbian || is_ubuntu && fc-cache -v
fi
