" File:        plugin/gfff.vim
" Description: goto first found file
" Author:      Randy Stauner
" Source:      https://github.com/rwstauner/vim-gfff
" License:     Same terms as Vim itself (see :help license).

if exists('g:loaded_gfff')
  finish
endif

if !exists("g:gfff_no_mappings")
  let g:gfff_no_mappings = 0
endif


let s:maps = [
  \ 'gf',
  \ '<C-w>f',
  \ '<C-w><C-f>',
  \ '<C-w>gf',
\ ]

let s:modes = [
  \ 'n',
\ ]

function s:template(str, vars)
  return substitute(a:str, '{\(\h\+\)}', '\=a:vars[submatch(1)]', 'g')
endfunction

function s:map_all(str)
  for l:map in s:maps
    for l:mode in s:modes
      exe s:template(a:str, {
        \ 'mode': l:mode,
        \ 'map': l:map,
        \ 'map_arg': substitute(l:map, '<', '<LT>', 'g'),
      \ })
    endfor
  endfor
endfunction

call s:map_all("{mode}noremap <silent> <Plug>gfff_{map} :<C-U>call gfff#open('{map_arg}', '{mode}')<CR>")

if !g:gfff_no_mappings
  call s:map_all('{mode}map {map} <Plug>gfff_{map}')
endif

let g:loaded_gfff = 1
