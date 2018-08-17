set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'kien/ctrlp.vim'

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Alternate between c/h
Plugin 'a.vim'

" Quite usefull to see what is in the file.
"Plugin 'majutsushi/tagbar'

" Tracks ctags really nicelly.
"Plugin 'ludovicchabant/vim-gutentags'

" Usefull. Does tags highlight.
"Plugin 'kendling/taghighlight'

Plugin 'embear/vim-localvimrc'

Plugin 'cofyc/vim-uncrustify'

"Plugin 'tpope/vim-fugitive'

"Plugin 'justmao945/vim-clang'

"Plugin 'octol/vim-cpp-enhanced-highlight'

" All of your Plugins must be added before the following line
call vundle#end()            " required

filetype plugin on    " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

"""""""""""""" configure airline """"""""""""""""""""""

let g:airline_powerline_fonts=1
set laststatus=2

"""""""""""""" configure ctrlp """"""""""""""""""""""

let g:ctrlp_map = '<C-P>'
let g:ctrlp_regexp = 0
let g:ctrlp_by_filename = 1
let g:ctrlp_use_caching = 1
let g:ctrlp_max_files = 10000
let g:ctrlp_max_depth = 100
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_extensions = ['tag', 'buffertag', 'mixed']
let g:ctrlp_match_window = 'top,order:ttb,min:10,max:20:results:20'


"""""""""""""" configure tagbar """"""""""""""""""""""

let g:tagbar_left = 1
let g:tagbar_vertical = 25
let g:tagbar_autoclose = 1
let g:tagbar_show_visibility = 1

let g:localvimrc_sandbox=0
let g:localvimrc_ask=0

"""""""""""""""" config clang auto completion """"""""
let g:clang_diagsopt=''


"""""""""""""" configure intends """"""""""""""""""""""
:set cindent ts=4 sw=4 sts=4 expandtab cino=>6n-2f0^-2{2}0:4g6N-1s(0

"""""""""""""" configure shortcuts """"""""""""""""""""""

" go to previous buffer
:map <A-Left> :bp<CR>
:nmap <A-j> :bp<CR>

" go to next buffer
:map <A-Right> :bN<CR>
:nmap <A-;> :bN<CR>

" open ctrlp in file search mode
":nmap <C-A-r> :CtrlP<CR>

" open ctrlp in tag search mode
":nmap <C-A-t> :CtrlPTag<CR>

" alternate *.h and *.c
:map <C-Tab> :A<CR>

" open the tag bar
:map <F1> :TagbarOpen fjc<ENTER>

" close current buffer. was quit current window
:map <C-W><C-Q> :bd<CR>

autocmd FileType c noremap <buffer> <F2> :call Uncrustify('c')<CR>
autocmd FileType c vnoremap <buffer> <F2> :call RangeUncrustify('c')<CR>
autocmd FileType cpp noremap <buffer> <F2> :call Uncrustify('cpp')<CR>
autocmd FileType cpp vnoremap <buffer> <F2> :call RangeUncrustify('cpp')<CR>

"toggle ON/OFF special chars
:map <F3> :set list!<CR>

" format text  by 80 columns
:map <F8> {j!}fmt<ENTER>}k$

" turn ON spell checker
:map <F6> :set spell<ENTER>

" turn OFF spell checkker
:map <F7> :set spell!<ENTER>


:set listchars=eol:$,tab:>>,space:.,trail:#

:syntax on

:set incsearch

:set encoding=UTF-8

:set nobackup
:set nowritebackup
:set fileformat=unix
:set hlsearch

" Remove trailing spaces on pre-save
:autocmd BufWritePre *.c %s/\s\+$//e
:autocmd BufWritePre *.cpp %s/\s\+$//e
:autocmd BufWritePre *.h %s/\s\+$//e
:autocmd BufWritePre *.hpp %s/\s\+$//e

" replace <tab> -> <space> upon save of c/h
:autocmd BufWritePre *.c set et|retab
:autocmd BufWritePre *.cpp set et|retab
:autocmd BufWritePre *.h set et|retab
:autocmd BufWritePre *.hpp set et|retab


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"   new interesting stuff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Clear current search highlight by double //
nmap <silent> // :nohlsearch<CR>

set tags=tags,./tags;
