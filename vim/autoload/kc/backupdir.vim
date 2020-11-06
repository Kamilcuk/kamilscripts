

" change backupdir to temporary directory
" not needed - all caches are now stored in cache
function kc#backupdir(dir)
	if empty(a:dir)
		let a:dir = '/tmp/.vimbackupdir-'.$USER.'/'
	endif
	if !isdirectory(a:dir)
		call mkdir(a:dir)
		call setfperm(a:dir, 'rxwrxwrxw')
	endif
	execute 'set backupdir^='.a:dir
	execute 'set directory^='.a:dir
	execute 'set backupskip^='.a:dir.'*'
	unlet a:dir
endfunction

