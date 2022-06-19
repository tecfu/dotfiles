## Preamble

This repo includes 2 branches for setup/configuration for Linux. Be sure to checkout the branch appropriate for your use case.

- *linux_x11* 
> In my case, running Xubuntu on a laptop: [XFCE](https://en.wikipedia.org/wiki/Xfce) on top of the the [X Window System](https://en.wikipedia.org/wiki/X_Window_System).

- *linux_server* 
> In my case, running Ubuntu Server


## Installation

```
git clone --recurse-submodules https://github.com/tecfu/dotfiles ~/dotfiles
. ~/dotfiles/INSTALL.sh
```

## Updating

```
$ git submodule update --recursive --remote
```

## Contents

- [Terminal Emulator Config](https://github.com/tecfu/.terminal/tree/server)  

- [Vim Config](https://github.com/tecfu/.vim/tree/server)  

- [Vimperator Config](https://github.com/tecfu/.vimperator/tree/master)  

- [X Window System (.Xmodmap, et.al) Config](https://github.com/tecfu/x11-config/tree/master)

## What each git submodule in this repo does


### Vim

The vim setup here should work on a Mac and even on a Windows box, but I haven't used it in those environments so there may be some tweaking needed. 


### Vimperator

Vimperator is a dead project and I've begrudgingly moved to Vimium, but I'll keep the config here for now anyway as an hommage. Vimperator was incredible.


### Terminal Config

Sets bash to run in vi-mode. Here are a couple articles on that:

- [Working Productively in Bash's Vi Command Line Editing Mode](http://www.catonmat.net/blog/bash-vi-editing-mode-cheat-sheet)

- [Vi mode in Bash](https://sanctum.geek.nz/arabesque/vi-mode-in-bash)


### X-11 Config

This is where I have stored files that allow me to remap hotkeys for Google Chrome which otherwise can't be remapped. Think \<C-j\>, \<C-k\>.


## License

**The MIT License (MIT)**

**Copyright (c) 2010 - 2021 Tecfu**

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
