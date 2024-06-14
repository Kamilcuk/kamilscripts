-- user.lua

local function KcPythonBool(script) return vim.fn.has "python3" and pcall(vim.fn.py3eval, script) end

local function KcPythonHasVersionAndImport(major, minor, import)
  return KcPythonBool(([[
      sys.version.infor.major == %d
      and sys.version.info.minor >= %d
      and __import__("importlib.util").util.find_spec(%s) is not None
      ]]).format(major, minor, import))
end

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
  if not stamp or vim.fn.localtime() - stamp < threshold_s then
    lines = {}
  end
  -- Add current script location to the message.
  local msg = vim.fn.substitute(vim.fn.expand "<sfile>", "..[^.]*$", "", "") .. ": " .. data
  if vim.fn.index(lines, msg) == -1 then
    print(msg)
    vim.fn.writefile({vim.fn.localtime(), msg}, myfile, "a")
  end
end
---@type LazySpec
return {
  { "folke/noice.nvim", enabled = false }, -- I hate terminal in the middle, how people work with that?
  { "williamboman/mason-lspconfig.nvim", opts = { automatic_installation = true } },
  { "jay-babu/mason-nvim-dap.nvim", opts = { automatic_installation = true } },
  { "windwp/nvim-autopairs", enabled = false },
  "tpope/vim-eunuch",

  {
    "junegunn/fzf",
    lazy = true,
    build = function() vim.api.nvim_call_function("fzf#install", {}) end,
  },
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
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
    "HampusHauffman/block.nvim",
    opts = { automatic = true },
    enabled = false,
  },
  {
    "HampusHauffman/bionic.nvim",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = vim.cmd.BionicOn,
      })
    end,
    enabled = false,
  },

  "christoomey/vim-tmux-navigator", -- <ctrl-h> <ctrl-j> move bewteen vim panes and tmux splits seamlessly
  "kshenoy/vim-signature", -- Show marks on the left and additiona m* motions
  "NoahTheDuke/vim-just", -- syntax for justfile
  "sheerun/vim-polyglot", -- Solid language pack for vim
  "grafana/vim-alloy", -- Grafana Alloy language support for vim

  { "vim/killersheep", cmd = { "KillKillKill" } },
  { "ThePrimeagen/vim-be-good", cmd = { "VimBeGood" } },
  { "felleg/TeTrIs.vim", cmd = { "Tetris" } },

  {
    "jackMort/ChatGPT.nvim",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Leader>G"] = {
                name = "🤖ChatGPT",
                c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
                e = { "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction", mode = { "n", "v" } },
                g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
                t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
                k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
                d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
                a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
                o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
                s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
                f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
                x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
                r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
                l = {
                  "<cmd>ChatGPTRun code_readability_analysis<CR>",
                  "Code Readability Analysis",
                  mode = { "n", "v" },
                },
              },
            },
          },
        },
      },
    },
  },

  { "salcode/vim-interactive-rebase-reverse", ft = { "gitrebase", "git" } }, -- reverse order commits during a Git rebase
  "ntpeters/vim-better-whitespace", -- Mark whitespaces :StripWhitespace
  "tpope/vim-surround", --  quoting/parenthesizing made simple cs\"' cst\" ds\" ysiw] cs]} ysiw<em>
  { "godlygeek/tabular", cmd = { "Tabularize" } }, -- :Tabularize Vim script for text filtering and alignment
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
      if vim.fn.has "nvim" and KcPythonHasVersionAndImport(3, 8, "PIL") then
        return true
      else
        KcLog "no pastify because no nvim or no python3.8 or no PIL"
        return false
      end
    end,
  },

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

  -- "cryptomilk/nightcity.nvim",
  "dasupradyumna/midnight.nvim",
  "tpope/vim-scriptease",
  {
    "HiPhish/rainbow-delimiters.nvim",
    submodules = false,
  },

  -- { "lspsaga.nvim", opts = { rename = { in_select = false } } },
  {
    "nvim-lspconfig",
    init = function()
      if vim.fn.executable "tabby-agent" then require("lspconfig").tabby_ml.setup {} end
    end,
  },

  {
    "christoomey/vim-tmux-navigator",
    lazy = False,
  },


  {
    "resession.nvim",
    enabled = false,
  },
  {
    "thaerkh/vim-workspace",
    enabled = true,
    init = function()
      vim.cmd [[
      let g:workspace_autosave_ignore = ['gitcommit', "neo-tree", "nerdtree", "qf", "tagbar"]
      let g:workspace_session_disable_on_args = 1
      let g:workspace_session_directory = $HOME . '/.vim/sessions/'
      let g:workspace_undodir= $HOME . '/.vim/sessions/.undodir'
      let g:workspace_autocreate = 1
      nnoremap <leader>W :ToggleWorkspace<CR>
      if exists(":Neotree")
        autocmd VimLeave * Neotree close
      endif
      if exists(":NERDTreeClose")
        autocmd VimLeave * NERDTreeClose
      endif
	    let g:workspace_create_new_tabs = 0
	    let g:workspace_persist_undo_history = 1  " enabled = 1 (default), disabled = 0
	    " Becuase a bug, these two populate search / history, just disable them.
	    let g:workspace_autosave_untrailtabs = 0
	    let g:workspace_autosave_untrailspaces = 0
	    let g:workspace_nocompatible = 0
	    let g:workspace_session_disable_on_args = 1
	    " https://github.com/thaerkh/vim-workspace/issues/11
	    set sessionoptions-=blank
      ]]
    end,
  },
  -- {
  --   "AstroNvim/astrocore",
  --   ---@type AstroCoreOpts
  --   opts = {
  --     autocmds = {
  --       -- disable alpha autostart
  --       alpha_autostart = false,
  --       restore_session = {
  --         {
  --           event = { "VimEnter", "StdinReadPost" },
  --           desc = "Restore previous directory session if neovim opened with no arguments",
  --           once = true, -- delete itself after executing once
  --           nested = true, -- trigger other autocommands as buffers open
  --           callback = function(args)
  --             -- Only load the session if nvim was started with no args
  --             if args.event == "VimEnter" and vim.fn.argc(-1) == 0 then
  --               -- try to load a directory session using the current working directory
  --               require("resession").load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true })
  --             end
  --           end,
  --         },
  --       },
  --     },
  --   },
  -- },

  --
}
