set statusline^=%{coc#status()}
"
"
" Insert <tab> when previous text is space, refresh completion if not.
inoremap <silent><expr> <TAB>
  \ coc#pum#visible() ? coc#pum#next(1):
  \ <SID>check_back_space() ? "\<Tab>" :
  \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<CR>"

"
"inoremap <silent><expr> <c-space> coc#refresh()
"
"inoremap <expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<CR>"
"
"inoremap <silent><expr> <CR> coc#pum#visible() ? coc#_select_confirm()
"            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
"
"
"inoremap <expr> <tab> pumvisible() ? "\<C-n>" : "\<Tab>"
"inoremap <expr> <S-tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
"
"inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<cr>"
"
"let g:coc_snippet_prev = '<c-j>'
"let g:coc_snippet_next = '<c-k>'
"
"
"
"function! s:check_back_space() abort
"  let col = col('.') - 1
"  return !col || getline('.')[col - 1]  =~ '\s'
"endfunction
"
"" Use `[c` and `]c` for navigate diagnostics
"nmap <silent> [c <Plug>(coc-diagnostic-prev)
"nmap <silent> ]c <Plug>(coc-diagnostic-next)
"
"" Use K for show documentation in preview window
"nnoremap <silent> K :call <SID>show_documentation()<cr>
"
"function! s:show_documentation()
"  if &filetype == 'vim'
"    execute 'h '.expand('<cword>')
"  else
"    call CocAction('doHover')
"  endif
"endfunction
"
"" Highlight symbol under cursor on CursorHold
"autocmd CursorHold * silent call CocActionAsync('highlight')
"
"" Remap for rename current word
"nmap <leader>rn <Plug>(coc-rename)
