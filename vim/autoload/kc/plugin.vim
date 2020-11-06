
" Carelessly copied from pathogen.vim
" Under VIM license Copyright (c) Tim Pope
" Split a path into a list.
function! kc#plugin#split(path) abort
  if type(a:path) == type([]) | return a:path | endif
  if empty(a:path) | return [] | endif
  let split = split(a:path,'\\\@<!\%(\\\\\)*\zs,')
  return map(split,'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
endfunction

" Check if the plugin with the name is enabled
function! kc#plugin#enabled(name) abort
	for i in kc#plugin#split(&rtp)
		if fnamemodify(i, ':t') =~ a:name
			return 1
		endif
	endfor
	return 0
endfunction

