# create config directories if they don't exists
SYMLINKS=()
SYMLINKS+=("$HOME/dotfiles/terminal-config $HOME/.terminal")

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

./terminal-config/INSTALL.sh
./x11-config/INSTALL.sh
./.vimperator/INSTALL.sh
./.vim/INSTALL.sh
vim -c "PlugInstall"
