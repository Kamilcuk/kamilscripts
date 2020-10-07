" kamilscripts/etc/vimrc

source $VIMRUNTIME/defaults.vim

if $LANG == 'en_US.UTF-8'
	set langmenu=pl_PL
	let $LANG = 'pl_PL.UTF-8'
	source $VIMRUNTIME/delmenu.vim
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
syntax on
colorscheme ron

set tabstop=4 " The width of a hard tabstop measured in spaces -- effectively the (maximum) width of an actual tab character.
set shiftwidth=4 " The size of an indent. It's also measured in spaces, so if your code base indents with tab characters then you want shiftwidth to equal the number of tab characters times tabstop. This is also used by things like the =, > and < commands.
" set softtabstop " Setting this to a non-zero value other than tabstop will make the tab key (in insert mode) insert a combination of spaces (and possibly tabs) to simulate tab stops at this width.
" set expandtab " Enabling this will make the tab key (in insert mode) insert spaces instead of tab characters. This also affects the behavior of the retab command.
" set smarttab " Enabling this will make the tab key (in insert mode) insert spaces or tabs to go to the next indent of the next tabstop when the cursor is at the beginning of a line (i.e. the only preceding characters are whitespace).

" https://vi.stackexchange.com/questions/2162/why-doesnt-the-backspace-key-work-in-insert-mode
set backspace=indent,eol,start  " let backspece delete everything in intsert mode

" Tell vim to remember certain things when we
set viminfo=%,'100,/50,:500,<800,@500,h,n~/.cache/vim/viminfo
"           | |    |   |    |    |    | + viminfo file path
"           | |    |   |    |    |    + disable 'hlsearch' loading viminfo
"           | |    |   |    |    + items in the input-line history
"           | |    |   |    + number of lines for each register
"           | |    |   + items in the command-line history
"           | |    + search history saved
"           | + number of edited files for which marks are remembered
"           + save/restore buffer list

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
autocmd BufEnter * set mouse=

" Some yaml specific stuffs.
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

"""""""""" Plugins """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if isdirectory('/usr/lib/kamilscripts/')
	let kamilscripts = '/usr/lib/kamilscripts/'
elseif isdirectory($HOME . '/.config/kamilscripts/kamilscripts/')
	let kamilscripts = $HOME . '/.config/kamilscripts/kamilscripts/'
endif

packadd! editexisting
packadd! termdebug

" set the runtime path to include Vundle and initialize
if exists("kamilscripts") && filereadable(kamilscripts . 'vim/vim-pathogen/autoload/pathogen.vim')
	execute 'source ' . kamilscripts . '/vim/vim-pathogen/autoload/pathogen.vim'
	execute pathogen#infect(kamilscripts . '/vim/{}')
else
	autocmd VimEnter * echom "~/.vimrc: ERROR: No kamilscripts"
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
let g:workspace_undodir = $HOME . '/.vim/vim-workspace-undodir/'
let g:workspace_nocompatible = 0
" let g:workspace_session_disable_on_args = 1

" michaelb/vim-tips
let g:vim_tips_tips_frequency = 0.5

" morhetz/gruvbox
let g:gruvbox_contrast_dark = 'hard'
try
	colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
endtry

" https://github.com/derekwyatt/vim-fswitch
au! BufEnter *.cpp,*.cc,*.c let b:fswitchdst = 'h,hpp'    | let b:fswitchlocs = 'reg:/src/include/,../include,./'
au! BufEnter *.h,*.hpp      let b:fswitchdst = 'cpp,cc,c' | let b:fswitchlocs = 'reg:/include/src/,../src,./'

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

