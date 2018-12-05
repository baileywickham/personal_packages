
"sets powerline to turn on
set laststatus=2
set showcmd

"Key remaps
inoremap ;; <esc>
nnoremap <F2> :e! ~/.config/nvim/init.vim<CR>
nore ; :
nore , ;

set nu "line numbers
set nobackup
set noerrorbells
set autowrite "writes on make
set autoread "reads modified files
set nocompatible              
set noswapfile
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


call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'ervandew/supertab'
Plug 'Valloric/YouCompleteMe'
Plug 'fatih/vim-go'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'JamshedVesuna/vim-markdown-preview' 
"Plugin 'tmhedberg/SimpylFold'
"Plugin 'shougo/deoplete.nvim'
call plug#end()

let g:ycm_python_binary_path='python'
let g:ycm_autoclose_preview_window_after_completion=1

set t_Co=256
syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized

map <C-n> :NERDTreeToggle<CR>

let g:go_highlight_types = 1
let g:go_auto_type_info = 1

let vim_markdown_preview_toggle=3
let vim_markdown_preview_browser='Google Chrome'

let g:python3_host_prog = '/home/y/.local/share/virtualenvs/y-Tr7e3Pwk/bin/python'


"virtualenv autocomplete support
py3 << EOF
import os
import sys

if 'VIRTUAL_ENV' in os.environ:
	project_base_dir = os.environ['VIRTUAL_ENV']
	activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
	exec(open(activate_this).read(), dict(__file__=activate_this))
EOF

