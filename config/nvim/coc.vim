" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
"let g:coc_force_debug = 1
set statusline^=%{coc#status()}

"inoremap <silent><expr> <TAB>
"      \ pumvisible() ? coc#_select_confirm() :
"      \ coc#expandableOrJumpable() ? coc#rpc#request('doKeymap', ['snippets-expand-jump','']) :
"      \ <SID>check_back_space() ? "\<TAB>" :
"      \ coc#refresh()

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-Tab>"

inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

let g:coc_snippet_prev = '<c-j>'
let g:coc_snippet_next = '<c-k>'



function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>k  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>j  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

