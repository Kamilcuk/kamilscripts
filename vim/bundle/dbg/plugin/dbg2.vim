""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:add_cleanup(i)
	if !exists("s:cleanup")
		let s:cleanup = []
	endif
	let s:cleanup += [a:i]
endfunction

function! s:add_tmap2(opts, name, mapping)
	execute 'tnoremap '.a:opts.' <C-a>'.a:name.' <C-w>'.a:mapping
	call s:add_cleanup('tunmap <C-a>'.a:name)
endfunction

function! s:add_map2(opts, name, mapping)
	execute 'nmap '.a:opts.' <leader>a'.a:name.' '.a:mapping
	call s:add_cleanup('nunmap <leader>a'.a:name)
endfunction

function! s:add_map(name, mapping)
	call s:add_map2("", a:name, a:mapping)
endfunction

function! s:add_map_repeat2(opts, name, temp, mapping)
	execute 'nnoremap <silent> <Plug>'.a:temp.' '.a:mapping.':call repeat#set("\<Plug>'.a:temp.'")<CR>'
	call s:add_cleanup('nunmap <Plug>'.a:temp)
	call s:add_map2(a:opts, a:name, '<Plug>'.a:temp)
endfunction

function! s:add_map_repeat(name, temp, mapping)
	call s:add_map_repeat2("", a:name, a:temp, a:mapping)
endfunction

function! s:add_command2(opts, name, what)
	execute 'command '.a:opts.' '.a:name.' '.a:what
	call s:add_cleanup('delcommand '.a:name)
endfunction

function! s:add_command(name, what)
	call s:add_command2("", a:name, a:what)
endfunction

function! s:exe_cleanup()
	if exists('s:cleanup')
		for i in s:cleanup
			execute i
		endfor
		unlet s:cleanup
	endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:Dbg_until(at)
	let bploc = empty(a:at) ? fnameescape(expand('%:p')) . ':' . (line('.') + v:count) : a:at 	
	call TermDebugSendCommand('until '.bploc)
endfunction

function! s:Dbg_toggle_break(at)
	let bploc = empty(a:at) ? fnameescape(expand('%:p')) . ':' . (line('.') + v:count) : a:at
	execute 'ToggleBreak ' . bploc
endfunction

function! s:Dbg_send(cmds)
	for i in a:cmds
		call TermDebugSendCommand(i)
	endfor
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! Dbg_jlink_jlinkgdbserver_closehandler(channel)
	call TermDebugSendCommand('quit')
	" echomsg "JLinkGDBServer exited"
endfunction

function! Dbg_jlink_stop()
	if exists(s:jlink)
		call job_stop(s:jlink, 'int')
		unlet s:jlink
	endif
	if exists('s:rtt') && s:rtt
		exe 'bwipe! ' . s:rtt
		unlet s:rtt
	endif
	call s:exe_cleanup()
endfunction

augroup Dbg
	autocmd!
	autocmd User TermdebugEnd :call Dbg_jlink_stop()
augroup END

function! s:Dbg_jlink_goto_rtt()
	if exists('s:rtt') && s:rtt
		exe 'b ' . s:rtt
	endif
endfunction

function s:Dbg_restart()
	call TermDebugSendCommand('quit')
	sleep 500 m
	call Dbg_jlink_start(s:last_args)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:last_args = {}

function! Dbg_add_commands_maps()
	call s:add_command("DbgRttwin", ":call s:Dbg_jlink_goto_rtt()")
	call s:add_command2("-range -nargs=?", "DbgUntil", ":call s:Dbg_until(<q-args>)")
	call s:add_command2("-range -nargs=?", "DbgToggleBreak", ":call s:Dbg_toggle_break(<q-args>)")

	if !exists('g:gdb_no_mappings') || g:gdb_no_mappings
		" to each of these '<leader>a' is added
		" to tmap is aded '<C-a>'
		call s:add_map_repeat("c", "DbgContinue", ":Continue<CR>")
		call s:add_map("b", ":DbgToggleBreak<CR>")
		call s:add_map("u", ":DbgUntil<CR>")
		call s:add_map("[", ":Break<CR>")
		call s:add_map("]", ":Clear<CR>")
		call s:add_map_repeat("s", "DbgStep", ":Step<CR>")
		call s:add_map_repeat("n", "DbgOver", ":Over<CR>")
		call s:add_map("g", ":Gdb<CR>")
		call s:add_map("e", ":Source<CR>")
		call s:add_tmap2("", "e", ":Source<CR>")
		call s:add_map("i", ":Stop<CR>")
		call s:add_map_repeat("f", "DbgFinish", ":Finish<CR>")
		call s:add_map("q", ":call TermDebugSendCommand('quit')<CR>")
		call s:add_map("R", ":call s:Dbg_restart()<CR>")
	endif

endfunction

function! Dbg_jlink_start(opts)
	let s:last_args = a:opts

	let l:file = get(a:opts, "file", "")
	if !filereadable(l:file)
		echoe "File ".l:file." not readable"
		return
	endif

	if !empty(get(a:opts, "jlink_args", ""))
		let l:args = 
					\ "JLinkGDBServer " .
					\ "-speed auto -port 2331 -swoport 2332 -telnetport 2333 -vd -ir -localhoston 1 -singlerun -strict -timeout 0 -nogui " .
					\ get(a:opts, "jlink_args", "")
		let s:jlink = job_start(l:args, { 'close_cb': 'Dbg_jlink_jlinkgdbserver_closehandler', })
		sleep 500m
		if job_status(s:jlink) != "run"
			echoe "JLinkGDBServer startup failed"
			call Dbg_jlink_stop()
			return
		endif
		echomsg "JLinkGDBServer started"
	endif

	Termdebug

	call Dbg_add_commands_maps()

	if 1
		Program
		let s:rtt = term_start(
					\ "sh -c \"socat -t1 tcp:localhost:19021,reuseaddr,keepalive,keepidle=1,keepintvl=1,keepcnt=100 STDOUT"
					\ . " | " .
					\ "awk '{ print strftime(\\\"%H:%M:%S\\\"), $0; fflush(); }'\""
					\ ,{
					\ "term_name": "jlink rtt logs",
					\ })
	endif

	if get(a:opts, "hide_program", 0) || 1
		Program
		hide
	endif

	Source

	let l:cmds = [
				\ 'set confirm off',
				\ 'set remotetimeout 2',
				\ 'target remote localhost:2331',
				\ 'file ' . shellescape(l:file),
				\ 'load',
				\ 'monitor reset',
				\ 'b main',
				\ 'continue',
				\ 'where'
				\ ]
	call s:Dbg_send(l:cmds)

endfunction


nmap <leader>qq :call TermDebugSendCommand("quit") <bar> :so /usr/lib/kamilscripts/vim/plugin/dbg2.vim <bar> :QDebug<CR>


