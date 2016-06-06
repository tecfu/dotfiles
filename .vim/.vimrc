" ┌───────────────────────────────────┐
" │      vimrc by Tecfu               │
" ├───────────────────────────────────┤
" │ http://github.com/tecfu           │
" └───────────────────────────────────┘


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Sections:
"    -> Load Plugins
"    -> General
"    -> VIM user interface
"    -> Colors and Fonts
"    -> Files, backups, and sessions
"    -> Text, tab and indent related
"    -> Visual mode related
"    -> Moving around, tabs and buffers
"    -> Status line
"    -> Key mappings
"    -> vimgrep searching and cope displaying
"    -> Misc
"    -> Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Load Plugins 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if filereadable($HOME."/.vim/plugins.vim")
  source ${HOME}/.vim/plugins.vim
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Sets how many lines of history VIM has to remember
set history=700

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" map leader to spacebar
"nnoremap <Space> <nop>
"let mapleader = " "
"let g:mapleader = " "
map <space> <leader>
imap <space><space> <C-O><leader>
set showcmd
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" {{{
" Set color column 
set colorcolumn=80

" Text highlight of words that match that under the cursor
" http://stackoverflow.com/questions/1551231/highlight-variable-under-cursor-in-vim-like-in-netbeans
" :autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\')) 

" Avoid garbled characters in Chinese language windows OS
let $LANG='en'
set langmenu=en
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc,.build.*,.so,*.a
if has("win16") || has("win32")
    set wildignore+=*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.hg\*,.svn\*
endif

"Show line numbers
set number

"Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Set incermental search
" Makes search act like search in modern browsers
" This way you can :/findsomething to see all current matches
" and then :%s//replace will use the last command (:/findsomething)
" http://stackoverflow.com/questions/1276403/simple-vim-commands-you-wish-youd-known-earlier?page=1&tab=votes#tab-top
set incsearch

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Add a bit extra margin to the left
set foldcolumn=1

" Code folding
autocmd Filetype vim,md,txt,js setlocal foldmethod=marker
set foldmethod=syntax
set foldlevelstart=4

" Use Vim's persistent undo
" Put plugins and dictionaries in this dir (also on Windows)
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
		let myUndoDir = expand(vimDir . '/undo')
		" Create dirs
		call system('mkdir ' . vimDir)
		call system('mkdir ' . myUndoDir)
		let &undodir = myUndoDir
		set undofile
		set undolevels=1000         " How many undos
		set undoreload=10000        " number of lines to save for undo
endif

"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key mappings """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" ctrl-q to force quit
noremap <C-Q> :qa!<CR>
vnoremap <C-Q> <C-C>:qa!<CR>
inoremap <C-Q> <C-O>:qa!<CR>

" Use CTRL-S for saving
" Must add the following to ~/.bashrc for this to work
" alias vim="stty stop '' -ixoff ; vim"
function! CustomSave()
  "Save the buffer
  "execute 'w!'
  :w!
endfunction
  
"noremap <C-S> :w!<CR>
noremap <C-S> :call CustomSave()<CR>
vnoremap <C-S> <C-C>:call CustomSave()<CR><ESC>
inoremap <C-S> <C-O>:call CustomSave()<CR><ESC>

" Map delete to black hole register
"nnoremap d "_d
"vnoremap d "_d

" Split lines leader+k [This frees up <S-k> for tabnext
noremap <leader>k i<CR><ESC>k

" Join lines on leader+j [This frees up <S-j> for tabprev
noremap <leader>j <S-j>

" Paste after cursor, next line down
"nmap p :pu<CR>

"insert a new-line after the current line by pressing Enter (Shift-Enter for inserting a line before the current line)
nmap <S-Enter> O<Esc>
nmap <CR> o<Esc>

" 'quote' a word
nnoremap qw :silent! normal mpea'<Esc>bi'<Esc>`pl
" double "quote" a word
nnoremap qqw :silent! normal mpea"<Esc>bi"<Esc>`pl
" remove single quotes from a word
nnoremap qd :silent! normal di'hPl2xb<CR>
" remove double quotes from a word
nnoremap qqd :silent! normal di"hPl2xb<CR>

" Map shift+tab to inverse tab
" for command mode
nmap <S-Tab> <<
" for insert mode
"imap <S-Tab> <Esc><<i

" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups, undo, and sessions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬

" Use spaces instead of tabs
" set expandtab

" Make "tab" insert indents instead of tabs at the beginning of a line
set smarttab

" Prefer spaces to tabs and set size to 2
set tabstop=2
set softtabstop=2
set shiftwidth=2
"Use tabs, not spaces
set noexpandtab

" Syntax of these languages is fussy over tabs Vs spaces
autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Linebreak on 500 characters
set lbr
set tw=500

" Indentation tweaks:
set ai "Auto indent
"set si "Smart indent
set wrap "Wrap lines

" reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

" Allow pasting from clipboard without autoindenting
" If your ssh session has X11 forwarding enabled, and the remote terminal Vim has +xclipboard support, then you can use the "+P keystroke to paste directly from the clipboard into Vim.
nnoremap <leader>p :execute 'set noai' <bar> execute 'normal "+p' <bar> execute 'set ai' <CR>
inoremap <C-v> <C-O>:set noai<CR> <C-R>+ <C-O>:set ai<CR>
inoremap <leader>p <C-O>:set noai<CR> <C-R>+ <C-O>:set ai<CR>

" Paste a space in normal mode
" nnoremap <leader>l a<space><esc> 
nnoremap <leader>l $a<space><esc> 

"}}} 

""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
"{{{
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
" --Probably is useful if you don't care about pasting from clipboard. Removed.
" vnoremap <silent> * :call VisualSelection('f', '')<CR>
" vnoremap <silent> # :call VisualSelection('b', '')<CR>
"}}}

  
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{

" Command mode mappings
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-k> <Up>
cnoremap <C-j> <Down>
cnoremap <C-h> <Left>
cnoremap <C-l> <Right>

" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

" Map ctrl+j, ctrl+k to down/up 10 lines
" Scroll up/down 10 lines at a time shift+j,shift+k
noremap <C-j> 10j
noremap <C-k> 10k

" Scroll right/left 10 characters
noremap <C-l> 10l 
noremap <C-h> 10h  

" Remap home and end to "ctrl+;" and ";" in addition to default "1" and "$" 
noremap <leader>a ^
noremap <leader>; $

noremap <C-a> ^
"<C-;> does not map
noremap <C-e> $ 

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Navigation shortcuts for location window
" map <leader>q :lopen <CR>
"	map q :lclose <CR>
map <expr> <C-Down> (empty(getloclist(0))  ? "" : ":lnext")."\n"
map <expr> <C-Up> (empty(getloclist(0))  ? "" : ":lp")."\n"

" Navigation shortcuts for quickfix window
map <expr> <A-Down> (empty(getqflist())  ? "" : ":cnext")."\n"
map <expr> <A-Up> (empty(getqflist())  ? "" : ":cprevious")."\n"

" Move between buffers with keycodes that match vimperator
" shift+h => back, shift+l => forward
noremap <S-h> :bp<CR>
noremap <S-l> :bn<CR>

" Close all the buffers
map <leader>ba :1,1000 bd!<cr>

" Useful mappings for managing tabs
"Overwrites jump to prev tag
"See: http://vim.wikia.com/wiki/Alternative_tab_navigation
map <C-t> :tabnew<CR> 
map <leader>to :tabonly<cr>
map <S-w> :tabclose<cr>
map <leader>tm :tabmove
map <S-k> :tabnext<CR>
map <S-j> :tabprev<CR>

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
   \ if line("'\"") > 0 && line("'\"") <= line("$") |
   \   exe "normal! g`\"" |
   \ endif

" Remember info about open buffers on close
set viminfo^=%

" New splits to appear to the right and to the bottom of the current
set splitbelow
set splitright
"}}}


""""""""""""""""""""""""""""""
" => Color Scheme
""""""""""""""""""""""""""""""
"{{{

" Set extra options when running in GUI mode
if has("gui_running")
  "set guioptions-=T
  "set guioptions-=e
  "set guitablabel=%M\ %t
  colorscheme solarized
  set guifont=monospace\ 11 
  set background=dark
  syntax on
else
	set t_Co=256
	colorscheme mango
  "colorscheme solarized
	"let g:solarized_termcolors=256
  set guifont=monospace\ 11 
  set background=dark
  syntax on
endif
"}}}


""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" {{{
" Always show the status line
set laststatus=2
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
" Remove the Windows ^M - when the encodings gets messed up noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
"}}}


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"{{{
function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("Ack \"" . l:pattern . "\" " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction


" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction
"}}}
