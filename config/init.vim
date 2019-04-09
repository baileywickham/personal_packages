
"sets powerline to turn on
set laststatus=2
set showcmd
"highlight line im on
set cursorline 

"Key remaps
inoremap hh <esc>
nore ; :
nore , ;
nnoremap <F2> :e! ~/.config/nvim/init.vim<CR>
noremap! <C-BS> <C-w>
noremap! <C-h> <C-w>

set nu "line numbers
set nobackup
set noerrorbells
set autowrite "writes on make
set autoread "reads modified files
set noswapfile

" coc settings
set hidden
"set cmdheight=2
set updatetime=300
set shortmess+=c

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
":command FixIt YcmCompleter FixIt
":command GoTo YcmCompleter GoTo
":command GoToDefinition YcmCompleter GoToDefinition
":command GetType YcmCompleter GetType

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
Plug 'altercation/vim-colors-solarized'
"Plug 'ervandew/supertab'
"Plug 'Valloric/YouCompleteMe'
Plug 'fatih/vim-go'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'JamshedVesuna/vim-markdown-preview' 
Plug 'christoomey/vim-tmux-navigator'
Plug 'Chiel92/vim-autoformat'
Plug 'lilydjwg/colorizer'
Plug 'luochen1990/rainbow'
Plug 'terryma/vim-multiple-cursors'
Plug 'lervag/vimtex'
"Plug 'sirver/ultisnips'
Plug 'KeitaNakamura/tex-conceal.vim'
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
"Plugin 'tmhedberg/SimpylFold'
call plug#end()

"let g:rainbow_active=1

let g:ycm_python_binary_path='python'
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_filetype_blacklist= { 'tex': 1 }

syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized

let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'


au BufWrite *.py,*.sh,*.json,*.c,*.h :Autoformat

let g:go_highlight_types = 1
let g:go_auto_type_info = 1

let vim_markdown_preview_github=1
let vim_markdown_preview_hotkey='<F9>'
"let vim_markdown_preview_toggle=3
let vim_markdown_preview_browser='Google Chrome'

let g:python3_host_prog = '/home/y/.local/share/virtualenvs/y-Tr7e3Pwk/bin/python'

"tex specific commands
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdgm'
"let g:UltiSnipsExpandTrigger = '<space>'
"let g:UltiSnipsJumpForwardTrigger = '<space>'
"let g:UltiSnipsJumpBackwardTrigger = '<s-space>'

source /home/y/.config/nvim/coc.vim

"virtualenv autocomplete support
py3 << EOF
import os
import sys

if 'VIRTUAL_ENV' in os.environ:
	project_base_dir = os.environ['VIRTUAL_ENV']
	activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
	exec(open(activate_this).read(), dict(__file__=activate_this))
EOF

