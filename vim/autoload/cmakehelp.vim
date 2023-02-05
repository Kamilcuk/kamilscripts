
function! s:error(msg) abort
	redraw
	echohl ErrorMsg
	echon 'cmakehelp.vim: ' a:msg
	echohl None
endfunction

function! s:find_window() abort
	let l:win = 1
	while l:win <= winnr('$')
		let l:buf = winbufnr(l:win)
		" echom "foundone: ".l:buf.' '.getbufvar(l:buf, '&filetype', '')
		if getbufvar(l:buf, '&filetype', '') ==# 'cmakehelp'
			execute l:win.'wincmd w'
			return 1
		endif
		let l:win += 1
	endwhile
	return 0
endfunction

function! cmakehelp#get(target) abort
	let l:prefixes = [
				\ 'help ',
				\ 'help-variable ',
				\ 'help-variable CMAKE_',
				\ 'help-module ',
				\ ]
	if a:target =~ '^CMP[0-9]\+$'
		let l:prefixes = [
					\ 'help-policy ',
					\ ]
	endif
	let l:target = shellescape(a:target)
	for l:prefix in l:prefixes
		try
			return kc#getredir('cmake --' . l:prefix . l:target)
		catch
		endtry
	endfor
	throw 'no manual entry for ' . a:target
endfunction

function! cmakehelp#open(target) abort
	try
		call cmakehelp#get(a:target)
	catch
		call s:error(v:exception)
		return
	endtry
	let [l:buf, l:save_tfu] = [bufnr(), &tagfunc]
	try
		setlocal tagfunc=cmakehelp#tagfunc
		if s:find_window()
			execute 'silent keepalt tag' a:target
		else
			execute 'silent keepalt stag' a:target
		endif
	finally
		call setbufvar(l:buf, '&tagfunc', l:save_tfu)
	endtry
endfunction

function! cmakehelp#read(target) abort
	try
		let str = cmakehelp#get(a:target)
	catch
		call s:error(v:exception)
		return
	endtry
	let w:scratch = 1
	call setline(1, str)
	setlocal conceallevel=2
	setlocal noswapfile buftype=nofile bufhidden=hide
	setlocal nomodified readonly nomodifiable
	setlocal keywordprg=:CMakeHelp
	setlocal tagfunc=cmakehelp#tagfunc
	setlocal filetype=cmakehelp
endfunction

function! cmakehelp#tagfunc(pattern, flags, info) abort
	try
		call cmakehelp#get(a:pattern)
	catch
		return []
	endtry
	let r = [{
				\ "name": "cmakehelp://".a:pattern,
				\ "filename": "cmakehelp://".a:pattern,
				\ "cmd": "1",
				\ }]
	return r
endfunction

