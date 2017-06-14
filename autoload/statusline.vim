" Return the dirname of the current buffer relative to the current working
" directory, optionally truncated at at a path boundary to the given argument,
" with a trailing slash.
function! statusline#reldir(...)
  let l:dir = expand('%:h')
  if l:dir == '.'
    return ''
  endif
  let l:xs = split(l:dir, '/')
  if a:0
    let l:truncated = 0
    while len(join(l:xs)) > a:1
      call remove(l:xs, 0)
      let l:truncated = 1
    endwhile
    if l:truncated
      call insert(l:xs, '…')
    endif
  endif
  call add(l:xs, '')
  if l:dir[0] == '/'
    call insert(l:xs, '')
  endif
  return '%2*' . join(l:xs, '/') . '%*'
endfunction

" If ALE or syntastic is installed, show a total count of errors.
function! statusline#syntax()
  let l:count = 0
  if exists('g:loaded_ale') && g:loaded_ale
    let l:f = ale#statusline#Count(bufnr(''))
    let l:count = l:f.total
  elseif exists('g:loaded_syntastic_plugin') && g:loaded_syntastic_plugin
    let l:f = g:SyntasticLoclist.current(bufnr(''))
    let l:count = len(l:f.errors()) + len(l:f.warnings())
  endif
  if l:count > 0
    return '%#ErrorMsg# ' . l:count . ' %* '
  else
    return ''
  endif
endfunction

" If gitgutter is installed and the current buffer has uncommited hunks,
" describe them. If fugitive is installed and the current file is in git, show
" the branch name (or commit id when detached).
function! statusline#git()
  let l:out = ' '
  if exists('g:loaded_gitgutter') && g:loaded_gitgutter
    let l:colors = ['GitGutterAdd', 'GitGutterChange', 'GitGutterDelete']
    let l:hunks = GitGutterGetHunkSummary()
    for l:i in range(3)
      let l:hunk = l:hunks[l:i]
      if l:hunk > 0
        let l:out .= '%#' . l:colors[l:i] . '#' . l:hunk . ' '
      endif
    endfor
  endif
  if exists('g:loaded_fugitive') && g:loaded_fugitive
    let l:head = fugitive#head(7)
    if len(l:head)
      let l:out .= ' %2*' . l:head
    endif
  endif
  return l:out . '%*'
endfunction

" Return a single-character representation of the current cursor line number as
" a fraction of the total lines. Courtesy of junegunn.
let s:braille = split('⠉⠒⠤⣀', '\zs')
function! statusline#scrollbar()
  let len = len(s:braille)
  let [cur, max] = [line('.'), line('$')]
  if cur == 1
    return '⎺'
  endif
  if cur == max
    return '_'
  endif
  let pos = min([len * (cur - 1) / max([1, max - 1]), len - 1])
  return s:braille[pos]
endfunction

function! statusline#create(winnr)
  let l:active = a:winnr == winnr()
  let l:buftype = getwinvar(a:winnr, '&buftype')
  let l:bufnr = winbufnr(a:winnr)
  let l:status = ''

  " Left side: current window / modified indicator, path and filename.
  if l:buftype == ''
    if l:active && getwinvar(a:winnr, '&modified')
      let l:status .= '%1*'
    endif
    let l:status .= ' › %*'
    let l:status .= '%<'
    let l:status .= statusline#reldir()
    let l:status .= '%t'
    if l:active && !getwinvar(a:winnr, '&modifiable')
      let l:status .= ' %1*⊝%*'
    endif
  elseif l:buftype == 'help'
    let l:status .= '[Help] %f'
  elseif l:buftype == 'terminal'
    let l:status .= '[Terminal]'
  else
    let l:status .= '%f'
  endif

  " Right side: syntax errors, git status, column indicator, scrollbar.
  let l:status .= ' %='
  if l:active && l:buftype == ''
    let l:status .= statusline#syntax()
    let l:status .= statusline#git()
    let l:status .= ' %3v %2*❘%* '
  endif
  if l:active
    let l:status .= statusline#scrollbar()
  endif

  return l:status
endfunction
