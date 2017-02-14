# Editing

#Let's jump ahead 20 years and make the default Unix editor be
#Midnight Commander, since I install it everywhere with this repo
export EDITOR=mcedit

#Or, if we're on a 21st century computer, let's default to
#Using Atom if we have it and we're not on a secure shell
if [[ ! "$SSH_TTY" ]] && is_exe atom
then
  EDITOR=atom
fi

alias edit=${EDITOR}

#if 'mc' can launch the whole Midnight Commander, why not these too?
alias mce=mcedit
alias mcv=mcview
alias mcd=mcdiff
alias view=mcview

# configure PAGER/LESS
# stolen from http://merlinmoncure.blogspot.com.au/2007/10/better-psql-with-less.html
export PAGER=less

# -i ignore case in search
# -M long prompt ?
# -S chop long lines
# -x4 tab stop at multiples of 4
# -F quit if one screen
# -X no (de)initialisation (avoids clearing screen etc)
# -R handle colours nicely
export LESS="-iMSx4 -FXR"
