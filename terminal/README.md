# .bashrc

## What this file does:

- Sets up Golang path
- Puts terminal in vi mode
- Adds some vim key mappings

```
# Golang configuration
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Set vimode, Vim as editor
set -o vi
# Set default editor to VIM
export VISUAL=/usr/bin/vim
export EDITOR=/usr/bin/vim
```


### Installation

```
mv .bashrc .bashrc.saved
ln -s ~/dotfiles/terminal/.bashrc ~/.bashrc
mv .inputrc .inputrc.saved
ln -s ~/dotfiles/terminal/.inputrc ~/.inputrc
ln -s ~/dotfiles/terminal/.xprofile ~/.xprofile
```

### Checking your terminal for 256 colors:

- Run the file ./256colors2.pl and check for tiled blocks that
represent 256 colors in the output.

