
function RemoveTrailingSpaces() abort
	call kc#preserve(':%s/\($\n\s*\)*\%$/\r/e')
endfunction
command -bar TrailingSpacesRemove call RemoveTrailingSpaces()

if 0
" https://stackoverflow.com/questions/7495932/how-can-i-trim-blank-lines-at-the-end-of-file-in-vim
augroup removetrailingspaces
	autocmd!
	autocmd FileType c,cpp,markdown,python,shell autocmd BufWritePre <buffer> :call RemoveTrailingSpaces()<CR>
augroup END
endif

