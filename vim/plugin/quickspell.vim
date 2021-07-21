
finish

" https://vi.stackexchange.com/questions/19680/how-can-i-make-vim-not-use-the-entire-screen-for-spelling-suggestions
" Don't hijack the entire screen for spell checking, just show the top 9 results
" in the commandline.
" Press 0 for the full list. Any key press that's not a valid option (1-9) will
" behave as normal.
fun! QuickSpell()
    if &spell is 0
        echohl Error | echo "Spell checking not enabled" | echohl None
        return
    endif

    " Separator between items.
    let l:sep = ' | '

    " Show as many columns as will fit in the window.
    let l:sug = spellsuggest(expand('<cword>'), 9)
    let l:c = 0
    for l:i in range(0, len(l:sug))
        let l:c += len(l:sug[l:i - 1]) + len(printf('%d ', l:i + 1))
        " The -5 is needed to prevent some hit-enter prompts, even when there is
        " enough space (bug?)
        if l:c + (len(l:sep) * l:i) >= &columns - 5
            break
        endif
    endfor

    " Show options; make it stand out a bit.
    echohl QuickFixLine
    echo join(map(l:sug[:l:i - 1], {i, v -> printf('%d %s', l:i+1, l:v)}), l:sep)
    echohl None

    " Get answer.
    let l:char = nr2char(getchar())

    " Display regular spell screen on 0.
    if l:char is# '0'
        normal! z=
        return
    endif

    let l:n = str2nr(l:char)

    " Feed the character if it's not a number, so it's easier to do e.g. "ciw".
    if l:n is 0 || l:n > len(l:sug)
        return feedkeys(l:char)
    endif

    " Replace!
    exe printf("normal! ciw%s\<Esc>", l:sug[l:n-1])
    echo
endfun
nnoremap z= :call QuickSpell()<CR>
