# vimrc

Configuration files for the Vim editor.

- Setup for development in the following languages: 
	- go
	- nodejs / javascript
	- PHP / Hack

- It includes editor preferences, colorscheme, plugins, custom functions and more.

**This project is my personal vimrc**. Feel free to send me suggestions through the [issues page](https://github.com/tecfu/.vim/issues/new) or to send me improvements through the [pull requests page](https://github.com/tecfu/.vim/pulls).

## Quick start

### Clone this repository into your home directory.

```
git clone git://github.com/tecfu/dotfiles ~/.dotfiles
ln -s ~/.dotfiles/.vim ~/.vim
ln -s ~/.dotfiles/.vim/.vimrc ~/.vimrc
```

### Install NeoBundle

- Ubuntu/Mac

```
$ curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
```

### Disable capturing of Ctrl-S, Ctrl-Q in terminal mode:

- Add the following lines to your .bashrc

```
# Allows ctrl-s, ctrl-q in Vim
stty -ixon > /dev/null 2>/dev/null
```

### [Optional] Remap ESC to CAPS LOCK

- Linux ~/.xmodmap 
```
! Swap caps lock and escape
remove Lock = Caps_Lock
keysym Escape = Caps_Lock
keysym Caps_Lock = Escape
add Lock = Caps_Lock
```

### [Optional]

Configure tern for vim to show argument hints if your machine can handle it.
```
g:tern_show_argument_hints="on_move"
```
Default is g:tern_show_argument_hints=0


### [Optional/Recommended] Install Silver Searcher

```
sudo -S apt-get install silversearcher-ag'
```

### Run Vim

- Before running Vim, export your user password in the terminal to allow NeoBundle to install depedencies. You need only do this prior to install.

### Adding your own plugins

- This .vimrc uses NeoBundle to manage plugin installation. You can add new plugins by appending them to the file: .vimrc.plugins .

- Once you have added a new plugin, you can auto-generate a tabular brief summary in the README.md file by running a grunt task that does this for you:

```
$ grunt
```

If you don't already have grunt installed you'll need to run the following commands:

```
$ npm install grunt -g
$ npm install
$ grunt
```

For more information on grunt see gruntjs.com. 

## Plugin List 

<!---PLUGINS-->
| Name                                                                                              | Description                                                                                                    | Website                                            |
| ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| <a href="http://github.com/airblade/vim-gitgutter">airblade/vim-gitgutter</a>                     | A Vim plugin which shows a git diff in the gutter (sign column) and stages/undoes hunks.                       | http://github.com/airblade/vim-gitgutter           |
| <a href="http://github.com/altercation/vim-colors-solarized">altercation/vim-colors-solarized</a> | precision colorscheme for the vim text editor                                                                  | http://github.com/altercation/vim-colors-solarized |
| <a href="http://github.com/brookhong/DBGPavim">brookhong/DBGPavim</a>                             | This is a plugin to enable php debug in VIM with Xdebug, with a new debug engine.                              | http://github.com/brookhong/DBGPavim               |
| <a href="http://github.com/Chiel92/vim-autoformat">Chiel92/vim-autoformat</a>                     | Provide easy code formatting in Vim by integrating existing code formatters.                                   | http://github.com/Chiel92/vim-autoformat           |
| <a href="http://github.com/danro/rename.vim">danro/rename.vim</a>                                 | Rename the current file in the vim buffer + retain relative path.                                              | http://github.com/danro/rename.vim                 |
| <a href="http://github.com/dhruvasagar/vim-table-mode">dhruvasagar/vim-table-mode</a>             | VIM Table Mode for instant table creation.                                                                     | http://github.com/dhruvasagar/vim-table-mode       |
| <a href="http://github.com/ervandew/supertab">ervandew/supertab</a>                               | Perform all your vim insert mode completions with Tab                                                          | http://github.com/ervandew/supertab                |
| <a href="http://github.com/farseer90718/vim-taskwarrior">farseer90718/vim-taskwarrior</a>         | vim interface for taskwarrior                                                                                  | http://github.com/farseer90718/vim-taskwarrior     |
| <a href="http://github.com/fatih/vim-go">fatih/vim-go</a>                                         | Go development plugin for Vim                                                                                  | http://github.com/fatih/vim-go                     |
| <a href="http://github.com/godlygeek/csapprox">godlygeek/csapprox</a>                             | Make gvim-only colorschemes work transparently in terminal vim                                                 | http://github.com/godlygeek/csapprox               |
| <a href="http://github.com/godlygeek/tabular">godlygeek/tabular</a>                               | Vim script for text filtering and alignment                                                                    | http://github.com/godlygeek/tabular                |
| <a href="http://github.com/gorkunov/smartpairs.vim">gorkunov/smartpairs.vim</a>                   | Fantastic selection for VIM                                                                                    | http://github.com/gorkunov/smartpairs.vim          |
| <a href="http://github.com/heavenshell/vim-jsdoc">heavenshell/vim-jsdoc</a>                       | Generate JSDoc to your JavaScript code.                                                                        | http://github.com/heavenshell/vim-jsdoc            |
| <a href="http://github.com/hhvm/vim-hack">hhvm/vim-hack</a>                                       | Syntax highlighting and typechecker integration for Hack.                                                      | http://github.com/hhvm/vim-hack                    |
| <a href="http://github.com/int3/vim-extradite">int3/vim-extradite</a>                             | A git commit browser for vim. Extends fugitive.vim.                                                            | http://github.com/int3/vim-extradite               |
| <a href="http://github.com/itchyny/calendar.vim">itchyny/calendar.vim</a>                         | A calendar application for Vim                                                                                 | http://github.com/itchyny/calendar.vim             |
| <a href="http://github.com/kien/ctrlp.vim">kien/ctrlp.vim</a>                                     | Fuzzy file, buffer, mru, tag, etc finder.                                                                      | http://github.com/kien/ctrlp.vim                   |
| <a href="http://github.com/Lokaltog/vim-easymotion">Lokaltog/vim-easymotion</a>                   | Vim motions on speed!                                                                                          | http://github.com/Lokaltog/vim-easymotion          |
| <a href="http://github.com/m2mdas/phpcomplete-extended">m2mdas/phpcomplete-extended</a>           | A fast, extensible, context aware autocomplete plugin for PHP composer projects with code inspection features. | http://github.com/m2mdas/phpcomplete-extended      |
| <a href="http://github.com/majutsushi/tagbar">majutsushi/tagbar</a>                               | Vim plugin that displays tags in a window, ordered by scope                                                    | http://github.com/majutsushi/tagbar                |
| <a href="http://github.com/maksimr/vim-jsbeautify">maksimr/vim-jsbeautify</a>                     | vim plugin which formated javascript files by js-beautify                                                      | http://github.com/maksimr/vim-jsbeautify           |
| <a href="http://github.com/marijnh/tern_for_vim">marijnh/tern_for_vim</a>                         | Tern plugin for Vim                                                                                            | http://github.com/marijnh/tern_for_vim             |
| <a href="http://github.com/MattesGroeger/vim-bookmarks">MattesGroeger/vim-bookmarks</a>           | Vim bookmark plugin                                                                                            | http://github.com/MattesGroeger/vim-bookmarks      |
| <a href="http://github.com/mattn/emmet-vim">mattn/emmet-vim</a>                                   | emmet for vim: http://emmet.io/                                                                                | http://github.com/mattn/emmet-vim                  |
| <a href="http://github.com/moll/vim-node">moll/vim-node</a>                                       | Tools and environment to make Vim superb for developing with Node.js. Like Rails.vim for Node.                 | http://github.com/moll/vim-node                    |
| <a href="http://github.com/mustache/vim-mustache-handlebars">mustache/vim-mustache-handlebars</a> | mustache and handlebars mode for vim                                                                           | http://github.com/mustache/vim-mustache-handlebars |
| <a href="http://github.com/mxw/vim-jsx">mxw/vim-jsx</a>                                           | React JSX syntax highlighting and indenting for vim.                                                           | http://github.com/mxw/vim-jsx                      |
| <a href="http://github.com/nathanaelkane/vim-indent-guides">nathanaelkane/vim-indent-guides</a>   | A Vim plugin for visually displaying indent levels in code                                                     | http://github.com/nathanaelkane/vim-indent-guides  |
| <a href="http://github.com/othree/eregex.vim">othree/eregex.vim</a>                               | Perl/Ruby style regexp notation for Vim                                                                        | http://github.com/othree/eregex.vim                |
| <a href="http://github.com/pangloss/vim-javascript">pangloss/vim-javascript</a>                   | Vastly improved Javascript indentation and syntax support in Vim.                                              | http://github.com/pangloss/vim-javascript          |
| <a href="http://github.com/Peeja/vim-cdo">Peeja/vim-cdo</a>                                       | Vim commands to run a command over every entry in the quickfix list (:Cdo) or location list (:Ldo).            | http://github.com/Peeja/vim-cdo                    |
| <a href="http://github.com/rking/ag.vim">rking/ag.vim</a>                                         | Vim plugin for the_silver_searcher, 'ag', a replacement for the Perl module / CLI script 'ack'                 | http://github.com/rking/ag.vim                     |
| <a href="http://github.com/scrooloose/syntastic">scrooloose/syntastic</a>                         | Syntax checking hacks for vim                                                                                  | http://github.com/scrooloose/syntastic             |
| <a href="http://github.com/shawncplus/phpcomplete.vim">shawncplus/phpcomplete.vim</a>             | Improved PHP omnicompletion                                                                                    | http://github.com/shawncplus/phpcomplete.vim       |
| <a href="http://github.com/Shougo/neocomplete">Shougo/neocomplete</a>                             | Next generation completion framework after neocomplcache                                                       | http://github.com/Shougo/neocomplete               |
| <a href="http://github.com/Shougo/neomru.vim">Shougo/neomru.vim</a>                               | MRU plugin includes unite.vim MRU sources                                                                      | http://github.com/Shougo/neomru.vim                |
| <a href="http://github.com/Shougo/unite.vim">Shougo/unite.vim</a>                                 | Unite and create user interfaces                                                                               | http://github.com/Shougo/unite.vim                 |
| <a href="http://github.com/Shougo/vimproc">Shougo/vimproc</a>                                     | Interactive command execution in Vim.                                                                          | http://github.com/Shougo/vimproc                   |
| <a href="http://github.com/Shougo/vimshell">Shougo/vimshell</a>                                   | Powerful shell implemented by vim.                                                                             | http://github.com/Shougo/vimshell                  |
| <a href="http://github.com/sickill/vim-pasta">sickill/vim-pasta</a>                               | Pasting in Vim with indentation adjusted to destination context                                                | http://github.com/sickill/vim-pasta                |
| <a href="http://github.com/sidorares/node-vim-debugger">sidorares/node-vim-debugger</a>           | node.js step by step debugging from vim                                                                        | http://github.com/sidorares/node-vim-debugger      |
| <a href="http://github.com/StanAngeloff/php.vim">StanAngeloff/php.vim</a>                         | Up-to-date PHP syntax file (5.3–5.6 support)                                                                   | http://github.com/StanAngeloff/php.vim             |
| <a href="http://github.com/tecfu/mango.vim">tecfu/mango.vim</a>                                   | A color scheme for vim                                                                                         | http://github.com/tecfu/mango.vim                  |
| <a href="http://github.com/terryma/vim-multiple-cursors">terryma/vim-multiple-cursors</a>         | True Sublime Text style multiple selections for Vim                                                            | http://github.com/terryma/vim-multiple-cursors     |
| <a href="http://github.com/tomtom/tcomment_vim">tomtom/tcomment_vim</a>                           | An extensible & universal comment vim-plugin that also handles embedded filetypes                              | http://github.com/tomtom/tcomment_vim              |
| <a href="http://github.com/tpope/vim-abolish">tpope/vim-abolish</a>                               | abolish.vim: easily search for, substitute, and abbreviate multiple variants of a word                         | http://github.com/tpope/vim-abolish                |
| <a href="http://github.com/tpope/vim-fugitive">tpope/vim-fugitive</a>                             | fugitive.vim: a Git wrapper so awesome, it should be illegal                                                   | http://github.com/tpope/vim-fugitive               |
| <a href="http://github.com/tpope/vim-obsession">tpope/vim-obsession</a>                           | obsession.vim: continuously updated session files                                                              | http://github.com/tpope/vim-obsession              |
| <a href="http://github.com/tpope/vim-surround">tpope/vim-surround</a>                             | surround.vim: quoting/parenthesizing made simple                                                               | http://github.com/tpope/vim-surround               |
| <a href="http://github.com/vim-scripts/matchit.zip">vim-scripts/matchit.zip</a>                   | extended % matching for HTML, LaTeX, and many other languages                                                  | http://github.com/vim-scripts/matchit.zip          |
| <a href="http://github.com/vim-scripts/YankRing.vim">vim-scripts/YankRing.vim</a>                 | Maintains a history of previous yanks, changes and deletes                                                     | http://github.com/vim-scripts/YankRing.vim         |
| <a href="http://github.com/yuratomo/w3m.vim">yuratomo/w3m.vim</a>                                 | w3m plugin for vim                                                                                             | http://github.com/yuratomo/w3m.vim                 |
<!---ENDPLUGINS-->

### Color Scheme

elrodeo		https://github.com/chmllr/elrodeo-colorscheme


### Notes
- Golang shortcuts

```
<leader>r <Plug>(go-run)
<leader>b <Plug>(go-build)
<leader>t <Plug>(go-test)
<leader>c <Plug>(go-coverage)
``` 

## Todo

- When opened, make unite traverse up the directory structure incrementally with each "f" keypress.

## License

**The MIT License (MIT)**

**Copyright (c) 2010 - 2015 Tecfu**

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
