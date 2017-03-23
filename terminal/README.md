# .bashrc

## Installation

- Install sxhkd https://github.com/baskerville/sxhkd

```
ln -s ~/dotfiles/terminal/.bashrc ~/.bashrc
ln -s ~/dotfiles/terminal/.inputrc ~/.inputrc
ln -s ~/dotfiles/terminal/.xprofile ~/.xprofile
ln -s ~/dotfiles/terminal/chrome_unbind_ctrlj.sh ~/chrome_unbind_ctrlj.sh
ln -s ~/dotfiles/terminal/chrome_unbind_ctrlk.sh ~/chrome_unbind_ctrlk.sh
```

### What this file does:

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

### Checking your terminal for 256 colors:

- Run the file ./256colors2.pl and check for tiled blocks that
represent 256 colors in the output.

## License

**The MIT License (MIT)**

**Copyright (c) 2016 Tecfu**

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
