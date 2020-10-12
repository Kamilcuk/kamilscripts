" MIT License. Copyright (c) 2014-2020 Mathias Andersson et al.
" Plugin: https://github.com/ludovicchabant/vim-gutentags
" vim: et ts=2 sts=2 sw=2

scriptencoding utf-8

function! airline#extensions#gen_tags#enable_on_section_x(...)
	if get(g:, 'airline#extensions#gen_tags#enabled', 1) && (get(g:, 'loaded_gentags#gtags', 0) || get(g:, 'loaded_gentags#ctags', 0))
		call airline#parts#define_function('gen_tags', 'airline#extensions#gen_tags#status')
		let g:airline_section_x = airline#section#create_right(['gen_tags'])
	endif
endfunction

if !get(g:, 'loaded_gentags#gtags', 0) && !get(g:, 'loaded_gentags#ctags', 0)
	finish
endif

function! airline#extensions#gen_tags#status()
  return gen_tags#job#is_running() != 0 ? 'Gen. gen_tags' : ''
endfunction

function! airline#extensions#gen_tags#init(ext)
  call airline#parts#define_function('gen_tags', 'airline#extensions#gen_tags#status')
endfunction

