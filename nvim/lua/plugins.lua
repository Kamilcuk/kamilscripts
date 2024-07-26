-- plugins.lua
-- vim: foldmethod=marker
-- {{{1 functions

---Execute a python script and return if it executed successfully
---@param script string
local function KcPythonBool(script) return vim.fn.has "python3" and pcall(vim.fn.py3eval, script) end

--Check if python version
---@param major number
---@param minor number
local function KcHasPythonVersion(major, minor, import)
  return KcPythonBool(([[
      sys.version.infor.major == %d
      and sys.version.info.minor >= %d
      ]]).format(major, minor, import))
end

---Check if python version is higher than major:minor and has import.
---@param major number
---@param minor number
---@param import string
local function KcHasPythonVersionAndImport(major, minor, import)
  return KcPythonBool(([[
      sys.version.infor.major == %d
      and sys.version.info.minor >= %d
      and __import__("importlib.util").util.find_spec(%s) is not None
      ]]).format(major, minor, import))
end

---Log a message once a day.
---@param data string
local function KcLog(data)
  -- Keep a cache of printed lines in a file.
  -- In that file store printed lines. If a line was already printed,
  -- do not print it again.
  -- Remove cache after two day.
  local myfile = vim.fn.stdpath "cache" .. "/kclogcache.txt"
  local lines = vim.fn.filereadable(myfile) ~= 0 and vim.fn.readfile(myfile) or {}
  local stamp = tonumber(lines[0])
  local threshold_s = 3600 * 24 * 2
  if not stamp or vim.fn.localtime() - stamp < threshold_s then lines = {} end
  -- Add current script location to the message.
  local msg = vim.fn.substitute(vim.fn.expand "<sfile>", "..[^.]*$", "", "") .. ": " .. data
  if vim.fn.index(lines, msg) == -1 then
    print(msg)
    vim.fn.writefile({ vim.fn.localtime(), msg }, myfile, "a")
  end
end

-- }}}
-- {{{1 disabled
-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-local
---@type LazySpec
local disabled = {

  -- Doesn't work and makes stuff dissapear. This requires more work and is too buggy.
  {
    "HampusHauffman/block.nvim",
    opts = { automatic = true },
    enabled = false,
  },

  -- using astrocommunity
  { "lspsaga.nvim", opts = { rename = { in_select = false } } },

  -- tabby plugin is much better
  {
    "nvim-lspconfig",
    init = function()
      if vim.fn.executable "tabby-agent" then
        local is_from_npm = vim.fn.system("which tabby-agent"):find "node-modules" ~= nil
        if is_from_npm then
          local version = vim.fn.system "npm list -g tabby-agent | sed -n 's/.*tabby-agent@//p'"
          if version == "1.6.0" then
            KcLog "tabby-agent version 1.6.0 is installed which creates audit.json everywhere. Disabling. Uninstall it."
            return
          end
        end
        require("lspconfig").tabby_ml.setup {}
      end
    end,
  },

  -- using astrocommunity
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "f3fora/cmp-spell", lazy = true },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "spell" })
    end,
  },

  -- using astrocommunity
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "hrsh7th/cmp-calc", lazy = true },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "calc" })
    end,
  },

  -- using astrocommunity
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "hrsh7th/cmp-nvim-lua", lazy = true },
    opts = function(_, opts)
      if not opts.sources then opts.sources = {} end
      table.insert(opts.sources, { name = "nvim_lua" })
    end,
  },

  -- using astrocommunity
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "lukas-reineke/cmp-under-comparator", lazy = true },
    opts = function(_, opts)
      local cmp = require "cmp"
      local find = function(tbl, elem)
        for i, v in ipairs(tbl) do
          if v == elem then return i end
        end
        return nil
      end
      opts.sorting = opts.sorting or {}
      opts.sorting.comparators = opts.sorting.comparators or cmp.get_config().sorting.comparators
      -- Find element in comparators we will position ourselves after.
      local pos = find(opts.sorting.comparators, cmp.config.compare.recently_used)
      if pos == nil then pos = find(opts.sorting.comparators, cmp.config.compare.score) end
      if pos == nil then pos = 3 end
      table.insert(opts.sorting.comparators, pos + 1, require("cmp-under-comparator").under)
    end,
  },

  -- using astrocommunity
  {
    "jackMort/ChatGPT.nvim",
    cmd = { "ChatGPT", "ChatGPTActAs", "ChatGPTEditWithInstructions", "ChatGPTRun" },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          local prefix = "<Leader>G"
          maps.n[prefix] = { desc = require("astroui").get_icon("ChatGPT", 1, true) .. "ChatGPT" }
          maps.v[prefix] = { desc = require("astroui").get_icon("ChatGPT", 1, true) .. "ChatGPT" }
          maps.n[prefix .. "c"] = { "<cmd>ChatGPT<CR>", desc = "ChatGPT" }

          maps.n[prefix .. "C"] = { "<Cmd>ChatGPTActAs<CR>", desc = "ChatGPT Acts As ..." }

          maps.n[prefix .. "e"] = { "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction" }
          maps.v[prefix .. "e"] = { "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction" }

          maps.n[prefix .. "g"] = { "<cmd>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction" }
          maps.v[prefix .. "g"] = { "<cmd>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction" }

          maps.n[prefix .. "t"] = { "<cmd>ChatGPTRun translate<CR>", desc = "Translate" }
          maps.v[prefix .. "t"] = { "<cmd>ChatGPTRun translate<CR>", desc = "Translate" }

          maps.n[prefix .. "k"] = { "<cmd>ChatGPTRun keywords<CR>", desc = "Keywords" }
          maps.v[prefix .. "k"] = { "<cmd>ChatGPTRun keywords<CR>", desc = "Keywords" }

          maps.n[prefix .. "d"] = { "<cmd>ChatGPTRun docstring<CR>", desc = "Docstring" }
          maps.v[prefix .. "d"] = { "<cmd>ChatGPTRun docstring<CR>", desc = "Docstring" }

          maps.n[prefix .. "a"] = { "<cmd>ChatGPTRun add_tests<CR>", desc = "Add Tests" }
          maps.v[prefix .. "a"] = { "<cmd>ChatGPTRun add_tests<CR>", desc = "Add Tests" }

          maps.n[prefix .. "o"] = { "<cmd>ChatGPTRun optimize_code<CR>", desc = "Optimize Code" }
          maps.v[prefix .. "o"] = { "<cmd>ChatGPTRun optimize_code<CR>", desc = "Optimize Code" }

          maps.n[prefix .. "s"] = { "<cmd>ChatGPTRun summarize<CR>", desc = "Summarize" }
          maps.v[prefix .. "s"] = { "<cmd>ChatGPTRun summarize<CR>", desc = "Summarize" }

          maps.n[prefix .. "f"] = { "<cmd>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs" }
          maps.v[prefix .. "f"] = { "<cmd>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs" }

          maps.n[prefix .. "x"] = { "<cmd>ChatGPTRun explain_code<CR>", desc = "Explain Code" }
          maps.v[prefix .. "x"] = { "<cmd>ChatGPTRun explain_code<CR>", desc = "Explain Code" }

          maps.n[prefix .. "r"] = { "<cmd>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit" }
          maps.v[prefix .. "r"] = { "<cmd>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit" }

          maps.n[prefix .. "l"] =
            { "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" }
          maps.v[prefix .. "l"] =
            { "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" }
        end,
      },
      { "AstroNvim/astroui", opts = { icons = { ChatGPT = "󰭹" } } },
    },
    opts = {},
  },

  {
    -- https://github.com/hrsh7th/nvim-cmp/issues/715
    -- Latency setting
    "hrsh7th/nvim-cmp",
    opts = {
      completion = {
        autocomplete = false,
      },
    },
    init = function()
      local timer = nil
      vim.api.nvim_create_autocmd({ "TextChangedI", "CmdlineChanged" }, {
        pattern = "*",
        callback = function()
          if timer then
            vim.loop.timer_stop(timer)
            timer = nil
          end
          timer = vim.loop.new_timer()
          timer:start(
            500,
            0,
            vim.schedule_wrap(function() require("cmp").complete { reason = require("cmp").ContextReason.Auto } end)
          )
        end,
      })
    end,
  },

  -- using vim-workspace
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      autocmds = {
        -- disable alpha autostart
        alpha_autostart = false,
        restore_session = {
          {
            event = { "VimEnter" },
            desc = "Restore previous directory session if neovim opened with no arguments",
            nested = true, -- trigger other autocommands as buffers open
            callback = function()
              -- Logic copied from https://github.com/AstroNvim/AstroNvim/blob/365aa6e083dcd25fa3d1c8a2515d7e71a03d51d3/lua/astronvim/plugins/alpha.lua#L49
              local should_skip
              local lines = vim.api.nvim_buf_get_lines(0, 0, 2, false)
              if
                vim.fn.argc() > 0 -- don't start when opening a file
                or #lines > 1 -- don't open if current buffer has more than 1 line
                or (#lines == 1 and lines[1]:len() > 0) -- don't open the current buffer if it has anything on the first line
                or #vim.tbl_filter(function(bufnr) return vim.bo[bufnr].buflisted end, vim.api.nvim_list_bufs()) > 1 -- don't open if any listed buffers
                or not vim.o.modifiable -- don't open if not modifiable
              then
                should_skip = true
              else
                for _, arg in pairs(vim.v.argv) do
                  if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
                    should_skip = true
                    break
                  end
                end
              end
              if should_skip then return end
              -- if possible, load session
              if not pcall(function() require("resession").load(vim.fn.getcwd(), { dir = "dirsession" }) end) then
                -- if session was not loaded, if possible, load alpha
                require("lazy").load { plugins = { "alpha-nvim" } }
                if pcall(function() require("alpha").start(true) end) then
                  vim.schedule(function() vim.cmd.doautocmd "FileType" end)
                end
              end
            end,
          },
        },
      },
    },
  },

  "nanotee/nvim-lsp-basics", -- does nothing
  "aznhe21/actions-preview.nvim", -- does nothing

  -- sounds are horrible
  {
    "timeyyy/clackclack.symphony",
    enabled = false,
    lazy = false,
    config = function()
      require("k.,soundme"):setup {
        debug = true,
        theme = "clackclack",
      }
    end,
  },

  {
    "timeyyy/bubbletrouble.symphony",
    lazy = false,
    config = function()
      require("soundme"):setup {
        debug = true,
        theme = "oxygen",
      }
    end,
  },

  --
}
-- }}}
---@type LazySpec
return {
  --- {{{1 astrocommunity

  "AstroNvim/astrocommunity",
  -- import/override with your plugins folder

  { import = "astrocommunity.completion.tabby-nvim" },
  { import = "astrocommunity.completion.cmp-git" },
  { import = "astrocommunity.completion.cmp-emoji" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  -- { import = "astrocommunity.editing-support.chatgpt-nvim" },
  { import = "astrocommunity.lsp.garbage-day-nvim" },
  -- { import = "astrocommunity.lsp.inc-rename-nvim" }, -- sreplcaed by lspsaga rename
  -- { import = "astrocommunity.lsp.lsp-lens-nvim" },
  { import = "astrocommunity.lsp.lsp-signature-nvim" },
  -- { import = "astrocommunity.diagnostics.lsp_lines-nvim" },
  { import = "astrocommunity.lsp.nvim-lsp-file-operations" },
  { import = "astrocommunity.lsp.nvim-lint" },
  { import = "astrocommunity.lsp.lspsaga-nvim" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.python-ruff" },
  -- { import = "astrocommunity.pack.cmake" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.search.sad-nvim" },
  -- { import = "astrocommunity.recipes.astrolsp-no-insert-inlay-hints" },
  { import = "astrocommunity.editing-support.auto-save-nvim" },
  { import = "astrocommunity.syntax.vim-sandwich" },
  { import = "astrocommunity.syntax.vim-cool" },
  { import = "astrocommunity.syntax.vim-easy-align" },
  -- { import = "astrocommunity.fuzzy-finder.fzf-lua" },
  -- { import = "astrocommunity.colorscheme.onedarkpro-nvim" },

  { import = "astrocommunity.completion.cmp-nvim-lua" },
  { import = "astrocommunity.completion.cmp-under-comparator" },
  { import = "astrocommunity.completion.cmp-calc" },
  { import = "astrocommunity.completion.cmp-spell" },

  -- }}}
  -- {{{1 astronvim customization
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = { -- extend the plugin options
      diagnostics = {
        virtual_text = false, -- disable diagnostics virtual text
      },
    },
  },

  {
    "AstroNvim/astrolsp",
    opts = {
      features = {
        inlay_hints = false, -- disable inlay hints globally on startup
      },
      formatting = {
        format_on_save = false, -- enable or disable automatic formatting on save
      },
    },
  },

  { "folke/noice.nvim", enabled = true }, -- I hate terminal in the middle, how people work with that?
  { "williamboman/mason-lspconfig.nvim", opts = { automatic_installation = true } },
  { "jay-babu/mason-nvim-dap.nvim", opts = { automatic_installation = true } },
  { "windwp/nvim-autopairs", enabled = false }, -- och god no, no autopairs

  -- }}}
  -- {{{1 :commmands plugins

  {
    "tpope/vim-eunuch",
    lazy = false, -- Make files with shebang executables automatically
  },

  {
    "junegunn/fzf.vim",
    dependencies = {
      "junegunn/fzf",
      lazy = true,
      build = function() vim.api.nvim_call_function("fzf#install", {}) end,
    },
    cmd = {
      "Files",
      "GFiles",
      "Buffers",
      "Colors",
      "Ag",
      "Rg",
      "RG",
      "Lines",
      "BLines",
      "Tags",
      "BTags",
      "Changes",
      "Marks",
      "Jumps",
      "Windows",
      "Locate",
      "History",
      "Snippets",
      "Commits",
      "BCommits",
      "Commands",
      "Maps",
      "Helptags",
      "Filetypes",
    },
  },
  {
    "junegunn/fzf.vim",
    init = function()
      vim.cmd [[
        " Run rg with -options.
	      " https://github.com/junegunn/fzf.vim/blob/master/plugin/fzf.vim#L63
	      command! -bang -nargs=* RGO call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".fzf#shellescape(<q-args>), fzf#vim#with_preview(), <bang>0)',
	      " Run ag with -options.
	      function! KcAg(query, ...)
		      " Allow to pass --options to AG.
		      " https://github.com/junegunn/fzf.vim/blob/a4ce66d72508ce7c626dd7fe1ada9c3273fb5313/autoload/fzf/vim.vim#L761
		      if type(a:query) != v:t_string
			      return s:warn('Invalid query argument')
		      endif
		      let query = empty(a:query) ? '^(?=.)' : a:query
		      let args = copy(a:000)
		      let ag_opts = len(args) > 1 && type(args[0]) == v:t_string ? remove(args, 0) : ''
		      "let command = ag_opts . '--' . fzf#shellescape(query)
		      let command = ag_opts . query
		      echom 'ag '.command
		      return call('fzf#vim#ag_raw', insert(args, command, 0))
	      endfunction
	      command! -bang -nargs=* AG call KcAg(<q-args>, fzf#vim#with_preview(), <bang>0)
	      " Full screen for fzf.
	      let g:fzf_layout = { 'window': { 'width': 0.99, 'height': 0.99 } }
	      ]]
    end,
  },

  { "vim/killersheep", cmd = { "KillKillKill" } },
  { "ThePrimeagen/vim-be-good", cmd = { "VimBeGood" } },
  { "felleg/TeTrIs.vim", cmd = { "Tetris" } },

  { "godlygeek/tabular", lazy = false }, -- :Tabularize Vim script for text filtering and alignment

  -- }}}
  -- {{{1 UI

  { "ntpeters/vim-better-whitespace", lazy = false }, -- Mark whitespaces :StripWhitespace

  {
    "HiPhish/rainbow-delimiters.nvim",
    submodules = false,
  },

  {
    -- "HampusHauffman/bionic.nvim",
    "kamilcuk/bionic.nvim",
    branch = "fix-index-nil-value",
    dependencies = {
      "AstroNvim/astrocore",
      opts = {
        autocmds = {
          bionic = {
            {
              event = "FileType",
              pattern = "*",
              desc = "Activate bionic",
              callback = function() require("bionic").on() end,
            },
          },
        },
      },
    },
  },

  "christoomey/vim-tmux-navigator", -- <ctrl-h> <ctrl-j> move bewteen vim panes and tmux splits seamlessly
  "kshenoy/vim-signature", -- Show marks on the left and additiona m* motions

  {
    -- Install markdown preview, use npx if available.
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      if vim.fn.executable "npx" then
        vim.cmd [[cd app && npx --yes yarn install]]
      else
        vim.fn["mkdp#util#install"]()
      end
    end,
    init = function()
      if vim.fn.executable "npx" then vim.g.mkdp_filetypes = { "markdown" } end
    end,
  },

  -- }}}
  -- {{{1 Filetypes

  "NoahTheDuke/vim-just", -- syntax for justfile
  -- "sheerun/vim-polyglot", -- Solid language pack for vim
  "grafana/vim-alloy", -- Grafana Alloy language support for vim

  -- }}}
  -- {{{1 lsp

  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "andersevenrud/cmp-tmux", lazy = true },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "tmux", options = { all_panes = true } })
    end,
  },

  -- }}}
  -- {{{1 utils

  { "salcode/vim-interactive-rebase-reverse", ft = { "gitrebase", "git" } }, -- reverse order commits during a Git rebase
  "tpope/vim-surround", --  quoting/parenthesizing made simple cs\"' cst\" ds\" ysiw] cs]} ysiw<em>
  "tpope/vim-abolish", -- :S :Abolish easily search for, substitute, and abbreviate multiple variants of a word
  "gyim/vim-boxdraw", -- Ascii box drawing. Open :new, type :set ve=all, and then select region with ctrl+v and type +o
  "samoshkin/vim-mergetool", -- Efficient way of using Vim as a Git mergetool
  "dhruvasagar/vim-table-mode", -- print tables in markdown \tm (TableMode) | --- | --- |

  {
    -- make Vim autodetect the spellcheck language
    "konfekt/vim-DetectSpellLang",
    ft = { "text", "markdown", "mail" },
    cond = function()
      if vim.fn.executable "hunspell" or vim.fn.executable "aspell" then
        return true
      else
        KcLog "DetectSpellLang disabled: no hunspell and no aspell"
        return false
      end
    end,
    init = function()
      vim.cmd [[
        if executable("aspell")
          let aspell_dicts = systemlist("aspell dicts")
          let aspell_dicts = uniq(map(aspell_dicts, {key, val -> substitute(val, '-[^\n]*', '', '')}))
          let g:detectspelllang_program = "aspell"
          let g:detectspelllang_langs = { "aspell": aspell_dicts }
        else
          let output = system("env LANG=C hunspell -D")
          let output = substitute(
               \ output,
                \ '.*AVAILABLE DICTIONARIES[^\n]*\n\(.*\)[^\n]*\(LOADED DICTIONARIES.*\|$\)',
               \ '\1',
               \ '')
          let hunspell_dicts = map(split(output), {key, val -> substitute(val, ".*\/", "", "")})
          let g:detectspelllang_program = "hunspell"
          let g:detectspelllang_langs = { "hunspell": hunspell_dicts }
        endif
      ]]
    end,
  },

  {
    -- Paste images into markdown from neovim
    "TobinPalmer/pastify.nvim",
    ft = "markdown",
    cond = function()
      if KcHasPythonVersionAndImport(3, 8, "PIL") then
        return true
      else
        KcLog "pastify.nvim disabled: no python3.8 or no PIL installed"
        return false
      end
    end,
  },

  { "tpope/vim-scriptease", lazy = false }, -- :Verbose

  { "christoomey/vim-tmux-navigator", lazy = false },

  { "resession.nvim", enabled = false },
  {
    "thaerkh/vim-workspace",
    enabled = true,
    priority = 10000,
    lazy = false,
    init = function()
      vim.cmd [[
      let g:workspace_autosave_ignore = ['gitcommit', "neo-tree", "nerdtree", "qf", "tagbar"]
      let g:workspace_session_disable_on_args = 1
      let g:workspace_session_directory = stdpath("cache") . '/vim-workspace.sessions'
      let g:workspace_undodir= stdpath("cache") . "/vim-workspace.undodir"
      let g:workspace_autocreate = 1
      " nnoremap <leader>W :ToggleWorkspace<CR>
      autocmd VimLeave *
          \ if exists(":Neotree") | execute 'Neotree close' | endif |
          \ if exists(":NERDTreeClose") | execute 'NERDTreeClose' | endif
	    let g:workspace_create_new_tabs = 0
	    let g:workspace_persist_undo_history = 1  " enabled = 1 (default), disabled = 0
	    " Because a bug, these two populate search / history, just disable them.
	    let g:workspace_autosave_untrailtabs = 0
	    let g:workspace_autosave_untrailspaces = 0
	    let g:workspace_nocompatible = 0
	    let g:workspace_session_disable_on_args = 1
	    " https://github.com/thaerkh/vim-workspace/issues/11
	    set sessionoptions-=blank
      ]]
    end,
  },

  -- }}}
  -- {{{1 colorscheme

  -- "cryptomilk/nightcity.nvim",
  {
    "dasupradyumna/midnight.nvim",
    config = function() vim.cmd.colorscheme "midnight" end,
  },

  -- }}}
  -- {{{1 staging

  { "mzlogin/vim-markdown-toc", ft = { "markdown" } }, -- Generate table of contents for markdown :GenToc*

  { "Robitx/gp.nvim", config = true }, -- Talk with AI with neovim

  {
    "mkirc/vim-boxdraw",
    config = function()
      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add {
          mode = "v",
          { "<C-b>", desc = "Select rectangular area with ctrl+v" },
          { "o", desc = "Switch between corners" },
          {
            "g",
            { "c", desc = "Restore selection" },
          },
          { "I", desc = "Insert before each line in block" },
          {
            "+",
            { "o", desc = "Draw a rectangle, clear its contents with whitespace" },
            { "O", desc = "Draw a rectangle, fill it with a label" },
            { "c", desc = "Fill the rectangle with a label" },
            { "-", desc = "Draw a line that ends with a horizontal line" },
            { "_", desc = "Draw a line that ends with a horizontal line" },
            { ">", desc = "Draw a line that ends with a horizontal arrow" },
            { "<", desc = "Draw a line that ends with a horizontal arrow" },
            { "|", desc = "Draw a line that ends with a vertical line" },
            { "^", desc = "Draw a line that ends with a vertical arrow" },
            { "v", desc = "Draw a line that ends with a vertical arrow" },
            { "V", desc = "Draw a line that ends with a vertical arrow" },
            {
              "+",
              desc = "Draw with arrow on both sides of the line",
              {
                ">",
                desc = "Draw a line that ends with a horizontal arrow, and has an arrow on both sides of the line",
              },
              {
                "<",
                desc = "Draw a line that ends with a horizontal arrow, and has an arrow on both sides of the line",
              },
              {
                "^",
                desc = "Draw a line that ends with a vertical arrow,  and has an arrow on both sides of the line",
              },
              {
                "v",
                desc = "Draw a line that ends with a vertical arrow,  and has an arrow on both sides of the line",
              },
              {
                "V",
                desc = "Draw a line that ends with a vertical arrow,  and has an arrow on both sides of the line",
              },
            },
            {
              "i",
              desc = "Select inside",
              { "o", desc = "Select current rectangle, without borders" },
            },
            {
              "a",
              desc = "Select all",
              { "o", desc = "Select current rectangle, with borders" },
            },
            -- extra
            { "~", desc = "Draw a diagonal line" },
          },
        }
      end
      --
      vim.api.nvim_create_user_command("Boxdraw", function()
        if vim.g.boxdraw_enabled ~= nil then
          print "Exiting boxdraw mode"
          vim.opt.virtualedit = vim.g.boxdraw_enabled
          vim.g.boxdraw_enabled = nil
        else
          vim.g.boxdraw_enabled = vim.opt.virtualedit
          vim.opt.virtualedit = "all"
          print [[
Entered boxdraw mode
Ctrl+b           Select rectangular area with ctrl+v
o                Switch between corners
gc               Restore selection
I                Insert before each line in block
y                yank block
1<Ctrl-v>        select shi area elsewhere
p                paste yanked block replace with current selection
+o               Draw a rectangle, clear its contents with whitespace.
+O               Draw a rectangle, fill it with a label.
+c               Fill the rectangle with a label.
+- or +_         Draw a line that ends with a horizontal line:
+> or +<         Draw a line that ends with a horizontal arrow:
++> or ++<       Draw a line that ends with a horizontal arrow, and has an arrow on both sides of the line:
+|               Draw a line that ends with a vertical line:
+^, +v or +V     Draw a line that ends with a vertical arrow.
++^, ++v or ++V  Draw a line that ends with a vertical arrow,                                                                                                  and has an arrow on both sides of the line:
+io              Select current rectangle, without borders.
+ao              Select current rectangle, with borders.
]]
        end
      end, {})
    end,
  }, -- Ascii box drawing. Open :new, type :set ve=all, and then select region with ctrl+v and type +o

  -- }}}
}
