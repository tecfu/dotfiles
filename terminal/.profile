# Allows ctrl-s, ctrl-q in Vim
stty -ixon > /dev/null 2>/dev/null

# Set vimode, Vim as editor
set -o vi
#
# Set default editor to VIM
export VISUAL=/usr/bin/vim
export EDITOR=/usr/bin/vim

#enables binding to \C-e
#doesn't work if done in .inputrc /  vi-command
bind -m vi-move '"\C-e":end-of-line'
# bind -m vi-command '"\C-e":end-of-line'

# @todo Find out why this works if you enter it into the terminal 
# after startup but doesn not work here
# bind '"\C-e":end-of-line'


# Globstar: The pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.
# To unset use:
# shopt -u globstar
shopt -s globstar

############################
# COMMANDS FOR DESKTOP ENV
############################

# Get remote ip address
alias ipv4lookup='dig +short myip.opendns.com @resolver1.opendns.com'
alias ipv6lookup='ip -6 addr'

## REACT/ANDROID SETUP
#export ANDROID_HOME=/media/shared-1/android-studio/bin
## Run the Gradle daemon for React Android builds
## See (1): https://docs.gradle.org/2.9/userguide/gradle_daemon.html
## See (2): https://facebook.github.io/react-native/releases/0.23/docs/android-setup.html
#touch ~/.gradle/gradle.properties && echo "org.gradle.daemon=true" >> ~/.gradle/gradle.properties
#touch ~/.gradle/gradle.properties && echo "org.gradle.daemon=true" >> ~/.gradle/gradle.properties

export NVM_DIR="/home/base/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Sets screen brightness
# run with su -c 'dim'
dim(){
  #make sure user is root
  if [[ $EUID -ne 0 ]]; then
     echo "Command must be run as root" 
     return
  fi
  echo "setb (Set brightness) accepts a number 1-255"
  echo $1 > /sys/class/backlight/radeon_bl0/brightness
  echo "You entered '$1'"
}
export dim

# Converts all .mp4 files in current working directory to mp3
# Useful when desiring to play downloaded YouTube videos in cmus
mp4tomp3(){
  for f in *.mp4
  do
      name=`echo "$f" | sed -e "s/.mp4$//g"`
      ffmpeg -i "$f" -vn -ar 44100 -ac 2 -ab 192k -f mp3 "$name.mp3"
  done
}
export mp4tomp3

# Golang configuration
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Add path for the PHP REPL tool psysh
export PATH="/home/$USER/bin:$PATH"

# Set DBUS_SESSION_BUS_ADDRESS when connecting to remotes via SSH
#if [[ -n $SSH_CLIENT ]]; then
#  NAUTILUS_PID=`pidof nautilus`  
#  if [! NAUTILUS_PID]; then
#    nautilus &
#    NAUTILUS_PID=`pidof nautilus`  
#  fi
#  export DBUS_SESSION_BUS_ADDRESS=`cat /proc/$(NAUTILUS_PID)/environ | tr '\0' '\n' | grep DBUS_SESSION_BUS_ADDRESS | cut -d '=' -f2-`
#  echo NAUTILUS_PID = $NAUTILUS_PID
#fi


