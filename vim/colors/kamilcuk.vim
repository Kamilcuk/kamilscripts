" Kamil Cukrowski color scheme

" Init {{{1
let s:dark = &background == "dark"

" Load Papercolor {{{1

let g:PaperColor_Theme_Options = {
			\
			\   'theme': {
			\     'default': {
			\        'allow_bold': 1,
			\        'allow_italic': 1,
			\     },
			\     'default.light': {
			\       'NO_CONVERSION': 0,
			\       'override' : {
			\       'color00' : ['#FFFFFF'],
			\       'color01' : ['#af0000'],
			\       'color02' : ['#008700'],
			\       'color03' : ['#5f8700'],
			\       'color04' : ['#0087af'],
			\       'color05' : ['#878787'],
			\       'color06' : ['#005f87'],
			\       'color07' : ['#000000'],
			\       'color08' : ['#bcbcbc'],
			\       'color09' : ['#d70000'],
			\       'color10' : ['#7F0055'],
			\       'color11' : ['#8700af'],
			\       'color12' : ['#d75f80'],
			\       'color13' : ['#d75f00'],
			\       'color14' : ['#005faf'],
			\       'color15' : ['#005f87'],
			\       'color16' : ['#0087af'],
			\       'color17' : ['#008700'],
			\       'cursor_fg' : ['#ffffff'],
			\       'cursor_bg' : ['#000000'],
			\       'cursorline' : ['#e4e4e4'],
			\       'cursorcolumn' : ['#e4e4e4'],
			\       'cursorlinenr_fg' : ['#af00af'],
			\       'cursorlinenr_bg' : ['#d0d0d0'],
			\       'popupmenu_fg' : ['#000000'],
			\       'popupmenu_bg' : ['#d0d0d0'],
			\       'search_fg' : ['#000000'],
			\       'search_bg' : ['#ffff5f'],
			\       'linenumber_fg' : ['#b2b2b2'],
			\       'linenumber_bg' : ['#eeeeee'],
			\       'vertsplit_fg' : ['#005f87'],
			\       'vertsplit_bg' : ['#eeeeee'],
			\       'statusline_active_fg' : ['#e4e4e4'],
			\       'statusline_active_bg' : ['#005f87'],
			\       'statusline_inactive_fg' : ['#000000'],
			\       'statusline_inactive_bg' : ['#d0d0d0'],
			\       'todo_fg' : ['#00af5f'],
			\       'todo_bg' : ['#eeeeee'],
			\       'error_fg' : ['#af0000'],
			\       'error_bg' : ['#ffd7ff'],
			\       'matchparen_bg' : ['#c6c6c6'],
			\       'matchparen_fg' : ['#005f87'],
			\       'visual_fg' : ['#eeeeee'],
			\       'visual_bg' : ['#0087af'],
			\       'folded_fg' : ['#0087af'],
			\       'folded_bg' : ['#afd7ff'],
			\       'wildmenu_fg': ['#000000'],
			\       'wildmenu_bg': ['#ffff00'],
			\       'spellbad':   ['#ffafd7'],
			\       'spellcap':   ['#ffffaf'],
			\       'spellrare':  ['#afff87'],
			\       'spelllocal': ['#d7d7ff'],
			\       'diffadd_fg':    ['#008700'],
			\       'diffadd_bg':    ['#afffaf'],
			\       'diffdelete_fg': ['#af0000'],
			\       'diffdelete_bg': ['#ffd7ff'],
			\       'difftext_fg':   ['#0087af'],
			\       'difftext_bg':   ['#ffffd7'],
			\       'diffchange_fg': ['#000000'],
			\       'diffchange_bg': ['#ffd787'],
			\       'tabline_bg':          ['#005f87'],
			\       'tabline_active_fg':   ['#000000'],
			\       'tabline_active_bg':   ['#e4e4e4'],
			\       'tabline_inactive_fg': ['#eeeeee'],
			\       'tabline_inactive_bg': ['#0087af'],
			\       'buftabline_bg':          ['#005f87'],
			\       'buftabline_current_fg':  ['#000000'],
			\       'buftabline_current_bg':  ['#e4e4e4'],
			\       'buftabline_active_fg':   ['#eeeeee'],
			\       'buftabline_active_bg':   ['#005faf'],
			\       'buftabline_inactive_fg': ['#eeeeee'],
			\       'buftabline_inactive_bg': ['#0087af']
			\       }
			\     }
			\   },
			\   'language': {
			\     'python': {
			\       'highlight_builtins' : 1
			\     },
			\     'cpp': {
			\       'highlight_standard_library': 1
			\     },
			\     'c': {
			\       'highlight_builtins' : 1
			\     }
			\   }
			\ }

" https://github.com/NLKNguyen/papercolor-theme
let g:airline_theme = 'papercolor'
runtime colors/PaperColor.vim

" Load all names for xterm256 variables, see autoload
call kc#xterm256color#load()
call kc#xterm256color#KcHi()

" Don't let PaperColor mess up with terminal colors
" I want them as they are
let i=1 | while i <= 15 | execute 'if exists("g:terminal_color_'.i.'") | unlet g:terminal_color_'.i.' | endif' | let i+=1 | endwhile
unlet i
if exists("g:terminal_ansi_colors") | unlet g:terminal_ansi_colors | endif

" Standard colors {{{1

" http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html

" Cursor is set above also
" hi clear CursorLine after
hi CursorLineNr cterm=bold gui=bold

KcHi! cInclude x_DodgerBlue2_27 cterm=none gui=none
KcHi! cInclude x_Black_0 cterm=italic gui=italic
hi cRepeat cterm=italic gui=italic
KcHi! cDefine x_DodgerBlue1_33
" hi cStorageClass cterm=bold gui=bold ctermfg=126 guifg=#7F0087

hi Repeat cterm=italic gui=italic
hi Conditional cterm=italic gui=italic

hi link doxygenBrief Comment
hi link doxygenStartSpecial Comment

" kamilscripts/vim/syntax/c.vim {{{1
KcHi! KcStandardCFuncs x_Purple4_54 cterm=bold gui=bold
hi link KcDefine cInclude
KcHi! KcDefineSlash x_Red_9

" TermDebug vim plugin configuration {{{1
KcHi! debugPC x_LightSkyBlue1_153 term=reverse
KcHi! debugBreakpoint x_Red_9 term=reverse

" vim-dispatch {{{1

" Dispatch colors for vim-dispatch with my patch
KcHi DispatchAbortedMsg   bg=x_Red_9   fg=x_Black_0
KcHi DispatchFailureMsg   bg=x_Red_9   fg=x_Black_0
KcHi DispatchSuccessMsg   bg=x_Green_2 fg=x_Black_0
KcHi DispatchCompleteMsg  bg=x_Green_2 fg=x_Black_0

" LspCxx stuff {{{1

" 3 manually configured in lsp
KcHi LspCxxHlGroupNamespace x_MediumOrchid3_133
KcHi LspCxxHlGroupEnumConstant x_DarkSeaGreen2_157 cterm=italic,bold gui=italic,bold
KcHi LspCxxHlGroupMemberVariable x_Black_0 cterm=bold gui=bold
" overwrite the defaults for the rest
hi LspCxxHlSymMethod cterm=bold gui=bold
hi LspCxxHlSymStaticMethod cterm=bold gui=bold
hi LspCxxHlSymEnum cterm=italic,bold gui=italic,bold guifg=#A070A0
hi LspCxxHlGroupEnumConstant cterm=italic gui=italic
KcHi LspCxxHlSymParameter cterm=none gui=none x_Grey63_139
KcHi LspCxxHlSymField cterm=none gui=none x_DeepPink4_53
KcHi LspCxxHlSymUnknownStaticField cterm=none gui=none x_MediumPurple4_60
hi link LspCxxHlSkippedRegion normal
" Highlight local variables Green
KcHi! LspCxxHlSymFunctionVariable x_Green_2 cterm=none gui=none
" Highlight statics Red
KcHi! LspCxxHlSymUnknownStatic x_Red_9 cterm=none gui=none
" Highlight globals Red with Bold text
KcHi! LspCxxHlSymUnknownNone x_Red_9 cterm=bold gui=bold

" NERDTree File highlighting {{{1

" https://github.com/preservim/nerdtree/issues/201#issuecomment-197373760
function! NERDTreeHighlightFile_syn_match(name, extension) abort
	" NERTTree inserts BEL character 0x07 ^G before and after the filename,
	" match it also with a \? to be safe
	exec 'autocmd FileType nerdtree syn match kc_nerdtree_'.a:name.' #^\s\+\?.*\.'.a:extension.'\(\?\s\+\[RO\]\)\?$#'
endfunction
function! NERDTreeHighlightFileLink(extension, name, ...) abort
	let l:name = a:0 >= 1 ? a:1 : substitute(a:extension, '[^a-zA-Z_0-9]*', '', 'g')
	exec 'autocmd FileType nerdtree highlight link kc_nerdtree_'.l:name.' '.a:name
	call NERDTreeHighlightFile_syn_match(l:name, a:extension)
endfunction

" to develop use :vsplit autoload/kc/xterm256colornames.vim
" :colorscheme kamilcuk | :NERDTreeClose | :NERDTree
call NERDTreeHighlightFileLink('vim'                 , s:dark ? 'x_LightSeaGreen_37' : 'x_DarkGreen_22')
call NERDTreeHighlightFileLink('jade'                , 'x_DarkSeaGreen3_150')
call NERDTreeHighlightFileLink('ini'                 , 'x_DarkTurquoise_44')
call NERDTreeHighlightFileLink('\(yaml\|yml\)'       , s:dark ? 'x_IndianRed1_204' : 'x_DarkRed_52')
call NERDTreeHighlightFileLink('config'              , 'x_DarkCyan_36')
call NERDTreeHighlightFileLink('conf'                , s:dark ? 'x_DodgerBlue1_33' : 'x_DarkBlue_18')
call NERDTreeHighlightFileLink('json'                , s:dark ? 'x_LightSkyBlue1_153' : 'x_Blue1_21')
call NERDTreeHighlightFileLink('html'                , 'x_DarkOliveGreen3_107')
call NERDTreeHighlightFileLink('styl'                , 'x_Cyan3_43')
call NERDTreeHighlightFileLink('css'                 , 'x_Cyan2_50')
call NERDTreeHighlightFileLink('coffee'              , 'x_Red3_124')
call NERDTreeHighlightFileLink('js'                  , s:dark ? 'x_LightCoral_210' : 'x_Orange4_58')
call NERDTreeHighlightFileLink('php'                 , 'x_Magenta3_127')
call NERDTreeHighlightFileLink('ds_store'            , s:dark ? 'x_Gold3_178' : 'x_Grey3_232')
call NERDTreeHighlightFileLink('gitconfig'           , 'x_Grey1_232')
call NERDTreeHighlightFileLink('gitignore'           , 'x_Grey2_232')
call NERDTreeHighlightFileLink('bash\(rc\|profile\)' , s:dark ? 'x_SeaGreen1_85' : 'x_DarkSeaGreen_108')
call NERDTreeHighlightFileLink('[ch]'                , s:dark ? 'x_Orchid1_213' : 'x_DarkMagenta_90')
call NERDTreeHighlightFileLink('[ch]pp'              , s:dark ? 'x_Orchid2_212' : 'x_DarkMagenta_91')
call NERDTreeHighlightFileLink('\(tx_Green1_t\|rst\|md\)'    , s:dark ? 'x46' : 'x_DarkGreen_22')
call NERDTreeHighlightFileLink('cmake'               , s:dark ? 'x_LightSteelBlue_147' : 'x_NavyBlue_17')
call NERDTreeHighlightFileLink('m4'                  , 'x_SteelBlue3_68')
call NERDTreeHighlightFileLink('ld'                  , s:dark ? 'x_Pink1_218' : 'x_DeepPink4_89')
call NERDTreeHighlightFileLink('\(a\|o\)'            , 'x_Gold3_142')

delf NERDTreeHighlightFileLink
delf NERDTreeHighlightFile_syn_match

" }}}
" Unused {{{1

function! NERDTreeHighlightFile_old(extension, fg, ...) abort
	"                                              bg, guifg, guibg
	" Optionally takes additional arguments, if `guifg` is not specified, the
	" same as for fg is used. If `bg` is not specified, "none" is used. If `guibg`
	" is not specified, the value for `bg` is used.
	let l:name = a:0 >= 1 ? a:1 : substitute(a:extension, '[^a-zA-Z_0-9]*', '', 'g')
	let l:bg = a:0 >= 1 ? a:1 : 'none'
	let l:guifg = a:0 >= 2 ? a:2 : a:fg
	let l:guibg = a:0 >= 3 ? a:3 : l:bg
	if a:0 >= 4
		echoe "NERDTreeHighlightFile: Invalid count of arguments"
		return
	endif
	exec 'autocmd FileType nerdtree highlight nerdtree_'.l:name.' ctermfg='.a:fg.' ctermbg='.l:bg.' guifg='.l:guifg.' guibg='.l:guibg
	call NERDTreeHighlightFile_syn_match(l:name, a:extension)
endfunction
delf NERDTreeHighlightFile_old

" }}}
" vim: foldmethod=marker

