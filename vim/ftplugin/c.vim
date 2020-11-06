
" Add map from coc command in C files
nmap <silent> <leader>gh :CocCommand clangd.switchSourceHeader<CR>

if kc#plugin#enabled('vim-dispatch') && !exists('b:dispatch')
	if &filetype == "c"
		let cc = ",ccrun"
	elseif &filetype == "cpp"
		let cc = ",c++run"
	endif
	if exists('cc')
		let b:dispatch = cc . ' % -Wall -Wextra -ggdb3 -fsanitize=address -fsanitize=undefined -fsanitize=pointer-compare -fsanitize=pointer-subtract -fsanitize-address-use-after-scope'
		unlet cc
	endif
endif

