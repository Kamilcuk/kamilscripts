" Async continous testing

let g:act_config = {
			\ 'from': '/home/kamil/tmp/test/',
			\ 'to': '/home/kamil/tmp/autoii/test/',
			\ 'make': 'make',
			\ 'rsyncopts': '--exclude .cache --exclude .git --exclude _build',
			\ }


function s:configfix()
	g:act_config['from'] = get(g:act_config, 'from', getcwd())
endfunction

let s:running = 0
let s:queued = 0
let s:output = []

function s:make_event(jobid, data, event)
	let s:output += a:data
endfunction

function s:make_exit(jobid, errcode, event)
	if a:errcode != 0
		cexpr s:output
		copen
		let s:output = ''
	endif
	let s:running = 0
	"if s:queued != 0
		"let s:queued = 0
		"call act#trigger()
	"endif
endfunction

let s:make_opts = {
			\ 'on_exit': function('s:make_exit'),
			\ 'on_stdout': function('s:make_event'),
			\ 'on_stderr': function('s:make_event'),
			\ }

function s:sync_exit(jobid, errcode, event)
	if a:errcode
		echoe 'Error when running rsync'
	else
		let s:make_job = jobstart(['sh', '-c', g:act_config['make']], extend(s:make_opts,
					\ {'cwd': g:act_config['to']}
					\ ))
	endif
endfunction

let s:sync_job = 0
let s:sync_opts = {
			\ 'on_exit': function('s:sync_exit'),
			\ }

function act#trigger()
	call s:configfix()
	if !s:running
		let s:running = 1
		let s:sync_job = jobstart([
					\ 'sh', '-c',
					\ 'rsync -a --delete '.g:act_config['rsyncopts']
					\ .' '.shellescape(g:act_config['from'])
					\ .' '.shellescape(g:act_config['to'])
					\ ], s:sync_opts)
		call act#trigger()
	else
		let s:queued = 1
	endif
endfunction

function s:ino_stdout(id, data, event)
	call act#trigger()
endfunction

let s:ino_job = 0
let s:ino_opts = {
			\ 'on_stdout': function('s:ino_stdout'),
			\ }

function act#start()
	call s:configfix()
	s:ino_job = jobstart(['inotifywait', '-rme', 'modify,create,delete', g:act_config['from']], s:ino_opts)
endfunction

function act#stop()
	call jobstop(s:ino_job)
endfunction

