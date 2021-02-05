" viewrestore.vim
" Written by Kamil Cukrowski 2020
" SPDX_License_Identifier: MIT and Beerware
" This was a test of view restoration, doesn't work as intended, the defaults
" are better.
" https://vim.fandom.com/wiki/Make_views_automatic
" :call kc#viewrestore#enable() to enable this module

if !exists("g:skipview_files") | let g:skipview_files = [] | endif

function kc#viewrestore#enable()
	set viewoptions-=options
	set viewoptions-=curdir
	set viewoptions-=folds
	set viewoptions+=cursor

	" $VIMRUNTIME/defaults.vim
	" Put these in an autocmd group, so that you can revert them with:
	augroup vimStartup | au! | augroup END

	augroup vimrcAutoView
    	autocmd!
	    " Autosave & Load Views.
		autocmd BufWritePost,BufLeave,WinLeave ?* call kc#viewrestore#save()
		" When entering, restore window position __and__ cursor position.
	    autocmd BufWinEnter ?* call kc#viewrestore#load()
	augroup end
endfunction

function! kc#viewrestore#check()
    if has('quickfix') && &buftype =~ 'nofile'
        " Buffer is marked as not a file
        return 0
    endif
    if empty(glob(expand('%:p')))
        " File does not exist on disk
        return 0
    endif
    if len($TEMP) && expand('%:p:h') == $TEMP
        " We're in a temp dir
        return 0
    endif
    if len($TMP) && expand('%:p:h') == $TMP
        " Also in temp dir
        return 0
    endif
    if index(g:skipview_files, expand('%')) >= 0
        " File is in skip list
        return 0
    endif
	if &filetype =~# 'commit'
		" If it's a commit message
		return 0
	endif
    return 1
endfunction

function! kc#viewrestore#save()
	if kc#viewrestore#check()
		mkview
	endif
endfunction

function! kc#viewrestore#load()
	if kc#viewrestore#check()
		silent! loadview
		" echom line("'\"") . "and" . line("$")
		if line("'\"") >= 1 && line("'\"") <= line("$")
			" echom "HERE"
			call setpos(".", getpos("'\""))
		endif
	endif
endfunction


