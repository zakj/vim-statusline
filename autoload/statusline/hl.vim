" Return the definition of a highlight group as a string.
function! statusline#hl#string(group)
  if !hlexists(a:group)
    return ''
  endif
  redir => l:output
  execute 'silent hi ' . a:group
  redir END
  if l:output =~ 'links to'
    let l:output = statusline#hl#string(substitute(l:output, '.* links to ', '', ''))
  endif
  let l:output = substitute(l:output, '[\x00\n]', '', 'g')  " weird bug in nvim?
  return substitute(l:output, '^.*xxx\s\+', '', '')
endfunction

" Return the definition of a highlight group as an object.
function! statusline#hl#obj(group)
  let l:string = statusline#hl#string(a:group)
  let l:style = {}
  for l:item in split(l:string, '\s\+')
    let [l:k, l:v] = split(l:item, '=')
    let l:style[l:k] = l:v
  endfor
  return l:style
endfunction

" Return the string definition of a highlight group from an object.
function! statusline#hl#obj_to_string(obj)
  let l:bits = []
  for l:item in items(a:obj)
    call add(l:bits, join(l:item, '='))
  endfor
  return join(l:bits, ' ')
endfunction

" Create the named highlight group by combining its foreground colors and the
" existing StatusLine group definition.
function! statusline#hl#create(name, from)
  if !hlexists(a:from)
    return
  endif
  let l:new = statusline#hl#obj(a:from)
  let l:statusline = statusline#hl#obj('StatusLine')
  for l:key in ['ctermbg', 'guibg', 'cterm', 'gui']
    if has_key(l:statusline, l:key)
      let l:new[l:key] = l:statusline[l:key]
    endif
  endfor
  execute join(['hi', a:name, statusline#hl#obj_to_string(l:new)], ' ')
endfunction
