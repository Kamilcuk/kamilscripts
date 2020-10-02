" kamilscripts/etc/vimrc

source $VIMRUNTIME/defaults.vim

let mojevimbackupdir = '/tmp/.vimbackupdir'.$USER.'/'
silent execute '!mkdir -p '.mojevimbackupdir.' && chmod 777 '.mojevimbackupdir.''
execute 'set backupdir^='.mojevimbackupdir
execute 'set directory^='.mojevimbackupdir
execute 'set viewdir^='.mojevimbackupdir
execute 'set dir^='.mojevimbackupdir
execute 'set backupskip^='.mojevimbackupdir.'*'

" https://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

set swapfile      " When this option is not empty a swap file is synced to disk after writing to it.
set nowritebackup " Make a backup before overwriting a file.
set nobackup      " Turn on backup option

set backspace=indent,eol,start  " let backspece delete everything in intsert mode
set history=500                 " keep 50 lines of command line history
set ruler                       " show the cursor position all the time
set showcmd                     " display incomplete commands
set incsearch                   " do incremental searching
set pastetoggle=<F2>            " toggle F2 for paste
set background=dark

" https://vim.fandom.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:200,%,n~/.viminfo
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction
augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

set autoindent  " Copy indent from current line when starting a new line

colorscheme ron
syntax on

set mouse=
autocmd BufEnter * set mouse=

set tabstop=4 " The width of a hard tabstop measured in spaces -- effectively the (maximum) width of an actual tab character.
set shiftwidth=4 " The size of an indent. It's also measured in spaces, so if your code base indents with tab characters then you want shiftwidth to equal the number of tab characters times tabstop. This is also used by things like the =, > and < commands.
" set softtabstop " Setting this to a non-zero value other than tabstop will make the tab key (in insert mode) insert a combination of spaces (and possibly tabs) to simulate tab stops at this width.
" set expandtab " Enabling this will make the tab key (in insert mode) insert spaces instead of tab characters. This also affects the behavior of the retab command.
" set smarttab " Enabling this will make the tab key (in insert mode) insert spaces or tabs to go to the next indent of the next tabstop when the cursor is at the beginning of a line (i.e. the only preceding characters are whitespace).

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

" add yaml stuffs
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

" https://github.com/thoughtbot/dotfiles/pull/641
" Set tags for fugitive
:set tags^=./.git/tags;

" Download vim-plug automatically
if !filereadable(expand('~/.vim/autoload/plug.vim'))
	execute '!echo Installing vim-plug && ( set -x && curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim ) && echo Installed vim-plug'
	source ~/.vim/autoload/plug.vim
endif

call plug#begin('~/.vim/plugged')
call plug#end()











