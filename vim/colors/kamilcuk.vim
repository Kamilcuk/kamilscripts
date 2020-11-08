" Kamil Cukrowski color scheme

set background=light

let g:PaperColor_Theme_Options = {
			\   'theme': {
			\     'default': {
			\        'allow_bold': 1,
			\        'allow_italic': 1,
			\     },
			\     'default.light': {
			\       'override' : {
			\       'color00' : ['#FFFFFF', '15'],
			\       'color01' : ['#af0000', '124'],
			\       'color02' : ['#008700', '28'],
			\       'color03' : ['#5f8700', '64'],
			\       'color04' : ['#0087af', '31'],
			\       'color05' : ['#878787', '102'],
			\       'color06' : ['#005f87', '24'],
			\       'color07' : ['#000000', '16'],
			\       'color08' : ['#bcbcbc', '250'],
			\       'color09' : ['#d70000', '160'],
			\       'color10' : ['#7F0055', '31'],
			\       'color11' : ['#8700af', '91'],
			\       'color12' : ['#d75f80', '166'],
			\       'color13' : ['#d75f00', '166'],
			\       'color14' : ['#005faf', '25'],
			\       'color15' : ['#005f87', '24'],
			\       'color16' : ['#0087af', '31'],
			\       'color17' : ['#008700', '28'],
			\       'cursor_fg' : ['#ffffff', '255'],
			\       'cursor_bg' : ['#000000', '24'],
			\       'cursorline' : ['#e4e4e4', '254'],
			\       'cursorcolumn' : ['#e4e4e4', '254'],
			\       'cursorlinenr_fg' : ['#af00af', '127'],
			\       'cursorlinenr_bg' : ['#d0d0d0', '255'],
			\       'popupmenu_fg' : ['#000000', '16'],
			\       'popupmenu_bg' : ['#d0d0d0', '252'],
			\       'search_fg' : ['#000000', '16'],
			\       'search_bg' : ['#ffff5f', '227'],
			\       'linenumber_fg' : ['#b2b2b2', '249'],
			\       'linenumber_bg' : ['#eeeeee', '255'],
			\       'vertsplit_fg' : ['#005f87', '24'],
			\       'vertsplit_bg' : ['#eeeeee', '255'],
			\       'statusline_active_fg' : ['#e4e4e4', '254'],
			\       'statusline_active_bg' : ['#005f87', '24'],
			\       'statusline_inactive_fg' : ['#000000', '16'],
			\       'statusline_inactive_bg' : ['#d0d0d0', '252'],
			\       'todo_fg' : ['#00af5f', '35'],
			\       'todo_bg' : ['#eeeeee', '255'],
			\       'error_fg' : ['#af0000', '124'],
			\       'error_bg' : ['#ffd7ff', '225'],
			\       'matchparen_bg' : ['#c6c6c6', '251'],
			\       'matchparen_fg' : ['#005f87', '24'],
			\       'visual_fg' : ['#eeeeee', '255'],
			\       'visual_bg' : ['#0087af', '31'],
			\       'folded_fg' : ['#0087af', '31'],
			\       'folded_bg' : ['#afd7ff', '153'],
			\       'wildmenu_fg': ['#000000', '16'],
			\       'wildmenu_bg': ['#ffff00', '226'],
			\       'spellbad':   ['#ffafd7', '218'],
			\       'spellcap':   ['#ffffaf', '229'],
			\       'spellrare':  ['#afff87', '156'],
			\       'spelllocal': ['#d7d7ff', '189'],
			\       'diffadd_fg':    ['#008700', '28'],
			\       'diffadd_bg':    ['#afffaf', '157'],
			\       'diffdelete_fg': ['#af0000', '124'],
			\       'diffdelete_bg': ['#ffd7ff', '225'],
			\       'difftext_fg':   ['#0087af', '31'],
			\       'difftext_bg':   ['#ffffd7', '230'],
			\       'diffchange_fg': ['#000000', '16'],
			\       'diffchange_bg': ['#ffd787', '222'],
			\       'tabline_bg':          ['#005f87', '24'],
			\       'tabline_active_fg':   ['#000000', '16'],
			\       'tabline_active_bg':   ['#e4e4e4', '254'],
			\       'tabline_inactive_fg': ['#eeeeee', '255'],
			\       'tabline_inactive_bg': ['#0087af', '31'],
			\       'buftabline_bg':          ['#005f87', '24'],
			\       'buftabline_current_fg':  ['#000000', '16'],
			\       'buftabline_current_bg':  ['#e4e4e4', '254'],
			\       'buftabline_active_fg':   ['#eeeeee', '255'],
			\       'buftabline_active_bg':   ['#005faf', '25'],
			\       'buftabline_inactive_fg': ['#eeeeee', '255'],
			\       'buftabline_inactive_bg': ['#0087af', '31']
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

" Don't let PaperColor mess up with terminal colors
" I want them as they are
let i=1 | while i <= 15 | execute 'if exists("g:terminal_color_'.i.'") | unlet g:terminal_color_'.i.' | endif' | let i+=1 | endwhile
unlet i
if exists("g:terminal_ansi_colors") | unlet g:terminal_ansi_colors | endif

" http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html

" Cursor is set above also
" hi clear CursorLine after
hi CursorLineNr cterm=bold gui=bold

" See kamilscripts/vim/syntax/c.vim
hi KcStandardCFuncs cterm=bold gui=bold guifg=#642880
hi link KcDefine cInclude
hi KcDefineSlash ctermfg=red

hi cInclude cterm=none gui=none ctermfg=27 guifg=#005fff
hi cDefine cterm=italic gui=italic ctermfg=Black
hi cRepeat cterm=italic gui=italic
hi cDefine ctermfg=33 guifg=#0087ff
" hi cStorageClass cterm=bold gui=bold ctermfg=126 guifg=#7F0087

hi Repeat cterm=italic gui=italic
hi Conditional cterm=italic gui=italic

" Dispatch colors for vim-dispatch with my patch
hi DispatchAbortedMsg   ctermbg=Red   guibg=Red
hi DispatchFailureMsg   ctermbg=Red   guibg=Red
hi DispatchSuccessMsg   ctermbg=Green guibg=LightGreen
hi DispatchCompleteMsg  ctermbg=Green guibg=LightGreen

" 3 manually configured in lsp
hi LspCxxHlGroupNamespace ctermfg=133 guifg=#a635ab
hi LspCxxHlGroupEnumConstant ctermfg=157 guifg=#AD7FA8 cterm=italic,bold gui=italic,bold
hi LspCxxHlGroupMemberVariable ctermfg=Black guifg=#000000 cterm=bold gui=bold
" overwrite the defaults for the rest
hi LspCxxHlSymMethod cterm=bold gui=bold
hi LspCxxHlSymStaticMethod cterm=bold gui=bold
hi LspCxxHlSymEnum cterm=italic,bold gui=italic,bold guifg=#A070A0
hi LspCxxHlGroupEnumConstant cterm=italic gui=italic
hi LspCxxHlSymParameter cterm=none gui=none ctermfg=54
hi LspCxxHlSymField cterm=none gui=none ctermfg=53
hi LspCxxHlSymUnknownStaticField cterm=none gui=none ctermfg=60
hi link LspCxxHlSkippedRegion normal
" Highlight local variables Green
hi! LspCxxHlSymFunctionVariable ctermfg=Green guifg=#00FF00 cterm=none gui=none
" Highlight statics Red
hi! LspCxxHlSymUnknownStatic ctermfg=Red guifg=#FF0000 cterm=none gui=none
" Highlight globals Red with Bold text
hi! LspCxxHlSymUnknownNone ctermfg=Red guifg=#FF0000 cterm=bold gui=bold


hi link doxygenBrief Comment
hi link doxygenStartSpecial Comment

" TermDebug vim plugin configuration
hi debugPC term=reverse ctermbg=lightblue guibg=lightblue
hi debugBreakpoint term=reverse ctermbg=red guibg=red

" NERDTree File highlighting {{{

" https://github.com/preservim/nerdtree/issues/201#issuecomment-197373760
function! NERDTreeHighlightFile_syn_match(name, extension) abort
	" NERTTree inserts BEL character 0x07 ^G before and after the filename,
	" match it also with a \? to be safe
	exec 'autocmd FileType nerdtree syn match kc_nerdtree_'.a:name.' #^\s\+\?.*'.a:extension.'\(\?\s\+\[RO\]\)\?$#'
endfunction
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
function! NERDTreeHighlightFileLink(extension, name, ...) abort
	let l:name = a:0 >= 1 ? a:1 : substitute(a:extension, '[^a-zA-Z_0-9]*', '', 'g')
	exec 'autocmd FileType nerdtree highlight link kc_nerdtree_'.l:name.' '.a:name
	call NERDTreeHighlightFile_syn_match(l:name, a:extension)
endfunction

" Load all names for xterm256 variables, see autoload
call kc#xterm256colornames#load()

" to develop use :vsplit autoload/kc/xterm256colornames.vim
call NERDTreeHighlightFileLink('vim'                 , 'x022_DarkGreen')
call NERDTreeHighlightFileLink('jade'                , 'x150_DarkSeaGreen3')
call NERDTreeHighlightFileLink('ini'                 , 'x044_DarkTurquoise')
call NERDTreeHighlightFileLink('ya\?ml'               , 'x052_DarkRed')
call NERDTreeHighlightFileLink('config'              , 'x036_DarkCyan')
call NERDTreeHighlightFileLink('conf'                , 'x018_DarkBlue')
call NERDTreeHighlightFileLink('json'                , 'x021_Blue1')
call NERDTreeHighlightFileLink('html'                , 'x107_DarkOliveGreen3')
call NERDTreeHighlightFileLink('styl'                , 'x043_Cyan3')
call NERDTreeHighlightFileLink('css'                 , 'x050_Cyan2')
call NERDTreeHighlightFileLink('coffee'              , 'x124_Red3')
call NERDTreeHighlightFileLink('js'                  , 'x058_Orange4')
call NERDTreeHighlightFileLink('php'                 , 'x127_Magenta3')
call NERDTreeHighlightFileLink('ds_store'            , 'x232_Grey3')
call NERDTreeHighlightFileLink('gitconfig'           , 'x232_Grey1')
call NERDTreeHighlightFileLink('gitignore'           , 'x232_Grey2')
call NERDTreeHighlightFileLink('bash\(rc\|profile\)' , 'x108_DarkSeaGreen')
call NERDTreeHighlightFileLink('[ch]'                , 'x090_DarkMagenta')
call NERDTreeHighlightFileLink('[ch]pp'              , 'x091_DarkMagenta')
call NERDTreeHighlightFileLink('\(txt\|rst\|md\)'    , 'x022_DarkGreen')
call NERDTreeHighlightFileLink('cmake'               , 'x017_NavyBlue')
call NERDTreeHighlightFileLink('m4'                  , 'x068_SteelBlue3')
call NERDTreeHighlightFileLink('ld'                  , 'x089_DeepPink4')
call NERDTreeHighlightFileLink('\(a\|o\)'            , 'x142_Gold3')

delf! NERDTreeHighlightFileLink
delf! NERDTreeHighlightFile_old
delf! NERDTreeHighlightFile_syn_match

" }}}
