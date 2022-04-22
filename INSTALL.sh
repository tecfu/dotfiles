# create config directories if they don't exists
SYMLINKS=()
SYMLINKS+=("$HOME/dotfiles/.editorconfig $HOME/.editorconfig")
SYMLINKS+=("$HOME/dotfiles/.ideavimrc $HOME/.ideavimrc")
SYMLINKS+=("$HOME/dotfiles/.terminal $HOME/.terminal")

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

### Check for node
if ! [ -x "$(which node)" ]; then
  echo "WARNING! You must install \"nodejs\" prior to installing due to coc-vim."
  echo "Attempting to install nodejs via nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
fi

cd $(dirname $0); __DIR__=$(pwd)

$__DIR__/.terminal/INSTALL.sh
$__DIR__/x11-config/INSTALL.sh
$__DIR__/.vim/INSTALL.sh
