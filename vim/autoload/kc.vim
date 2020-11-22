
function! kc#rtp_list() abort
	for i in split(&rtp, ",")
		echom i
	endfor
endfunction

