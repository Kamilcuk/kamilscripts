
" My own script to set b:dispatch to my script that runs and detects how to
" run current file.
if exists('g:kamilscripts')
	let s:args = ""
	if argc() == 0
		" Add -p option when vim was started without any arguments
		let s:args = "-p "
	endif
	function Tryautorun()
		" echom "Setting ".&makeprg." ".s:tryautorun_once." ".s:args
		if &makeprg == "" || &makeprg == "make"
			" Run only once - remove out augroup
			augroup tryautorun
				autocmd!
			augroup END
			"
			let &makeprg = ',tryautorun -V -p ' . s:args . '-- % $*'
		endif
	endfunction
	augroup tryautorun
		autocmd!
		autocmd FileType c,cpp,python,sh,bash,cmake call Tryautorun()
	augroup END
endif

