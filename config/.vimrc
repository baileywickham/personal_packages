"sets powerline to turn on
set laststatus=2
set showcmd
set cursorline

"Key remaps
"inoremap hh <esc>
nnoremap <F2> :e! ~/.vimrc<CR>
"nore ; :
"nore , ;

set nu "line numbers
set nobackup
set noerrorbells
set autowrite "writes on make
set autoread "reads modified files
set nocompatible
set noswapfile
set hidden
set relativenumber

"Search options
set hlsearch
set smartcase
set incsearch
set wildmenu

"set indent and plugins for filetype
filetype plugin indent on
syntax enable

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

autocmd BufNewFile,BufRead *.h setfiletype c
autocmd BufNewFile,BufRead *.bailey_shell set filetype=sh
set mouse=a
