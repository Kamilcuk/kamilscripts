
if exists('g:loaded_cmakehelp')
	finish
endif
let g:loaded_cmakehelp = 1

augroup CMakeHelp
	autocmd!
	autocmd BufReadCmd cmakehelp://* call cmakehelp#read(matchstr(expand('<amatch>'), 'cmakehelp://\zs.*'))
augroup END

