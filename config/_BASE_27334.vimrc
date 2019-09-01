"sets powerline to turn on
set laststatus=2
set showcmd
set cursorline

"Key remaps
inoremap hh <esc>
nnoremap <F2> :e! ~/.vimrc<CR>
nore ; :
nore , ;

set nu "line numbers
set nobackup
set noerrorbells
set autowrite "writes on make
set autoread "reads modified files
set nocompatible
set noswapfile
set hidden

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
"Auto refresh vimrc

call plug#begin('~/.vim/plugged')
" let Vundle manage Vundle, required
Plug 'altercation/vim-colors-solarized'
Plug 'ervandew/supertab'
Plug 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
Plug 'scrooloose/nerdtree'
call plug#end()


set t_Co=256
syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized

map <C-n> :NERDTreeToggle<CR>


