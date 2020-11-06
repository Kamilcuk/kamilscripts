
" Disable spell checking in these
" Lines extractes as-is from vimruntime/syntax/git.vim
" I guess I could also sed 's/... it.
syn region gitHead start=/\%^/ end=/^$/ contains=@NoSpell
syn region gitHead start=/\%(^commit\%( \x\{40\}\)\{1,\}\%(\s*(.*)\)\=$\)\@=/ end=/^$/ contains=@NoSpell
syn match gitHead /^\d\{6\} \%(\w\{4} \)\=\x\{40\}\%( [0-3]\)\=\t.*/ contains=@NoSpell
syn match gitHead /^\x\{40\} \x\{40}\t.*/ contains=@NoSpell
syn match  gitHash      /\<\x\{40\}\>/                         contained nextgroup=gitIdentity,gitStage,gitHash skipwhite contains=@NoSpell
syn match  gitHash      /^\<\x\{40\}\>/ containedin=gitHead contained nextgroup=gitHash skipwhite contains=@NoSpell
syn match  gitHashAbbrev /\<\x\{4,40\}\>/           contained nextgroup=gitHashAbbrev skipwhite contains=@NoSpell
syn match  gitHashAbbrev /\<\x\{4,39\}\.\.\./he=e-3 contained nextgroup=gitHashAbbrev skipwhite contains=@NoSpell

