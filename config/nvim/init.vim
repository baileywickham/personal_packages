function! SourceIfExists(file)
    if filereadable(expand(a:file))
        exe 'source' a:file
    else
        echo "Counld not read file"
    endif
endfunction

function! Imp(importname)
    " force case sensitive
    if &filetype ==? "go"
        call go#import#SwitchImport(1, '', a:importname, '<bang>')
    elseif &filetype ==? "python"
        echo "python"
    endif
endfunction



"sets powerline to turn on
set laststatus=2
set showcmd
set cursorline

"Key remaps :(
"inoremap hh <esc>
"Remap for term
tnoremap hh <C-\><C-n>
"nore ; :
"nore , ;
nnoremap <F2> :e! ~/.config/nvim/init.vim<CR>
nnoremap <F1> :e! ~/.config/nvim/<CR>
noremap! <C-BS> <C-w> "ctrl backspace
noremap! <C-h> <C-w>

"nnoremap <Space> i_<Esc>r
"space inserts single character


set nu "line numbers
set nobackup
set noerrorbells
set autowrite "writes on make
set autoread "reads modified files
set noswapfile
set hidden
set relativenumber
set inccommand=nosplit

" coc settings
"set cmdheight=2
set updatetime=300
set shortmess+=c

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
"
"Search options
set hlsearch
set smartcase
set incsearch
set wildmenu
set wildignorecase
"set ignorecase

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

if has("autocmd")
    au BufReadPost *.rkt,*.rktl set filetype=scheme
endif


autocmd FileType c,cpp setlocal equalprg=clang-format
autocmd BufNewFile,BufRead *.h setfiletype c
autocmd BufNewFile,BufRead *.bailey_shell set filetype=sh

autocmd BufWritePre * %s/\s\+$//e

autocmd FileType yaml,yml setlocal et ts=2 sw=2 sts=0


call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'fatih/vim-go'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'JamshedVesuna/vim-markdown-preview' " f9? to preview
Plug 'christoomey/vim-tmux-navigator'
Plug 'Chiel92/vim-autoformat'
Plug 'lilydjwg/colorizer'
Plug 'luochen1990/rainbow'
Plug 'lervag/vimtex'
Plug 'KeitaNakamura/tex-conceal.vim'
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'Shougo/neco-vim'
Plug 'neoclide/coc-neco'
Plug 'wlangstroth/vim-racket' "vim autocomplete
"Plug 'jpalardy/vim-slime'
call plug#end()

syntax enable
set background=dark
let g:solarized_termcolors=256
colorscheme solarized

"add coc to airline
let g:airline_theme='solarized'
let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'


au BufWrite *lisp,*.go,*.sh,*.json,*.zsh :Autoformat

map <C-n> :NERDTreeToggle<CR>

let g:go_highlight_types = 1
let g:go_auto_type_info = 1

let vim_markdown_preview_github=1
let vim_markdown_preview_hotkey='<F9>'
"let vim_markdown_prevew_toggle=3
let vim_markdown_preview_browser='Google Chrome'

let g:python3_host_prog = '/usr/bin/python3'

"tex specific commands
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
"let g:vimtex_quickfix_mode=0

set conceallevel=1
let g:tex_conceal='abdgm'


call SourceIfExists("$HOME/.config/nvim/coc.vim")
command! -nargs=1 Import  call Imp('<args>')

let g:slime_target = "tmux"
"command! configure e ~/.config/nvim
