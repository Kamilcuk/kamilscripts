
function! kc#rtp_list() abort
	for i in split(&rtp, ",")
		echom i
	endfor
endfunction

function! kc#nvim_version_str()
	if !has('nvim')
		return "0"
	endif
	redir => s
	silent! version
	redir END
	return matchstr(s, 'NVIM v\zs[^\n]*')
endfunction

