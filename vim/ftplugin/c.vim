
" Add map from coc command in C files
nmap <silent> <buffer> <leader>gh :CocCommand clangd.switchSourceHeader<CR>

if kc#plugin#enabled('vim-dispatch') && !exists('b:dispatch')
	let b:dispatch = g:kamilscripts.'/vim/bin/,vim_autorun.sh '.&filetype.' %'
endif


