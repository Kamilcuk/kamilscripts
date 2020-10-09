" kamilscripts/etc/vimrc

source $VIMRUNTIME/defaults.vim

if $LC_CTYPE == 'pl_PL.UTF-8'
	source $VIMRUNTIME/delmenu.vim
	set langmenu=pl_PL.UTF-8
	language pl_PL.UTF-8
	source $VIMRUNTIME/menu.vim
endif

if 0
	" change backupdir to temporary directory
	" not needed - all caches are now stored in cache
	let myvimbackupdir = '/tmp/.vimbackupdir-'.$USER.'/'
	if !isdirectory(myvimbackupdir) | call mkdir(myvimbackupdir) | call setfperm(myvimbackupdir, 'rxwrxwrxw') | endif
	execute 'set backupdir^='.myvimbackupdir
	execute 'set directory^='.myvimbackupdir
	execute 'set backupskip^='.myvimbackupdir.'*'
	unlet myvimbackupdir
endif

" HOW-TO make vim not suck Out of the Box
set nocompatible   " This option has the effect of making Vim either more Vi-compatible, or make Vim behave in a more useful way.
set ruler          " Show the line and column number of the cursor position, separated by a comma
set laststatus=2   " The value of this option influences when the last window will have a status line:
set showcmd        " Show (partial) command in the last line of the screen.
set showmode       " If in Insert, Replace or Visual mode put a message on the last line.
set incsearch      " While typing a search command, show where the pattern, as it was typed so far, matches.
set ignorecase     " Ignore case in search patterns.
set smartcase      " Override the 'ignorecase' option if the search pattern contains upper case characters.
set hlsearch       " When there is a previous search pattern, highlight all its matches.
set number
set relativenumber
set autowriteall
set nohidden
set swapfile      " When this option is not empty a swap file is synced to disk after writing to it.
set writebackup   " Make a backup before overwriting a file.
set nobackup      " Turn on backup option
set autoindent    " Copy indent from current line when starting a new line
set history=500                 " keep 50 lines of command line history
set pastetoggle=<F2>            " toggle F2 for paste
filetype plugin indent on
syntax enable
" colorscheme ron
set encoding=utf-8

set tabstop=4 " The width of a hard tabstop measured in spaces -- effectively the (maximum) width of an actual tab character.
set shiftwidth=4 " The size of an indent. It's also measured in spaces, so if your code base indents with tab characters then you want shiftwidth to equal the number of tab characters times tabstop. This is also used by things like the =, > and < commands.
" set softtabstop " Setting this to a non-zero value other than tabstop will make the tab key (in insert mode) insert a combination of spaces (and possibly tabs) to simulate tab stops at this width.
" set expandtab " Enabling this will make the tab key (in insert mode) insert spaces instead of tab characters. This also affects the behavior of the retab command.
" set smarttab " Enabling this will make the tab key (in insert mode) insert spaces or tabs to go to the next indent of the next tabstop when the cursor is at the beginning of a line (i.e. the only preceding characters are whitespace).

" https://vi.stackexchange.com/questions/2162/why-doesnt-the-backspace-key-work-in-insert-mode
set backspace=indent,eol,start  " let backspece delete everything in intsert mode

" Tell vim to remember certain things when we
set viminfo='100,/50,:500,<800,@500,h,n~/.cache/vim/viminfo
"           |    |   |    |    |    | + viminfo file path
"           |    |   |    |    |    + disable 'hlsearch' loading viminfo
"           |    |   |    |    + items in the input-line history
"           |    |   |    + number of lines for each register
"           |    |   + items in the command-line history
"           |    + search history saved
"           + number of edited files for which marks are remembered

" $VIMRUNTIME/defaults.vim
" Put these in an autocmd group, so that you can revert them with:
augroup vimStartup | au! | augroup END
" https://vim.fandom.com/wiki/Make_views_automatic
set viewoptions-=options
let g:skipview_files = []
function! MakeViewCheck()
    if has('quickfix') && &buftype =~ 'nofile'
        " Buffer is marked as not a file
        return 0
    endif
    if empty(glob(expand('%:p')))
        " File does not exist on disk
        return 0
    endif
    if len($TEMP) && expand('%:p:h') == $TEMP
        " We're in a temp dir
        return 0
    endif
    if len($TMP) && expand('%:p:h') == $TMP
        " Also in temp dir
        return 0
    endif
    if index(g:skipview_files, expand('%')) >= 0
        " File is in skip list
        return 0
    endif
	if &filetype =~# 'commit'
		" If it's a commit message
		return 0
	endif
    return 1
endfunction
augroup vimrcAutoView
    autocmd!
    " Autosave & Load Views.
    autocmd BufWritePost,BufLeave,WinLeave ?* if MakeViewCheck() | mkview | endif
	" When entering, restore window position __and__ cursor position.
    autocmd BufWinEnter ?*
		\ if MakeViewCheck()
		\ | silent loadview
		\ | if line("'\"") >= 1 && line("'\"") <= line("$")
		\ | call setpos(".", getpos("'\""))
		\ | endif
		\ | endif
augroup end

" I do not like mouse
set mouse=
autocmd BufEnter ?* set mouse=

" Some yaml specific stuffs.
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

" Automatically generate tags for custom documentation files
" https://vim.fandom.com/wiki/Add_your_note_files_to_Vim_help
autocmd BufWritePost ~/.vim/doc/* :helptags ~/.vim/doc

" https://vim.fandom.com/wiki/Highlight_current_line
if 1
	" color picked from gruvbox color pallete
	hi CursorLine   cterm=NONE ctermbg=229
	hi CursorColumn cterm=NONE ctermbg=229
	augroup CursorLine
		au!
		au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
		au WinLeave * setlocal nocursorline
	augroup END
endif

" https://vim.fandom.com/wiki/Cscope
if has('cscope') && has('quickfix')
	set cscopetag
	set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-,a-
endif

"""""""""" Plugins """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

packadd! editexisting
packadd! termdebug

for i in [
		\ '/usr/lib/kamilscripts/',
		\ $HOME . '/.config/kamilscripts/kamilscripts/',
		\ $HOME . '/.local/kamilscripts/' ]
	if isdirectory(i) && isdirectory(i. '/vim')
		let g:kamilscripts = i
		break
	endif
endfor
unlet i

" set the runtime path to include Vundle and initialize
if exists("g:kamilscripts") && filereadable(g:kamilscripts . 'vim/bundle/vim-pathogen/autoload/pathogen.vim')
	execute 'source ' . g:kamilscripts . '/vim/bundle/vim-pathogen/autoload/pathogen.vim'
	execute pathogen#infect(g:kamilscripts . '/vim/bundle/{}')
else
	autocmd VimEnter * echom "~/.vimrc: ERROR: No g:kamilscripts"
endif

" https://github.com/thoughtbot/dotfiles/pull/641
" Set tags for fugitive
set tags^=./.git/tags;

" luochen1990/rainbow configuration
let g:rainbow_active = 1 " be active
let g:rainbow_conf = {'separately':{'cmake':0}} " turn off for cmake

" youcompleteme
if !exists('g:ycm_clangd_binary_path') && filereadable('/usr/bin/clangd')
	let g:ycm_clangd_binary_path = '/usr/bin/clangd'
endif
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_confirm_extra_conf = 0
let g:airline#extensions#tabline#enabled = 1

" vim-workspace
let g:workspace_create_new_tabs = 0
let g:workspace_session_directory = $HOME . '/.vim/sessions/'
let g:workspace_persist_undo_history = 1  " enabled = 1 (default), disabled = 0
let g:workspace_undodir = $HOME . '/.vim/undodir/'
let g:workspace_nocompatible = 0
let g:workspace_session_disable_on_args = 1

" michaelb/vim-tips
let g:vim_tips_tips_frequency = 0.5

" morhetz/gruvbox
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_contrast_light = 'hard'
try
	colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
endtry

" https://github.com/derekwyatt/vim-fswitch
let g:fsnonewfiles = 0
autocmd FileType c,cpp  let b:fswitchlocs = './,../include,reg:/src/include/'
autocmd BufEnter *.c    let b:fswitchdst = 'h'
autocmd BufEnter *.h    let b:fswitchdst = 'c,cpp'
autocmd BufEnter *.cpp  let b:fswitchdst = 'h,hpp'
autocmd BufEnter *.hpp  let b:fswitchdst = 'cpp'

" https://github.com/aperezdc/vim-template
let g:templates_directory = [ g:kamilscripts . "/vim/templates/" ]

" Add nice versions of background jobs if available
" The nice versions are within kamilscripts/bin
if !exists('g:ycm_server_python_interpreter') && executable(',nicepython3')
	let g:ycm_server_python_interpreter = ',nicepython3'
endif
if !exists('g:gutentags_cscope_executable') && executable(',nicecscope')
	let g:gutentags_cscope_executable = ',nicecscope'
endif
if !exists('g:gutentags_ctags_executable') && executable(',nicectags')
	let g:gutentags_ctags_executable = ',nicectags'
endif
if get(g:, 'ycm_clangd_binary_path', '/usr/bin/clangd') == '/usr/bin/clangd' && executable(',niceclangd')
	let g:ycm_clangd_binary_path = ',niceclangd'
endif

" https://github.com/FelikZ/ctrlp-py-matcher
let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }

" https://github.com/ggreer/the_silver_searcher
if executable('ag')
	let g:ackprg = 'ag --vimgrep'
endif

" https://vim.fandom.com/wiki/Folding
setlocal foldmethod=syntax
setlocal foldnestmax=10
setlocal nofoldenable
setlocal foldlevel=2

" https://stackoverflow.com/questions/12652172/is-there-any-way-to-adjust-the-format-of-folded-lines-in-vim
function! MyFoldText()
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
set foldtext=MyFoldText()

"""""""""" Shortcuts """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" https://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
" https://vim.fandom.com/wiki/Map_semicolon_to_colon
map ; :
noremap ;; ;
" !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

nnoremap <leader>w :ToggleWorkspace<CR>

" https://vim.fandom.com/wiki/Search_and_replace_the_word_under_the_cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" https://gitter.im/Valloric/YouCompleteMe?at=5d3183545ea6e644ecdf5a7a
nnoremap <leader>gd :YcmCompleter GoToDefinitionElseDeclaration<CR>
nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
nnoremap <leader>gt :YcmCompleter GoToInclude<CR>

" https://github.com/derekwyatt/vim-fswitch
nmap <silent> <Leader>gh :FSHere<cr>

" :h dispatch-maps

command RemoveCurrentFile call delete(expand('%')) | bdelete!

function g:MyCscope(arg)
	execute 'botright copen ' get(g:, 'dispatch_quickfix_height', '')
	wincmd p
	cscope find s:arg <cword>
endfunction
nnoremap <leader>fs :call MyCscope("s")<CR>
nnoremap <leader>fd :call MyCscope("d")<CR>
nnoremap <leader>fc :call MyCscope("c")<CR>
nnoremap <leader>ft :call MyCscope("t")<CR>
nnoremap <leader>fe :call MyCscope("e")<CR>
nnoremap <leader>ff :call MyCscope("f")<CR>
nnoremap <leader>fi :call MyCscope("i")<CR>
nnoremap <leader>fg :call MyCscope("g")<CR>

map <C-n> :NERDTreeToggle<CR>

"""""""""""" Project specific """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" do not load by default
let g:gutentags_dont_load = 1

let g:gutentags_ctags_exclude = [
	\ '*.git', '*.svg', '*.hg', '.git', '.github',
	\ '*/tests/*', '_build', '.build', 'build', '.clangd',
	\ 'dist', '*sites/*/files/*',
	\ 'bin', 'node_modules', 'bower_components', 'cache', 'compiled',
	\ 'docs', 'example', 'bundle', 'vendor', '*.md',
	\ '*-lock.json', '*.lock', '*bundle*.js', '*build*.js',
	\ '.*rc*', '*.json', '*.html', '*.min.*', '*.map', '*.bak',
	\ '*.zip', '*.pyc', '*.class', '*.sln', '*.Master', '*.csproj', '*.tmp',
	\ '*.csproj.user', '*.cache', '*.pdb', 'tags*', 'cscope.*', '*.css',
	\ '*.less', '*.scss', '*.exe', '*.dll', '*.mp3', '*.ogg', '*.flac', '*.swp', '*.swo',
	\ '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png',
	\ '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
	\ '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx',
	\ '*.map', '*.ld', '*.txt', '.vscode', '*.key',
	\ '*.json', '*.cproject', '*.project', 	
	\ ]

let g:ycm_collect_identifiers_from_tags_files = 1
let g:gutentags_modules = [ 'ctags' ]
let g:gutentags_generate_on_new = 1
let g:gutentags_generate_on_missing = 1
let g:gutentags_generate_on_write = 1
let g:gutentags_generate_on_empty_buffer = 0
let g:gutentags_cscope_build_inverted_index = 1
let g:gutentags_ctags_extra_args = [
	\ '--tag-relative=yes',
	\ '-h=.c.h.cpp.hpp.asm.cmake.make',
	\ '--fields=+ailmnS',
	\ ]

let g:gutentags_trace = 0
let g:gutentags_find_args = " -path ./_build -prune -o -regextype egrep -regex .*\.(cpp|hpp|[hcsS])$ "

if getcwd() == "/home/work/beacon"
	let &errorformat = '../../%f:%l:%c: %m'
	let g:gutentags_dont_load = 0
	let g:gutentags_modules += [ 'cscope' ]
	let g:ycm_global_ycm_extra_conf = g:kamilscripts . 'vim/ycm_extra_conf_beacon.py'
	let g:gutentags_ctags_exclude += [ 
		\ '*/Unity/examples',
		\ '*/Unity/extra',
		\ '*/Unity/test', 
		\ '_build_tools/*/examples',
		\ 
		\ ]
	autocmd BufEnter ?* let b:dispatch =  'make debug hw=4.7'
	command Bdebughw47            Dispatch make debug hw=4.7
	command Breleasehw47          Dispatch make release hw=4.7 pcb_test=0
	command Bprogram              Dispatch unbuffer make program
	command Bdebughw47program     Dispatch make debug hw=4.7 && unbuffer make program
	command Breleasehw47program   Dispatch make release hw=4.7 pcb_test=0 && unbuffer make program
endif
