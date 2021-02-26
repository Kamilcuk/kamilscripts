
" My own script to set b:dispatch to my script that runs and detects how to
" run current file.
if exists('g:kamilscripts')
	let s:args = ""
	if argc() == 0
		" Add -p option when vim was started without any arguments
		let s:args = "-p "
	endif
	augroup try_autorun
		autocmd!
		execute "autocmd FileType c,cpp,python,sh,bash let &makeprg = ',try_autorun.sh -S " . s:args . "% $*'"
	augroup END
	unlet s:args
endif

