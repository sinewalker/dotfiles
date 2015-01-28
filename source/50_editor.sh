# Editing

export EDITOR='vim'

if [[ ! "$SSH_TTY" ]] && is_osx && type mvim >&/dev/null
then
  export EDITOR='mvim'
  export LESSEDIT='mvim ?lm+%lm -- %f'
fi

# git picks this up and I don't like it
#export VISUAL="$EDITOR"

#alias q="$EDITOR"
#alias qv="q $DOTFILES/link/.{,g}vimrc +'cd $DOTFILES'"
#alias qs="q +'cd $DOTFILES'"
