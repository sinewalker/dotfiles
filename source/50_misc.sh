# Set the terminal's title bar.
function titlebar() {
  echo -n $'\e]0;'"$*"$'\a'
}

# Disable ansible cows }:]
export ANSIBLE_NOCOWS=1
