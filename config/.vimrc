set laststatus=2
set showcmd
set cursorline

"Key remaps
inoremap hh <esc>
nore ; :
nore , ;
noremap! <C-BS> <C-w> "ctrl backspace
noremap! <C-h> <C-w>
nnoremap <F2> :e! ~/.vimrc<CR>

set nu "line numbers
set nobackup
set noerrorbells
set autowrite "writes on make
set autoread "reads modified files
set nocompatible              
set noswapfile
set hidden
filetype off

"Search options
set hlsearch
set smartcase
set incsearch
set wildmenu

"set indent and plugins for filetype
filetype plugin indent on

"set formating
set tabstop=4
set shiftwidth=4
set expandtab
set shiftround "Rounds shift to shiftwidth
set backspace=indent,eol,start

au BufNewFile,BufRead *.py:
			\ set tabstop=4
			\ set shiftwidth=4
			\ set expandtab

autocmd FileType c,cpp setlocal equalprg=clang-format
autocmd BufNewFile,BufRead *.h setfiletype c


call plug#begin('~/.vim/plugged')
" let Vundle manage Vundle, required
Plug 'altercation/vim-colors-solarized'
Plug 'ervandew/supertab'
Plug 'Valloric/YouCompleteMe'
Plug 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
Plug 'scrooloose/nerdtree'
call plug#end()

let g:ycm_python_binary_path='python'
let g:ycm_autoclose_preview_window_after_completion=1

set t_Co=256
syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized

map <C-n> :NERDTreeToggle<CR>



