
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
	" If using vim-plug, check the global variable g:plugs.
	if exists('g:plugs')
		if index(keys(g:plugs), a:name) != -1
			" The variable has a dir that we can use to check.
			let i = get(get(g:plugs, a:name), "dir", "")
			" Check if the dir exists and is not empty.
			if isdirectory(i) && !empty(glob(i.'/*', v:true))
				return 1
			endif
		endif
	else
		for i in kc#plugin#split(&rtp)
			if fnamemodify(i, ':t') =~ a:name
				if isdirectory(i) && !empty(glob(i.'/*', v:true))
					return 1
				endif
			endif
		endfor
	endif
	return 0
endfunction

