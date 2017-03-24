" File:        autoload/gfff.vim
" Description: goto first found file
" Author:      Randy Stauner
" Source:      https://github.com/rwstauner/vim-gfff
" License:     Same terms as Vim itself (see :help license).

function! s:var(var, default)
  if has_key(b:, a:var)
    return get(b:, a:var)
  endif

  return get(g:, a:var, a:default)
endfunction


let s:commands = {
  \ 'gf':         'edit',
  \ '<C-w>f':     'split',
  \ '<C-w><C-f>': 'split',
  \ '<C-w>gf':    'tab split',
\ }

function! s:target(mode)
  if a:mode == 'v'
    let reg = 'g'
    let old = getreg(reg)
    exe 'normal! gv"' . reg . 'y'
    let sel = getreg(reg)
    call setreg(reg, old)
    return sel
  endif

  return expand("<cfile>")
endfunction

function! gfff#open(map, mode, ...)
  let l:file = a:0 ? a:1 : s:target(a:mode)
  let l:found = gfff#find(l:file)
  if strlen(l:found)
    exe s:commands[a:map] fnameescape(l:found)
  else
    echom l:file "not found in" &path
  endif
endfunction


function! gfff#find(file)
  let l:done = {}
  let l:exprs = [ 'a:file' ]

  if s:var("gfff_remove_leading_dot_slash", 1)
    call add(l:exprs, 'substitute(a:file, "^\./", "", "")')
  endif

  let l:vfnamesub = 'eval(substitute(%s, "\\<v:fname\\>", "a:file", ""))'

  if s:var("gfff_use_includeexpr", 1)
    call add(l:exprs, printf(l:vfnamesub, '&includeexpr'))
  endif

  call extend(l:exprs, map(s:var("gfff_includeexprs", []),
    \ "printf(l:vfnamesub, '\"'.escape(v:val, '\\\"').'\"')"))

  for l:expr in l:exprs
    let l:file = eval(l:expr)

    " Ignore duplicates.
    if has_key(l:done, l:file)
      continue
    endif

    let l:ff = findfile(l:file)
    if strlen(l:ff)
      return l:ff
    endif

    let l:done[l:file] = 1
  endfor

  " Emulate return of a single findfile() call.
  return ''
endfunction
