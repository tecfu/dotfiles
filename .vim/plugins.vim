"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Neo Bundle
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Note: Skip initialization for vim-tiny or vim-small.
if 0 | endif

if has('vim_starting')
  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Custom Plugins Start Here
NeoBundle 'Shougo/vimproc', {
      \ 'build' : {
      \     'windows' : 'make -f make_mingw32.mak',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }


" UML syntax highlighting for scrooloose/vim-slumlord
NeoBundle 'aklt/plantuml-syntax'


NeoBundle 'airblade/vim-gitgutter'


NeoBundle 'altercation/vim-colors-solarized'


NeoBundle 'blindFS/vim-taskwarrior'
"remap <S-j>, <S-k> to switch to tabprev,tabnext
augroup TaskwarriorMapping
    autocmd!
    autocmd FileType taskreport nunmap <buffer> K
augroup END
"autocmd FileType taskreport TwUnmap
"autocmd FileType taskreport unmap <buffer> K 

"autocmd VimEnter * noremap <buffer> <S-j> :tabprev<CR>
"autocmd VimEnter * noremap <buffer> <S-k> :echo 'tabnext'<CR>
"autocmd VimEnter * noremap <buffer> <S-k> :tabnext<CR>


NeoBundle 'bling/vim-airline'
" {{{
"let g:airline_theme='colors/mango.vim'
let g:airline_powerline_fonts=1

"airline themed tabs
"let g:airline#extensions#tabline#enabled = 1

if has("gui_running")
  
endif

function! AirlineOverride(...)
  let g:airline_section_a = airline#section#create(['mode'])
  let g:airline_section_b = airline#section#create_left(['branch'])
  let g:airline_section_c = airline#section#create_left(['%f'])
  let g:airline_section_y = airline#section#create([])
endfunction
autocmd VimEnter * call AirlineOverride()

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_right_sep = '«'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
" }}}


NeoBundle 'brookhong/DBGPavim'


NeoBundle 'Chiel92/vim-autoformat'
let g:formatterpath = ['/usr/local/bin']
"For javascript, install js-beautify externally
"npm install js-beautify -g


NeoBundle 'danro/rename.vim'


NeoBundle 'dhruvasagar/vim-table-mode'


NeoBundle 'ervandew/supertab'
let g:SuperTabDefaultCompletionType = "<c-n>"


"NeoBundle 'farseer90718/vim-taskwarrior'


"Run commands such as go run for the current file with <leader>r or go build and go test for the current package with <leader>b and <leader>t respectively. Display beautifully annotated source code to see which functions are covered with <leader>c. 
NeoBundle 'fatih/vim-go'
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)


NeoBundle 'FooSoft/vim-argwrap'
nnoremap <leader>w :ArgWrap<CR>


NeoBundle 'fs111/pydoc.vim'


NeoBundle 'godlygeek/csapprox'


NeoBundle 'godlygeek/tabular'


"Cool, but just use native vim selection
":help object-select
"Conflicts with vim-multiple-cursors
"NeoBundle 'gorkunov/smartpairs.vim'
"let g:smartpairs_uber_mode=1


NeoBundle 'heavenshell/vim-jsdoc'


NeoBundle 'hhvm/vim-hack'


NeoBundle 'int3/vim-extradite'


NeoBundle 'itchyny/calendar.vim'


"NeoBundle 'kien/ctrlp.vim'
 

NeoBundle 'Lokaltog/vim-easymotion'
"{{{
let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Bi-directional find motion
" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap f <Plug>(easymotion-s)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
"nmap f <Plug>(easymotion-s2)

" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1
"}}}


NeoBundle 'majutsushi/tagbar'
"{{{
nmap t :TagbarToggle<CR>

"Open tagbar automatically if you're opening Vim with a supported file type
"autocmd VimEnter * nested :call tagbar#autoopen(1)

"Open Tagbar only for specific filetypes
"autocmd FileType c,cpp nested :TagbarOpen

"}}}


NeoBundle 'maksimr/vim-jsbeautify'


NeoBundle 'marijnh/tern_for_vim', {
    \ 'build' : {
    \   'unix': 'sh -c "(cd $PWD/bundle/tern_for_vim; npm install)"',
    \   'mac': '(cd $PWD/bundle/tern_for_vim; npm install)',
    \   'win': '(cd $PWD/bundle/tern_for_vim; npm install)' 
    \    }
    \ }
"Awesome feature if your machine can handle it.
let g:tern_show_argument_hints = 'on_move'
"let g:tern_show_argument_hints=0


NeoBundle 'MattesGroeger/vim-bookmarks'


NeoBundle 'mattn/emmet-vim'


NeoBundle 'moll/vim-node'


NeoBundle 'mxw/vim-jsx'


NeoBundle 'nathanaelkane/vim-indent-guides'


"Must be manually triggered by M:/ when SearchComplete plugin enabled
NeoBundle 'othree/eregex.vim'
let g:eregex_default_enable = 0
let g:eregex_force_case = 1
let g:eregex_forward_delim = '/'
let g:eregex_backward_delim = '?'


NeoBundle 'pangloss/vim-javascript'
let b:javascript_fold = 1


NeoBundle 'm2mdas/phpcomplete-extended'
"{{{
let g:phpcomplete_index_composer_command = "composer"
"}}}


"Cool plugin, but useless in terminal vim because no alt key
" NeoBundle 'matze/vim-move'


" Recommended: sudo -S apt-get install silversearcher-ag
NeoBundle 'mileszs/ack.vim'
if executable('ag')
 let g:ackprg = 'ag --vimgrep'
endif


NeoBundle 'mustache/vim-mustache-handlebars'


NeoBundle 'Peeja/vim-cdo'


NeoBundle 'scrooloose/vim-slumlord'


" NeoBundle 'scrooloose/syntastic', {
"     \ 'build' : {
"     \   'unix': 'sh -c "npm install eslint -g"',
"     \   'mac': 'npm install eslint -g',
"     \   'win': 'npm install eslint -g' 
"     \    }
"     \ }

NeoBundle 'scrooloose/syntastic', {
    \ 'build' : {
    \   'unix': 'sh -c "npm install jshint -g"',
    \   'mac': 'npm install jshint -g',
    \   'win': 'npm install jshint -g' 
    \    }
    \ }


"{{{
"Check if plugin loaded
if !empty(glob("~/.vim/bundle/syntastic/plugin/syntastic.vim")) 
	"echo "Syntastic Loaded..."
	set statusline+=%#warningmsg#
	set statusline+=%{SyntasticStatuslineFlag()}
	set statusline+=%*

	let g:syntastic_always_populate_loc_list = 1
	let g:syntastic_auto_loc_list = 1
	let g:syntastic_check_on_open = 1
	let g:syntastic_check_on_wq = 0
  let g:syntastic_reuse_loc_lists = 1

" javascript	
"	let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_checkers = ['jshint']

" java
	"let g:syntastic_java_checker = 'javac'
	
" manage custom filetypes
	augroup filetype
			autocmd! BufRead,BufNewFile  *.gradle  set filetype=gradle
	augroup END

	let g:syntastic_filetype_map = { "gradle": "java" }

	set sessionoptions-=blank
endif

" Set location list height to 3 lines
let g:syntastic_loc_list_height=3
"}}}

" Use deoplete with nvim
if has("nvim")
	NeoBundle 'Shougo/deoplete.nvim'
	let g:deoplete#enable_at_startup = 1
" Use neomplete with vim
else
	NeoBundle 'Shougo/neocomplete'

	"{{{
	"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
	" => Shougo/neocomplete Plugin
	"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
	"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
	" Disable AutoComplPop.
	let g:acp_enableAtStartup = 0
	" Use neocomplete.
	let g:neocomplete#enable_at_startup = 1
	" Use smartcase.
	let g:neocomplete#enable_smart_case = 1
	" Set minimum syntax keyword length.
	let g:neocomplete#sources#syntax#min_keyword_length = 3
	let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

	" Define dictionary.
	let g:neocomplete#sources#dictionary#dictionaries = {
	\ 'default' : '',
	\ 'vimshell' : $HOME.'/.vimshell_hist',
	\ 'scheme' : $HOME.'/.gosh_completions'
	\ }

	" Define keyword.
	if !exists('g:neocomplete#keyword_patterns')
	let g:neocomplete#keyword_patterns = {}
	endif
	let g:neocomplete#keyword_patterns['default'] = '\h\w*'

	" Plugin key-mappings.
	inoremap <expr><C-g>     neocomplete#undo_completion()
	inoremap <expr><C-l>     neocomplete#complete_common_string()

	" Recommended key-mappings.
	" <CR>: close popup and save indent.
	"inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
	function! s:my_cr_function()
	return neocomplete#close_popup() . "\<CR>"
	" For no inserting <CR> key.
	"return pumvisible() ? neocomplete#close_popup() : "\<CR>"
	endfunction

	" <TAB>: completion.
	inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
	" <C-h>, <BS>: close popup and delete backword char.
	inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
	inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
	inoremap <expr><C-y>  neocomplete#close_popup()
	inoremap <expr><C-e>  neocomplete#cancel_popup()
	
	" Enable omni completion.
	autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
	autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
	autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
	autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
	autocmd FileType php setlocal omnifunc=phpcomplete#CompletePHP
	" autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
	" autocmd FileType javascript setlocal omnifunc=tern#Complete

	" Enable heavy omni completion.
	if !exists('g:neocomplete#sources#omni#input_patterns')
		let g:neocomplete#sources#omni#input_patterns = {}
	endif
	"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
	"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
	"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
	let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
	"let g:neocomplete#sources#omni#input_patterns.javascript = '[^. \t]\.\w*'
	"}}}

	if !exists('g:neocomplete#force_omni_input_patterns')
		let g:neocomplete#force_omni_input_patterns = {}
	endif
	let g:neocomplete#force_omni_input_patterns.go = '[^.[:digit:] *\t]\.'

endif

NeoBundle 'Shougo/neomru.vim'


NeoBundle 'Shougo/neoyank.vim'


NeoBundle 'Shougo/unite.vim'
"{{{
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Shougo/unite.vim Plugin
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable history yank source
let g:unite_source_history_yank_enable = 1

let g:unite_update_time = 1000

" set up mru limit
let g:unite_source_file_mru_limit = 5

" highlight like my vim
let g:unite_cursor_line_highlight = 'CursorLine'

" format mru
let g:unite_source_file_mru_filename_format = ':~:.'
let g:unite_source_file_mru_time_format = ''

" set up  arrow prompt
let g:unite_prompt = '➜ '

" Save session automatically.
let g:unite_source_session_enable_auto_save = 1

" Unite Commands ===============================================================

" No prefix for unite, leader that bish
" nnoremap [unite] <Nop>

" scroll through available files
" nnoremap <silent> <leader>n :Unite buffer file file_mru -auto-preview<CR>
nnoremap <silent> <leader>f :Unite buffer file file_mru<CR>

" key search through available files
nnoremap <silent> <leader>s :<C-u>Unite -no-split file -start-insert<CR>

" ;f Fuzzy Find Everything
" files, Buffers, recursive async file search
" nnoremap <silent> <leader>d :<C-u>Unite -buffer-name=files file_rec/async<CR>

" ;y Yank history
" Shows all your yanks, when you accidentally overwrite
nnoremap <silent> <leader>y :<C-u>Unite -buffer-name=yanks history/yank<CR>

" ;o Quick outline, see an overview of this file
nnoremap <silent> <leader>o :<C-u>Unite -buffer-name=outline -vertical outline<CR>

" ;m MRU All Vim buffers, not file buffer
nnoremap <silent> <leader>m :<C-u>Unite -buffer-name=mru file_mru<CR>

" ;b view open buffers
nnoremap <silent> <leader>b :<C-u>Unite -buffer-name=buffer buffer<CR>

" B
" ;c Quick commands, lists all available vim commands
" nnoremap <silent> <leader>c :<C-u>Unite -buffer-name=commands command<CR>


" Unite motions ================================================================

" Function that only triggers when unite opens
autocmd FileType unite call s:unite_settings()

function! s:unite_settings()
  
  setlocal modifiable

  " Play nice with supertab
  "let b:SuperTabDisabled=1

  " Support autocompletion with tab at cost of actions menu
  "imap <silent><buffer> <tab> <c-x><c-f>
  " iunmap <silent><buffer> <c-n>
  " iunmap <silent><buffer> <c-p>
  imap <silent><buffer> <Tab>   <Plug>SuperTabForward
  imap <silent><buffer> <S-Tab>  <Plug>SuperTabBackward
  nnoremap <silent><buffer> <S-Tab> <Plug>SuperTabBackward
  "imap <buffer> <S-Tab> <c-p>

	
	" exit with esc
  " nmap <buffer> <ESC> <Plug>(unite_exit)
  " imap <buffer> <ESC> <Plug>(unite_exit)

  " Ctrl jk mappings
  nmap <buffer> <C-j> 5j
	nmap <buffer> <C-k> 5k

  " Enable navigation with shift-j and shift-k in insert mode
  imap <buffer> <S-j>  <Plug>(unite_select_next_line)
  imap <buffer> <S-k>  <Plug>(unite_select_previous_line)
  
  " refresh unite
  nmap <buffer> <C-r> <Plug>(unite_redraw)
  "imap <buffer> <C-r> <Plug>(unite_redraw)

  " split control
  inoremap <silent><buffer><expr> <C-s> unite#do_action('split')
  nnoremap <silent><buffer><expr> <C-s> unite#do_action('split')
  inoremap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  nnoremap <silent><buffer><expr> <C-v> unite#do_action('vsplit')

	"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
	" => Shougo/unite.vim Plugin Postprocessing
	"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
	"{{{
	" Use the fuzzy matcher for everything
	call unite#filters#matcher_default#use(['matcher_fuzzy'])

	" Use the rank sorter for everything
	call unite#filters#sorter_default#use(['sorter_rank'])

	" Set up some custom ignores
	call unite#custom_source('file_rec,file_rec/async,file_mru,file,buffer,grep',
				\ 'ignore_pattern', join([
				\ '\.git/',
				\ 'git5/review/',
				\ 'google/obj/',
				\ 'tmp/',
				\ 'lib/Cake/',
				\ 'node_modules/',
				\ 'vendor/',
				\ 'Vendor/',
				\ 'app_old/',
				\ 'acf-laravel/',
				\ 'plugins/',
				\ 'bower_components/',
				\ '.sass-cache',
				\ 'web/wp',
				\ ], '\|'))
	"}}}


" Unite custom menus ================================================================

	" Fugitive menu in Unite (depends on both Fugitive and Unite.vim) {{{
	let g:unite_source_menu_menus = {}
	let g:unite_source_menu_menus.git = {}
	let g:unite_source_menu_menus.git.description = 'git (Fugitive)'
	let g:unite_source_menu_menus.git.command_candidates = [
			\['▷ git status       (Fugitive)',
					\'Gstatus'],
			\['▷ git diff         (Fugitive)',
					\'Gdiff'],
			\['▷ git commit       (Fugitive)',
					\'Gcommit'],
			\['▷ git log          (Fugitive)',
					\'exe "silent Glog | Unite quickfix"'],
			\['▷ git blame        (Fugitive)',
					\'Gblame'],
			\['▷ git stage        (Fugitive)',
					\'Gwrite'],
			\['▷ git checkout     (Fugitive)',
					\'Gread'],
			\['▷ git rm           (Fugitive)',
					\'Gremove'],
			\['▷ git mv           (Fugitive)',
					\'exe "Gmove " input("destino: ")'],
			\['▷ git push         (Fugitive, output buffer)',
					\'Git! push'],
			\['▷ git pull         (Fugitive, output buffer)',
					\'Git! pull'],
			\['▷ git prompt       (Fugitive, output buffer)',
					\'exe "Git! " input("comando git: ")'],
			\['▷ git cd           (Fugitive)',
					\'Gcd'],
			\]
" }}}

endfunction
"}}}

 
NeoBundle 'Shougo/vimshell'
" {{{
let g:vimshell_user_prompt = 'fnamemodify(getcwd(), ":~")'
let g:vimshell_prompt =  '$ '
" open new splits actually in new tab
let g:vimshell_split_command = "tabnew"

if has("gui_running")
  let g:vimshell_editor_command = "gvim"
endif

" use same keybindings to go forward and back in prompt as in vim bash
"inoremap <buffer> <S-k>  <Plug>(vimshell_previous_prompt)
"inoremap <buffer> <S-j>  <Plug>(vimshell_next_prompt)
"}}}


NeoBundle 'shawncplus/phpcomplete.vim'


NeoBundle 'sickill/vim-pasta'


NeoBundle 'sidorares/node-vim-debugger',{
      \ 'build' : {
      \     'windows' : 'npm i vimdebug -g',
      \     'cygwin' : 'npm i vimdebug -g',
      \     'mac' : 'npm i vimdebug -g',
      \     'unix' : 'npm i vimdebug -g',
      \    },
      \ }


NeoBundle 'StanAngeloff/php.vim'


NeoBundle 'terryma/vim-multiple-cursors'


NeoBundle 'tomtom/tcomment_vim'


"NeoBundle 'tpope/vim-abolish'
"Abolish overwrites :S command in othree/eregex.vim


NeoBundle 'tpope/vim-fugitive'
"Open split windows vertically
set diffopt+=vertical


NeoBundle 'tpope/vim-obsession'
"{{{

" Sessions
" Using Tim Pope's Obsession Plugin
" automatically restore when session found.
function! RestoreSess()
  if filereadable(".vim/session.vim")
    source .vim/session.vim
  else
    exec 'echo "Warning: No vim session available to restore"'
  endif
endfunction

" autocmd VimEnter * call RestoreSess()
"}}}

NeoBundle 'tpope/vim-surround'


"Fork
"This plugin hijacks the search mappings /,? and thus
"other plugins that augment search won't work right
"i.e. othree/eregex
NeoBundle 'Dewdrops/SearchComplete'
"NeoBundle 'vim-scripts/SearchComplete'


"Fucking cool, but using <leader>y w/ Shougo/Unite instead.
"Seems to conflict with issuing [count] macros
"NeoBundle 'vim-scripts/YankRing.vim'


" End custom plugins
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

