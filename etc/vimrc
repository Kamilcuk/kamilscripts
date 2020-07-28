" kamilscripts/etc/vimrc

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

" Uncomment the following to have Vim jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='100,\"1000,:200,%,n~/.viminfo

set autoindent  " Copy indent from current line when starting a new line
set smartindent " Do smart autoindenting when starting a new line.
set cindent     " Enables automatic C program indenting.

colorscheme ron
syntax on

set mouse=
autocmd BufEnter * set mouse=

" add yaml stuffs
au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

set tabstop=4
set shiftwidth=4

" https://vi.stackexchange.com/questions/84/how-can-i-copy-text-to-the-system-clipboard-from-vim
noremap <Leader>y "*y
noremap <Leader>p "*p
noremap <Leader>Y "+y
noremap <Leader>P "+p

" HOW-TO make vim not suck Out of the Box
set nocompatible ruler laststatus=2 showcmd showmode
set incsearch ignorecase smartcase hlsearch
