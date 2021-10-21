" Vim syntax file
" Langauge:  CMakeHelp
" Maintainer: Kamil Cukrowski

if !has('nvim')
	finish
endif
if exists("b:current_syntax")
  finish
endif
runtime! syntax/cmake.vim
unlet! b:current_syntax

syn match cmakehelpH1 "^.\+\n-\+$"
syn match cmakehelpH2 "^.\+\n\^\+$"
syn match cmakehelpHeadingRule "^[-\^]\+$"

syn region cmakehelpCode matchgroup=cmakehelpCodeDelimiter start="``" end="``" oneline concealends

syn region cmakehelpItalic matchgroup=cmakehelpItalicDelimiter start="\S\@<=\*\|\*\S\@=" end="\S\@<=\*\|\*\S\@=" skip="\\\*"  concealends
syn region cmakehelpItalic matchgroup=cmakehelpItalicDelimiter start="\w\@<!_\S\@=" end="\S\@<=_\w\@!" skip="\\_"  concealends
syn region cmakehelpBold matchgroup=cmakehelpBoldDelimiter start="\S\@<=\*\*\|\*\*\S\@=" end="\S\@<=\*\*\|\*\*\S\@=" skip="\\\*"  concealends
syn region cmakehelpBold matchgroup=cmakehelpBoldDelimiter start="\w\@<!__\S\@=" end="\S\@<=__\w\@!" skip="\\_"  concealends
syn region cmakehelpBoldItalic matchgroup=cmakehelpBoldItalicDelimiter start="\S\@<=\*\*\*\|\*\*\*\S\@=" end="\S\@<=\*\*\*\|\*\*\*\S\@=" skip="\\\*"  concealends
syn region cmakehelpBoldItalic matchgroup=cmakehelpBoldItalicDelimiter start="\w\@<!___\S\@=" end="\S\@<=___\w\@!" skip="\\_"  concealends

syn match cmakehelpVersionadded /^ \+\.\. versionadded:: [0-9].*$/

syn region cmakehelpRef matchgroup=cmakehelpRefDelimiter start=/:ref:`/ end=/`/ oneline concealends

syn clear cmakeRegistry
syn clear cmakeArguments

" syn region cmakeArguments contained start="(" end=")" contains=ALLBUT,cmakeCommand,cmakeCommandConditional,cmakeCommandRepeat,cmakeCommandDeprecated,cmakeArguments,cmakeTodo
syn region cmakehelpCodeblock start=/ [A-Za-z_]\+(/ end=/)\n\n/ contains=cmakeCommand
" contains=cmakeCommand,cmakeCommandConditional,cmakeCommandRepeat,cmakeCommandDeprecated,cmakeArguments,cmakeTodo

hi def link cmakehelpH1                    htmlH1
hi def link cmakehelpH2                    htmlH2
hi def link cmakehelpHeadingRule           PreProc
hi def link cmakehelpItalic                htmlItalic
hi def link cmakehelpItalicDelimiter       cmakehelpItalic
hi def link cmakehelpBold                  htmlBold
hi def link cmakehelpBoldDelimiter         cmakehelpBold
hi def link cmakehelpBoldItalic            htmlBoldItalic
hi def link cmakehelpBoldItalicDelimiter   cmakehelpBoldItalicDelimiter
hi def link cmakehelpCodeDelimiter         Delimiter
hi def link cmakehelpCode                  PreProc
hi def link cmakehelpVersionadded          Comment
hi def link cmakehelpRef                   Underlined
hi def link cmakehelpRefDelimiter          Delimiter

let b:current_syntax = 'cmakehelp'
