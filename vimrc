"soloarized plugin
let g:solarized_termcolors=256
syntax enable
set background=dark
colorscheme solarized

"sets powerline to turn on
set laststatus=2
"shortcuts
set showcmd
set noerrorbells
inoremap ;; <esc>
nore ; :
nore , ;
set nu!
set nobackup 
set splitbelow
set splitright
set backspace=indent,eol,start
"window editing.
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
"vundle
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'ervandew/supertab'
Plugin 'Valloric/YouCompleteMe'
Plugin 'powerline/powerline', {'rtp': 'powerline/bindings/vim/'}
Plugin 'tpope/vim-fugitive'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'plytophogy/vim-virtualenv', {'for': ['python', 'python3']}
call vundle#end()

"Python syntax defaults. 
filetype plugin indent on
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab   

"virtualenv support, no idea if comp with pipenv

py << EOF
import os
import sys

if 'VIRTUAL_ENV' in os.environ:
      project_base_dir = os.environ['VIRTUAL_ENV']
      activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
      execfile(activate_this, dict(__file__=activate_this))
EOF

