"===[ Settings ]========================================================

" Use characters instead of numbers for link hints - omit f
:set hintchars=hkasdgyuopqwertnmzxcvb

" Format link hints
:highlight Hint color:white;background-color:#333;padding:0px 2px 0px 2px;

" Autocomplete using Firefox Awesomebar subsystem
set complete=l

" Make Firefox run faster by using JIT
set! javascript.options.jit.chrome=true

" Make bar yellow when focused.
" From: http://www.reddit.com/r/linux/comments/99d55/i_could_use_a_little_vimperator_help_also/
javascript <<EOF
    (function() {
        var inputElement = document.getElementById('liberator-commandline-command');
        function swapBGColor(event) {
            inputElement.style.backgroundColor = event.type == "focus" ? "yellow" : "";
        }
        inputElement.addEventListener('focus', swapBGColor, false);
        inputElement.addEventListener('blur', swapBGColor, false);
    })();
EOF

"===[ Auto commands ]===================================================

" Pass through all keys (like CTRL-Z) on Gmail and Google Reader:
autocmd LocationChange .* :js modes.passAllKeys = /mail\.google\.com|www\.google\.com\/reader\/view/.test(buffer.URL)

"===[ Mappings ]========================================================

" map leader to spacebar
"nnoremap <Space> <nop>
"let mapleader = " "
"let g:mapleader = " "
map <space> <leader>
imap <space><space> <C-O><leader>

" Open external editor with <leader>i while in insert mode,
" since many WYSIWYG editors have <C-i> bound.
inoremap <C-S-i> <C-i>
" js mappings.addUserMap([modes.INSERT], ["<C-S-i>"], "Launch the external editor.", function() { editor.editFieldExternally(); })

" Scroll up/down 20 lines at a time shift+j,shift+k
noremap <C-j> 20j
noremap <C-k> 20k

" Scroll right/left 10 characters
noremap <C-l> 10l 
noremap <C-h> 10h  
 
" Remap home and end to "ctrl+;" and ";" in addition to default "0" and "$"  
noremap <leader>a ^
noremap <leader>; $

" Press 'F10' to toggle Vimperator
noremap <F10> :vimperatortoggle<CR>

" Press 'c' to change to a buffer, instead of 'b'
"noremap c b

" Press 'b' to page up, instead of crazy CTRL-B
"noremap b <PageUp>

" Press 'shift+l' to go forward in history
noremap <S-l> :forward<CR>

" Press 'shift+j' to go to previous tab
noremap <S-j> :tabprevious<CR>

" Press 'shift+k' to go to next tab
noremap <S-k> :tabnext<CR>

" Press 'q' to delete current tab
"noremap q :bdelete<CR>

" Press 'C-a' to select all
noremap <C-a> <C-v><C-a>

"===[ fin ]=============================================================
