
#!/bin/bash

###
#   RUN THIS WITH /bin/bash NOT /bin/sh
#   /bin/sh MAPS TO INCOMPATIBLE TERM EMULATORS 
#   IN SOME OS
#   
#   ```
#    $ /bin/bash INSTALL.sh
#   ```
#
###

# declare array
SYMLINKS=()
SYMLINKS+=("$HOME/dotfiles/terminal/.bashrc $HOME/.bashrc")
SYMLINKS+=("$HOME/dotfiles/terminal/.inputrc $HOME/.inputrc")
SYMLINKS+=("$HOME/dotfiles/terminal/.profile $HOME/.profile")
SYMLINKS+=("$HOME/dotfiles/terminal/.xprofile $HOME/.xprofile")
#printf '%s\n' "${SYMLINKS[@]}"
#
for i in "${SYMLINKS[@]}"; do
  #echo $i
  # split each command at the space to get config path
  IFS=' ' read -ra OUT <<< "$i"
  # ${OUT[1]} is path config file should be at
  #no config, create symlink to one
  if [ ! -f "${OUT[1]}" ] && [ ! -L "${OUT[1]}" ]; then
    echo "Creating $i"
    ln -s $i 
  
  #config exsts; save if doesn't point to correct target
  elif [ "$(readlink -- "${OUT[1]}")" != "${OUT[0]}" ]; then
    echo "MOVING ${OUT[1]} to ${OUT[1]}.saved"
    mv "${OUT[1]}" "${OUT[1]}.saved"
    ln -s $i
  fi
done

printf "\n"
echo DONE
