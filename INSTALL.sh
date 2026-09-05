#!/bin/bash

usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Installs dotfiles: symlinks configs into \$HOME, then runs each component
installer (x11-config, .terminal, .vim).

Options:
  --ignore-missing-deps  Skip configs whose dependencies are missing instead of aborting
  --keyboard-shortcuts   Also apply keyboard shortcuts (XFCE + KDE only)
  --help                 Show this help and exit
EOF
}

case " $* " in
  *" --help "*) usage; exit 0 ;;
esac

OPENING_MESSAGE="START: $0"
echo $OPENING_MESSAGE

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

# switch to HOME directory
cd $(dirname $0); __DIR__=$(pwd)

. "$__DIR__/lib/common.sh"

# Volta (node version manager): install if missing, then ensure latest node
if ! command -v volta >/dev/null 2>&1; then
  apt_install curl
  echo "Installing volta (node version manager)..."
  curl -sSf https://get.volta.sh | bash
  export PATH="$HOME/.volta/bin:$PATH"
fi
volta install node@latest

# --ignore-missing-deps: skip configs whose dependencies are missing instead
# of aborting. Exported so sub-installers inherit it.
IGNORE_MISSING_DEPS=0
POSITIONAL=()
for ARG in "$@"; do
  case "$ARG" in
    --ignore-missing-deps) IGNORE_MISSING_DEPS=1 ;;
    *) POSITIONAL+=("$ARG") ;;
  esac
done
export IGNORE_MISSING_DEPS

# Exit if any child script fails
INSTALL_SCRIPTS=()
INSTALL_SCRIPTS+=("$__DIR__/x11-config/INSTALL.sh")
INSTALL_SCRIPTS+=("$__DIR__/.terminal/INSTALL.sh")
INSTALL_SCRIPTS+=("$__DIR__/.vim/INSTALL.sh")

# opt-in: apply keyboard shortcuts (XFCE + KDE)
if [[ " ${POSITIONAL[*]} " == *" --keyboard-shortcuts "* ]]; then
  INSTALL_SCRIPTS+=("$__DIR__/keyboard-shortcuts/install.sh")
fi

for SCRIPT in "${INSTALL_SCRIPTS[@]}"; do
  echo -e "\n"
  echo "START SUBSCRIPT: $SCRIPT"

  # Source each script individually
  $SCRIPT
  return_code=$?

  # Check if the last command in the sourced script was successful
  if [ $return_code -ne 0 ]; then
    ERROR_MESSAGE="ERROR: $SCRIPT"
    echo -e "\033[31m$ERROR_MESSAGE\033[0m"
    exit 1
  fi

  SUCCESS_MESSAGE="SUCCESS: $SCRIPT"
  echo -e "\033[0;32m$SUCCESS_MESSAGE\033[0m"
done

echo -e "\n"
CLOSING_MESSAGE="DONE: $0"
echo -e "$CLOSING_MESSAGE"
