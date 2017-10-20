# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  # We have color support; assume it's compliant with Ecma-48
  # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
  # a case would tend to support setf rather than setaf.)
  color_prompt=yes
    else
  color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export NVM_DIR="/home/base/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Allows ctrl-s, ctrl-q in Vim
stty -ixon > /dev/null 2>/dev/null

# Sets the default CWD
gotocwd(){ 
  # cd "/var/www" ; 
  echo "Predefined current working directory customized in ~/.bashrc" ;
}
gotocwd

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


# Set vimode, Vim as editor
set -o vi

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

# Globstar: The pattern ‘**’ used in a filename expansion context will match all files and zero or more directories and subdirectories. If the pattern is followed by a ‘/’, only directories and subdirectories match.
# To unset use:
# shopt -u globstar
shopt -s globstar


# Open vim within nodejs repl using ".editor" command

## REACT/ANDROID SETUP
#export ANDROID_HOME=/media/shared-1/android-studio/bin
## Run the Gradle daemon for React Android builds
## See (1): https://docs.gradle.org/2.9/userguide/gradle_daemon.html
## See (2): https://facebook.github.io/react-native/releases/0.23/docs/android-setup.html
#touch ~/.gradle/gradle.properties && echo "org.gradle.daemon=true" >> ~/.gradle/gradle.properties
#touch ~/.gradle/gradle.properties && echo "org.gradle.daemon=true" >> ~/.gradle/gradle.properties
