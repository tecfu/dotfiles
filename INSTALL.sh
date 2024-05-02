#!/bin/bash

PRODUCT="DOTFILES"

OPENING_MESSAGE="STARTING $PRODUCT CONFIGURATION INSTALL"
echo -e "\033[0;32m$OPENING_MESSAGE\033[0m"

# create symlinks for config directories if they don't exists
SYMLINKS=()
SYMLINKS+=("$HOME/dotfiles/.editorconfig $HOME/.editorconfig")
SYMLINKS+=("$HOME/dotfiles/.ideavimrc $HOME/.ideavimrc")
SYMLINKS+=("$HOME/dotfiles/.terminal $HOME/.terminal")
SYMLINKS+=("$HOME/dotfiles/.vim $HOME/.vim")

for i in "${SYMLINKS[@]}"; do
  #echo $i
  # split each command at the space to get config path
  IFS=" " read -ra OUT <<< "$i"
  if [ ! -d "${OUT[1]}" ] && [ ! -L "${OUT[1]}" ]; then
    ln -s $i 
  
  elif [ "$(readlink -- "${OUT[1]}")" != "${OUT[0]}" ]; then
    mv "${OUT[1]}" "${OUT[1]}.saved"
    ln -s $i
  fi
done

./x11-config/INSTALL.sh

# switch to HOME directory
cd $(dirname $0); __DIR__=$(pwd)

$__DIR__/.terminal/INSTALL.sh
$__DIR__/.vim/INSTALL.sh

CLOSING_MESSAGE="ENDING $PRODUCT CONFIGURATION INSTALL"
echo -e "\033[0;32m$CLOSING_MESSAGE\033[0m"
