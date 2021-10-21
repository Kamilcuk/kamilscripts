
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


" https://stackoverflow.com/questions/7495932/how-can-i-trim-blank-lines-at-the-end-of-file-in-vim
" Utility function that save last search and cursor position
" http://technotales.wordpress.com/2010/03/31/preserve-a-vim-function-that-keeps-your-state/
" video from vimcasts.org: http://vimcasts.org/episodes/tidying-whitespace
" using 'execute' command doesn't overwrite the last search pattern, so I
" don't need to store and restore it.
" preserve function
function! kc#preserve(command) abort
	try
		let l:win_view = winsaveview()
		"silent! keepjumps keeppatterns execute a:command
		silent! execute 'keeppatterns keepjumps ' . a:command
	finally
		call winrestview(l:win_view)
	endtry
endfunction

" https://stackoverflow.com/a/64639752/9072753
" pev.hall from stackoverflopw
function! kc#VisualSelectionArray() abort
    if mode()=="v"
        let [line_start, column_start] = getpos("v")[1:2]
        let [line_end, column_end] = getpos(".")[1:2]
    else
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
    end

    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] =
        \   [line_end, column_end, line_start, column_start]
    end
    let lines = getline(line_start, line_end)
    if len(lines) == 0
            return ['']
    endif
    if &selection ==# "exclusive"
        let column_end -= 1 "Needed to remove the last character to make it match the visual selction
    endif
    if visualmode() ==# "\<C-V>"
        for idx in range(len(lines))
            let lines[idx] = lines[idx][: column_end - 1]
            let lines[idx] = lines[idx][column_start - 1:]
        endfor
    else
        let lines[-1] = lines[-1][: column_end - 1]
        let lines[ 0] = lines[ 0][column_start - 1:]
    endif
    return lines  "use this return if you want an array of text lines
endfunction
function! kc#VisualSelection() abort
    return join(kc#VisualSelectionArray(), "\n") "use this return instead if you need a text block
endfunction

" http://www.danielbigham.ca/cgi-bin/document.pl?mode=Display&DocumentID=1053
" URL encode a string. ie. Percent-encode characters as necessary.
function! kc#UrlEncode(string) abort
    let result = ""
    let characters = split(a:string, '.\zs')
    for character in characters
        if character == " "
            let result = result . "+"
        elseif kc#CharacterRequiresUrlEncoding(character)
            let i = 0
            while i < strlen(character)
                let byte = strpart(character, i, 1)
                let decimal = char2nr(byte)
                let result = result . "%" . printf("%02x", decimal)
                let i += 1
            endwhile
        else
            let result = result . character
        endif
    endfor
    return result
endfunction

" http://www.danielbigham.ca/cgi-bin/document.pl?mode=Display&DocumentID=1053
" Returns 1 if the given character should be percent-encoded in a URL encoded
" string.
function! kc#CharacterRequiresUrlEncoding(character) abort
    let ascii_code = char2nr(a:character)
    if ascii_code >= 48 && ascii_code <= 57
        return 0
    elseif ascii_code >= 65 && ascii_code <= 90
        return 0
    elseif ascii_code >= 97 && ascii_code <= 122
        return 0
    elseif a:character == "-" || a:character == "_" || a:character == "." || a:character == "~"
        return 0
    endif
    return 1
endfunction


" https://gist.github.com/romainl/eae0a260ab9c135390c30cd370c20cd7
" Run command in background and redirect output to a new buffer
function! kc#Redir(cmd, rng, start, end)
	for win in range(1, winnr('$'))
		if getwinvar(win, 'scratch')
			execute win . 'windo close'
		endif
	endfor
	if a:cmd =~ '^!'
		let cmd = a:cmd =~' %'
			\ ? matchstr(substitute(a:cmd, ' %', ' ' . expand('%:p'), ''), '^!\zs.*')
			\ : matchstr(a:cmd, '^!\zs.*')
		if a:rng == 0
			let output = systemlist(cmd)
		else
			let joined_lines = join(getline(a:start, a:end), '\n')
			let cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
			let output = systemlist(cmd . " <<< $" . cleaned_lines)
		endif
	else
		redir => output
		execute a:cmd
		redir END
		let output = split(output, "\n")
	endif
	vnew
	let w:scratch = 1
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	call setline(1, output)
endfunction

" from /usr/share/nvim/runtime/autoload/man.vim
" Handler for s:system() function.
function! s:system_handler(jobid, data, event) dict abort
  if a:event is# 'stdout' || a:event is# 'stderr'
    let self[a:event] .= join(a:data, "\n")
  else
    let self.exit_code = a:data
  endif
endfunction
" Run a system command and timeout after 30 seconds.
function! s:system(cmd, ...) abort
  let opts = {
        \ 'stdout': '',
        \ 'stderr': '',
        \ 'exit_code': 0,
        \ 'on_stdout': function('s:system_handler'),
        \ 'on_stderr': function('s:system_handler'),
        \ 'on_exit': function('s:system_handler'),
        \ }
  let jobid = jobstart(a:cmd, opts)

  if jobid < 1
    throw printf('command error %d: %s', jobid, join(a:cmd))
  endif

  let res = jobwait([jobid], 30000)
  if res[0] == -1
    try
      call jobstop(jobid)
      throw printf('command timed out: %s', join(a:cmd))
    catch /^Vim(call):E900:/
    endtry
  elseif res[0] == -2
    throw printf('command interrupted: %s', join(a:cmd))
  endif
  if opts.exit_code != 0
    throw printf("command error (%d) %s: %s", jobid, join(a:cmd), substitute(opts.stderr, '\_s\+$', '', &gdefault ? '' : 'g'))
  endif

  return opts.stdout
endfunction

function! kc#getredir(cmd) abort
	return split(s:system(a:cmd), '\n')
endfunction
