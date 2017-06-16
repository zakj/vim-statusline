if exists('g:loaded_statusline') && g:loaded_statusline
  finish
endif
let g:loaded_statusline = 1

" User1: warnings/flags
" User2: dim text
" ErrorMsg is also used.
hi User1 ctermfg=203 ctermbg=232 guifg=#ff5f5f guibg=#080808
hi User2 ctermfg=237 ctermbg=232 guifg=#3a3a3a guibg=#080808

function! s:update() abort
  for n in range(1, winnr('$'))
    call setwinvar(n, '&statusline', '%!statusline#create(' . n . ')')
  endfor
endfunction

augroup status
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * call s:update()
augroup END
