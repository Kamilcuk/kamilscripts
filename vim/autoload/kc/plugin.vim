
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
	if 0 && exists('g:plugs')
		for [key, val] in items(g:plugs)
			if has_key(val, 'uri')
				let val = val.uri
				let val = fnamemodify(val, ':t')
				let val = fnamemodify(val, ':r')
				if val =~ a:name
					return 1
				endif
			endif
		endfor
	endif
	for i in kc#plugin#split(&rtp)
		if fnamemodify(i, ':t') =~ a:name && isdirectory(i)
			return 1
		endif
	endfor
	return 0
endfunction

