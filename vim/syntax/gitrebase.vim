
" Disable spell checking in thse two
" Lines extracted from runtime git
syn match   gitrebaseHash   "\v<\x{7,}>"                               contained contains=@NoSpell
syn match   gitrebaseCommit "\v<\x{7,}>"    nextgroup=gitrebaseSummary skipwhite contains=@NoSpell

