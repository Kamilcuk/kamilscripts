
if exists('g:kamilscripts') && kc#plugin#enabled('vim-dispatch') && !exists('b:dispatch')
	let s:args = ""
	if argc() == 0
		let s:args = "-p "
	endif
	echo s:args
	augroup try_autorun
		autocmd!
		execute "autocmd filetype c,cpp,python,sh,bash let b:dispatch = ',try_autorun.sh -S " . s:args . "-e ' . &filetype . ' %'"
	augroup END
	unlet s:args
endif
