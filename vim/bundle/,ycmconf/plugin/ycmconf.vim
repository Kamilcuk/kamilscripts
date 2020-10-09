
" Set the global extra configuration
if !exists('g:ycm_global_ycm_extra_conf')
	let g:ycm_global_ycm_extra_conf = expand('<sfile>:p:h:h') . '/ycm_extra_conf.py'
endif

