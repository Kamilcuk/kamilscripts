
" https://stackoverflow.com/questions/12652172/is-there-any-way-to-adjust-the-format-of-folded-lines-in-vim
function! kc#foldtext#foldtext() abort
    let line = getline(v:foldstart)
    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart
    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')
    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
    return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction

function! kc#foldtext#enable() abort
	set foldtext=kc#foldtext#foldtext()
endfunction

