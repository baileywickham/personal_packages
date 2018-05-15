"soloarized plugin
let g:solarized_termcolors=256
syntax enable
set background=dark
colorscheme solarized

"shortcuts
set showcmd
set noerrorbells
inoremap ;; <esc>
nore ; :
nore , ;
set nu!
set nobackup 

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
Plugin 'davidhalter/jedi-vim'
Plugin 'ervandew/supertab'
Plugin 'tpope/vim-surround'

call vundle#end()

"Python syntax defaults. 
filetype plugin indent on
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
