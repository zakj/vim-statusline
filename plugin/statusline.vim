if exists('g:loaded_statusline') && g:loaded_statusline
  finish
endif
let g:loaded_statusline = 1

function! s:update() abort
  call statusline#hl#create('StatusLineFlag', 'WarningMsg')
  call statusline#hl#create('StatusLineGitAdd', 'GitGutterAdd')
  call statusline#hl#create('StatusLineGitChange', 'GitGutterChange')
  call statusline#hl#create('StatusLineGitDelete', 'GitGutterDelete')

  for n in range(1, winnr('$'))
    call setwinvar(n, '&statusline', '%!statusline#create(' . n . ')')
  endfor
endfunction

augroup StatusLine
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * call s:update()
augroup END
