-- polish.lua

vim.opt.exrc = true
vim.opt.wrap = true

---@class LinterSpec
---@field [1] string
---@field pattern? string
---@field [2] string[]
---@field groups? string[]
---@field [3] table<string, vim.diagnostic.Severity>
---@field severity_map? table<string, vim.diagnostic.Severity>
---@field [4] table
---@field defaults? table
---@field [5] {col_offset?: integer, end_col_offset?: integer, lnum_offset?: integer, end_lnum_offset?: integer}
---@field opts? {col_offset?: integer, end_col_offset?: integer, lnum_offset?: integer, end_lnum_offset?: integer}
---@field col_offset? integer
---@field end_col_offset? integer
---@field lnum_offset? integer
---@field end_lnum_offset? integer

---@class LintersSpec
---@field defaults? table

---@param patterns LinterSpec[]|LintersSpec
local function from_patterns(patterns)
  return function(output, bufnr)
    local diagnostics = {}
    for _, pattern in ipairs(patterns) do
      local args = {
        pattern.pattern or pattern[1],
        pattern.groups or pattern[2],
        pattern.severity_map or pattern[3],
        pattern.defaults or pattern[4] or patterns.defaults,
        pattern.opts or pattern[5] or {
          col_offset = pattern.col_offset,
          end_col_offset = pattern.end_col_offset,
          lnum_offset = pattern.lnum_offset,
          end_lnum_offset = pattern.end_lnum_offset,
        },
      }
      local result = require("lint.parser").from_pattern(unpack(args))(output, bufnr)
      for _, diagnostic in ipairs(result) do
        table.insert(diagnostics, diagnostic)
      end
    end
    return diagnostics
  end
end

-- Add nomad as a linter for hcl files.
if false then
  local lint = pcall("require", "lint")
  if lint then
    lint.linters.nomad = {
      name = "nomad",
      cmd = "nomad",
      stdin = false,
      append_fname = true,
      args = { "job", "validate" },
      stream = "both",
      ignore_exitcode = false,
      parser = from_patterns {
        defaults = { severity = vim.diagnostic.severity.ERROR },
        {
          "[^:]+:(%d+): (.+)",
          { "lnum", "message" },
        },
        {
          "[^:]+:(%d+),(%d+)-(%d+): (.+)",
          { "lnum", "col", "col_end", "message" },
        },
      },
    }
    lint.linters_by_ft = {
      hcl = { "nomad" },
    }
  end
end

local function kc_is_loaded(plugin_name) return require("lazy.core.config").plugins[plugin_name]._.loaded end

vim.cmd [[

set wildmenu
set wildmode=longest,list
" Don't pass messages to |ins-completion-menu|.
if v:version >= 800
	set shortmess+=c
endif
set shortmess-=I " enable intro messages

set scrolloff=6

set cmdheight=1

" https://stackoverflow.com/questions/36724209/disable-beep-of-linux-bash-on-windows-10
set visualbell

" Additional unicode visual pairs.
set matchpairs=(:),{:},[:],❰:❱,≤:≥,«:»

" Highlight current line when leaving buffer buffer
" https://vim.fandom.com/wiki/Highlight_current_line
if 1 | augroup CursorLine
	au!
	au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
	au WinLeave * setlocal nocursorline
augroup END | endif
set nocursorline
set nocursorcolumn

" https://stackoverflow.com/a/16988346/9072753
syntax match nonascii "[^\x00-\x7F]"
highlight nonascii guibg=Red ctermbg=2

if has('nvim')
	let g:ft_man_folding_enable = 0
	let g:man_hardwrap = 0
endif

" Quite a few people accidentally type "q:" instead of ":q" and get confused
" by the command line window.  Give a hint about how to get out.
" If you don't like this you can put this in your vimrc:
" ":augroup vimHints | exe 'au!' | augroup END"
autocmd CmdwinEnter *
			\ echohl Todo |
			\ echo 'You discovered the command-line window! You can close it with ":q".' |
			\ echohl None

" Disable entering ex mode
" https://stackoverflow.com/questions/1269689/to-disable-entering-ex-mode-in-vim
nnoremap Q <Nop>

" Close quickfix window with ESC
" https://github.com/mhinz/vim-grepper/issues/117
autocmd FileType qf if mapcheck('<esc>', 'n') ==# '' | nnoremap <buffer><silent> <esc> :cclose<bar>lclose<CR> | endif

" https://vim.fandom.com/wiki/Search_and_replace_the_word_under_the_cursor
nnoremap <leader>S :%s/\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>

" https://castel.dev/post/lecture-notes-1/
" Run spellchecking using ctrl+l when typing
inoremap <C-l>     <c-g>u<Esc>[s1z=`]a<c-g>u
"nnoremap <leader>p <c-g>u<Esc>[s1z=`]a<c-g>u

nmap <C-w><C-e> :bdelete<CR>

" When opening in diff, go to first change.
if &diff
	autocmd VimEnter *? norm ]c[c
endif

" https://raw.githubusercontent.com/Akin909/Dotfiles/ee774ce0f0ce591e852e207e209c95ae3811f388/vim/configs/autocommands.vim
" Horizontal Rule (78 char long)
autocmd FileType python,perl,ruby,sh,zsh,conf,bash,yaml,make,cmake,*
			\ nnoremap <silent><buffer> <leader>hr
			\ 0i###############################################################################<ESC>^1l
autocmd FileType vim,lua
			\ nnoremap <silent><buffer> <leader>hr
			\ 0i" -----------------------------------------------------------------------------<ESC>^1l
autocmd FileType javascript,php,c,cpp,css
			\ nnoremap <silent><buffer> <leader>hr
			\ 0i/* ------------------------------------------------------------------------- */<ESC>^2l
autocmd FileType lua
			\ nnoremap <silent><buffer> <leader>hr
			\ 0i-------------------------------------------------------------------------------<ESC>^1l

" https://vi.stackexchange.com/questions/10728/splitting-a-line-into-two/10731
nnoremap <leader>s i<CR><Esc>

" https://github.com/thoughtbot/dotfiles/pull/641
" Set tags for fugitive
set tags^=./.git/tags;

" Duplicate the bahavior of Home key as in Eclipse, that I'm used to.
"jump to first non-whitespace on line, jump to begining of line if already at first non-whitespace
"https://superuser.com/questions/301109/move-cursor-to-beginning-of-non-whitespace-characters-in-a-line-in-vim
nmap <silent> <Home> :call LineHome()<cr>
inoremap <silent> <Home> <C-R>=LineHome()<CR>
"map ^[[1~ :call LineHome()<CR>:echo<CR>
"imap ^[[1~ <C-R>=LineHome()<CR>
function! LineHome()
  let x = col('.')
  execute 'normal ^'
  if x == col('.')
    execute 'normal 0'
  endif
  return ''
endfunction

" See :help doxygen.vim
let g:load_doxygen_syntax=1 " Automatically load doxygen for C, C++, C#, IDL and PHP

command! -bar VimConfig :edit ~/.config/nvim/lua/plugins/user.lua
command! -bar KcProfile :profile start ~/tmp/vimprofile.log | profile func * | profile file * " profile vim
command! -bar KcProfileEnd :profile stop
command! -bar -nargs=1 KcLazyConfig :Verbose = require("lazy.core.config").plugins[<f-args>]


" Disable default neovim SQL completion because it makes it very slow.
" :help sql-completion-maps
" let g:omni_sql_no_default_maps=1

function! KcPythonBool(script) abort
	try
		return has('python3') && py3eval(a:script)
	finally
		call kc#log('no python3 support')
	endtry
	return v:false
endfunction

function! KcPythonHasVersion(major, minor) abort
	return KcPythonBool('sys.version_info.major == '.a:major.' and sys.version_info.minor >= '.a:minor)
endfunction

function! KcPythonHasImport(import) abort
	return KcPythonBool('__import__("importlib.util").util.find_spec("'.a:import.'") is not None')
endfunction

" https://vi.stackexchange.com/questions/19680/how-can-i-make-vim-not-use-the-entire-screen-for-spelling-suggestions
set spellsuggest+=10
" Include correct word in spellsuggestiong if it is correct. See :h spellsuggest()
function Kc_spell_suggest_correct_word()
	if len(spellbadword(v:val)[0])
		return []
	endif
	if v:lang ==? 'pl_PL.UTF-8'
		echo 'Słowo "'.v:val.'" jest poprawne.'
	else
		echo 'The word "'.v:val.'" is correct.'
	endif
	return [ [v:val.'_is_correct', 1] ]
endfunction
set spellsuggest=expr:Kc_spell_suggest_correct_word(),10

" https://vi.stackexchange.com/questions/7453/access-a-file-under-subdirectories-of-a-path-through-gf-command/7485#7485
set path+=**

" When typing %% in command line replace it by directory of the file
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

autocmd BufNewFile,BufRead Jenkinsfile setfiletype groovy tabstop=4 ofttabstop=-1 shiftwidth=0 smartindent cpoptions+=I smartindent cindent

" commentstring in alloy to //
autocmd BufNewFile,BufRead *.alloy setlocal commentstring=//\ %s
" Default commentstring to #
autocmd BufNewFile,BufRead * if &syntax == '' | setlocal commentstring=#\ %s | endif

" https://vi.stackexchange.com/a/39270/31698
set listchars=eol:$,tab:⇥¬¬,trail:·,extends:>,precedes:<,space:·

]]

-- https://www.reddit.com/r/AstroNvim/comments/1f89958/how_to_remove_please_install_notifications/
local status, notify = pcall(require, "notify")
if status then
  local orig_notify = getmetatable(notify).__call
  setmetatable(notify, {
    __call = function(_, m, l, o)
      if
        string.find(m, "please install sad")
        or string.find(m, 'vim.tbl_islist is deprecated. Run ":checkhealth vim.deprecated" for more information')
      then
        return
      end
      return orig_notify(_, m, l, o)
    end,
  })
end

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "neo-tree",
  callback = function()
    local state = require("neo-tree.sources.manager").get_state('filesystem', nil, nil)
    state.commands.order_by_modified(state)
  end,
})


