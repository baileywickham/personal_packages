"soloarized plugin
"sets powerline to turn on
set laststatus=2
"shortcuts
set showcmd
set noerrorbells
"set dovark keybindings
noremap d h
noremap h j
noremap t k
noremap n l
inoremap ;; <esc>
nore ; :
nore , ;
nore q e
nore e d

set nu!
set nobackup 
set splitbelow
set splitright
set backspace=indent,eol,start
"window editing.
nnoremap <C-H> <C-W><C-J>
nnoremap <C-T> <C-W><C-K>
nnoremap <C-N> <C-W><C-L>
nnoremap <C-S> <C-W><C-H>
 
"vundle
set nocompatible              " be iMproved, required
filetype off                  " required

"Python syntax defaults. 
filetype plugin indent on

set shiftwidth=4
set expandtab
set tabstop=4


au BufNewFile,BufRead *.py:
    \ set shiftwidth=4
    \ set expandtab   
au BufNewFile,BufRead *.c*,*.h
	\ set tabstop=4
	\ set softtabstop=4
	\ set shiftwidth=4
	\ set noexpandtab
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'ervandew/supertab'
Plugin 'Valloric/YouCompleteMe'
Plugin 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
Plugin 'tpope/vim-fugitive'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-sensible'
Plugin 'tmhedberg/SimpylFold'
"Plugin 'shougo/deoplete.nvim'
"Plugin 'davidhalter/jedi-vim'
call vundle#end()

let g:ycm_python_binary_path='python'
set t_Co=256
syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized

let g:ycm_autoclose_preview_window_after_completion=1
autocmd FileType python setlocal completeopt-=preview

"virtualenv support, no idea if comp with pipenv

py3 << EOF
import os
import sys

if 'VIRTUAL_ENV' in os.environ:
      project_base_dir = os.environ['VIRTUAL_ENV']
      activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
      exec(open(activate_this).read(), dict(__file__=activate_this))
EOF

