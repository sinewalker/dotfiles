# OSX-only stuff. Abort if not OSX.
is_osx || return 1

# APPLE, Y U PUT /usr/bin B4 /usr/local/bin?!
PATH="/usr/local/bin:$(__path_remove /usr/local/bin)"

#MJL20170204 Homebrew PATH fixes
PATH="/usr/local/sbin:${PATH}"
PATH="/usr/local/opt/openssl/bin:${PATH}"
PATH="/usr/local/opt/grep/libexec/gnubin:${PATH}"
export PATH

#Find the SDK and add it to the CPATH for compiling, see https://github.com/python-pillow/Pillow/issues/3438#issuecomment-543812237
export CPATH=$(xcrun --show-sdk-path)/usr/include

#MJL20190226 Fix osX fork() behaviour to work with Python again
# see https://github.com/ansible/ansible/issues/31869#issuecomment-337769174
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Trim new lines and copy to clipboard
alias c="tr -d '\n' | pbcopy"

# Make 'less' more.
[[ "$(type -P lesspipe.sh)" ]] && eval "$(lesspipe.sh)"

# Start ScreenSaver. This will lock the screen if locking is enabled.
alias ss="open /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app"


#MJL20190210 - squash the CPU-hungry Google Drive File System
alias gdfs='cpulimit -l 2 -p $(pgrep -f "crash_handler_token=")&'
#MJL20191012 - another one: Apple's ReportCrash help runs a lot after Catalina
alias nocrash='cpulimit -l 1 -p $(pgrep -f "ReportCrash")&'

#MJL20200911 Brew library compilation caveats

export PKG_CONFIG_PATH="/usr/local/opt/postgresql@11/lib/pkgconfig"
export PKG_CONFIG_PATH="/usr/local/opt/icu4c/lib/pkgconfig":{$PKG_CONFIG_PATH}
export LD_LIBRARY_PATH="/usr/local/opt/postgresql@11/lib":{$LD_LIBRARY_PATH}
export LD_LIBRARY_PATH="/usr/local/opt/libiconv/lib":{$LD_LIBRARY_PATH}
export LD_LIBRARY_PATH="/usr/local/opt/sqlite/lib":{$LD_LIBRARY_PATH}
export CPP_INCLUDE_PATH="/usr/local/opt/postgresql@11/include"
export CPP_INCLUDE_PATH="/usr/local/opt/libiconv/include":{$CPP_INCLUDE_PATH}
export CPP_INCLUDE_PATH="/usr/local/opt/sqlite/include":{$CPP_INCLUDE_PATH}


# Create a new Parallels VM from template, replacing the existing one.
#function vm_template() {
#  local name="$@"
#  local basename="$(basename "$name" ".zip")"
#  local dest_dir="$HOME/Documents/Parallels"
#  local dest="$dest_dir/$basename"
#  local src_dir="$dest_dir/Templates"
#  local src="$src_dir/$name"
#  if [[ ! "$name" || ! -e "$src" ]]; then
#    echo "You must specify a valid VM template from this list:";
#    shopt -s nullglob
#    for f in "$src_dir"/*.pvm "$src_dir"/*.pvm.zip; do
#      echo " * $(basename "$f")"
#    done
#    shopt -u nullglob
#    return 1
#  fi
#  if [[ -e "$dest" ]]; then
#    echo "Deleting old VM"
#    rm -rf "$dest"
#  fi
#  echo "Restoring VM template"
#  if [[ "$name" == "$basename" ]]; then
#    cp -R "$src" "$dest"
#  else
#    unzip -q "$src" -d "$dest_dir" && rm -rf "$dest_dir/__MACOSX"
#  fi && \
#  echo "Starting VM" && \
#  open -g "$dest"
#}

# Export Localization.prefPane text substitution rules.
#function txt_sub_backup() {
#  local prefs=~/Library/Preferences/.GlobalPreferences.plist
#  local backup=$DOTFILES/conf/osx/NSUserReplacementItems.plist
#  /usr/libexec/PlistBuddy -x -c "Print NSUserReplacementItems" "$prefs" > "$backup" &&
#  echo "File ~${backup#$HOME} written."
#}

# Import Localization.prefPane text substitution rules.
#function txt_sub_restore() {
#  local prefs=~/Library/Preferences/.GlobalPreferences.plist
#  local backup=$DOTFILES/conf/osx/NSUserReplacementItems.plist
#  if [[ ! -e "$backup" ]]; then
#    echo "Error: file ~${backup#$HOME} does not exist!"
#    return 1
#  fi
#  cmds=(
#    "Delete NSUserReplacementItems"
#    "Add NSUserReplacementItems array"
#    "Merge '$backup' NSUserReplacementItems"
#  )
#  for cmd in "${cmds[@]}"; do /usr/libexec/PlistBuddy -c "$cmd" "$prefs"; done
#}
