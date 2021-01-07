
" My own script to set b:dispatch to my script that runs and detects how to
" run current file.
if exists('g:kamilscripts') && kc#plugin#enabled('vim-dispatch') && !exists('b:dispatch')
	let s:args = ""
	if argc() == 0
		" Add -p option when vim was started without any arguments
		let s:args = "-p "
	endif
	augroup try_autorun
		autocmd!
		execute "autocmd FileType c,cpp,python,sh,bash let b:dispatch = ',try_autorun.sh -S " . s:args . "-e ' . &filetype . ' %'"
	augroup END
	unlet s:args
endif

