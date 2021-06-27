
" My own script to set b:dispatch to my script that runs and detects how to
" run current file.
if exists('g:kamilscripts')
	let s:args = ""
	if argc() == 0
		" Add -p option when vim was started without any arguments
		let s:args = "-p "
	endif
	let s:tryautorun_once = 1
	function Tryautorun()
		" echom "Setting ".&makeprg." ".s:tryautorun_once." ".s:args
		if s:tryautorun_once && ( &makeprg == "" || &makeprg == "make" )
			let s:tryautorun_once = 0
			let &makeprg = ',tryautorun -V -p ' . s:args . '-- % $*'
		endif
	endfunction
	augroup tryautorun
		autocmd!
		execute "autocmd FileType c,cpp,python,sh,bash call Tryautorun()"
	augroup END
endif

