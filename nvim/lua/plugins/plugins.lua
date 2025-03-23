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

local function KcEnableAtHome()
  -- if user is cukrowsk
  return vim.fn.getenv "USER" ~= "cukrowsk"
end

---@param timeout_s number
---@param start fun(): any
---@param stop fun(any): nil
---@param header string?
local function KcScreensaver(timeout_s, start, stop, header)
  local timer = vim.loop.new_timer()
  local running = false
  local starting = false
  local stopping = false
  local data = nil
  local timeout_ms = timeout_s * 1000
  vim.on_key(function(key, typed)
    -- print(vim.fn.strftime "%c " .. "ON KEY EXEUCTED" .. key .. " " .. typed)
    if running and not starting and not stopping then
      -- print(vim.fn.strftime "%c " .. "STOPPING EXEUCTED")
      running = false
      stopping = true
      vim.schedule(function()
        -- vim.wait(100, function() return not starting end, 100)
        if header then print(vim.fn.strftime "%c " .. "Stopping " .. header) end
        stop(data)
        stopping = false
      end)
    end
    timer:start(timeout_ms, 0, function()
      if not running and not starting and not stopping then
        running = true
        starting = true
        timer:stop()
        vim.schedule(function()
          -- vim.wait(100, function() return not stopping end, 100)
          if header then print(vim.fn.strftime "%c " .. "Starting " .. header) end
          data = start()
          starting = false
        end)
      end
    end)
  end)
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
      opts.sources = opts.sources or {}
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

  -- makes vim sooooo slow
  -- "sheerun/vim-polyglot", -- Solid language pack for vim

  --
}
-- }}}

---@type LazySpec
return {
  -- {{{1 astrocommunity astronvim modifications of configurations in astro customizations

  "AstroNvim/astrocommunity",
  -- import/override with your plugins folder

  {
    import = "astrocommunity.completion.tabby-nvim",
    enabled = false,
    cond = function() return vim.fn.filereadable(vim.fn.expand "~/.tabby-client/agent/config.toml") ~= 0 end,
  },

  -- { import = "astrocommunity.pack.cpp" },
  -- { import = "astrocommunity.pack.lua" },
  -- { import = "astrocommunity.pack.python-ruff" },
  -- { import = "astrocommunity.pack.cmake" },
  -- { import = "astrocommunity.pack.bash" },

  -- { import = "astrocommunity.recipes.astrolsp-no-insert-inlay-hints" }, -- disable insert hits in insert mode only. I disable inlay hits everywhere.
  { import = "astrocommunity.editing-support.auto-save-nvim" },
  -- { import = "astrocommunity.colorscheme.onedarkpro-nvim" },

  -- { import = "astrocommunity.indent.indent-blankline-nvim" }, -- does nothing, already in astronvim

  {
    "astrocore",
    ---@type AstroCoreOpts
    opts = { -- extend the plugin options
      diagnostics = {
        virtual_text = false, -- disable diagnostics virtual text
      },
      autocmds = {
        alpha_autostart = false, -- disable entry screen
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
      config = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "standard",
              },
            },
          },
        },
      },
    },
  },

  {
    -- https://www.mikecoutermarsh.com/astrovim-slow-on-large-files/
    -- Disable to speed up on larger files.
    "RRethy/vim-illuminate",
    event = "User AstroFile",
    opts = {
      large_file_cutoff = 3000,
    },
  },
  { "aerial.nvim", enabled = false },
  { "alpha-nvim", enabled = false }, -- disable entry screen, I do not use it anyway
  { "goolord/alpha-nvim", enabled = false }, -- disable entry screen, I do not use it anyway
  { "folke/noice.nvim", enabled = true }, -- I hate terminal in the middle, how people work with that?
  { "williamboman/mason-lspconfig.nvim", opts = { automatic_installation = true } },
  { "jay-babu/mason-nvim-dap.nvim", opts = { automatic_installation = true } },
  { "windwp/nvim-autopairs", enabled = false }, -- och god no, no autopairs
  { "kdheepak/lazygit.nvim", enabled = false }, -- I have no idea how to use it, I like the tpope plugin
  { "nvim-ts-autotag", enabled = false }, -- no autoclosin

  {
    -- https://www.reddit.com/r/neovim/comments/phndpv/comment/hbl89xp/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    "telescope.nvim",
    dependencies = {
      "astrocore",
      opts = {
        mappings = {
          i = {
            ["<C-Down>"] = require("telescope.actions").cycle_history_next,
            ["<C-Up>"] = require("telescope.actions").cycle_history_prev,
          },
        },
      },
    },
  },

  {
    -- make nvim-notify smaller. I would make it even smaller smaller
    "nvim-notify",
    -- load immidately
    lazy = false,
    priority = 1000,
    opts = function(_, opts)
      opts.render = "wrapped-compact"
      -- Added in my lua path.
      opts.render = "my-wrapped-compact"
      opts.render = "my-wrapped-minimal"
      opts.stages = "static"
      opts.top_down = false
      opts.fps = 1
    end,
  },

  {
    -- Add buffer number in front of buffer name in the tabline.
    "heirline.nvim",
    opts = function(_, opts)
      local status = require "astroui.status"
      local ui_config = require("astroui").config
      local function my_tabline_file_info()
        local tmp = status.component.tabline_file_info()
        table.insert(tmp, 2, {
          provider = function(self) return self and self.bufnr and self.bufnr or "" end,
          hl = { bold = true, underline = true },
        })
        return tmp
      end
      opts.tabline[2] = status.heirline.make_buflist(my_tabline_file_info())
    end,
  },

  {
    -- Add saerch of jump files and jumps. Usefull for finding previous files.
    "astrocore",
    opts = function(_, opts)
      local maps = opts.mappings
      maps.n["<Leader>fj"] = { function() require("telescope.builtin").jumplist() end, desc = "Find jumps" }
      maps.n["<Leader>fq"] = { function() require("k.telescope-add").jumpfilelist() end, desc = "Find jump files" }
    end,
  },

  -- }}}
  -- {{{1 :commmands plugins

  {
    "tpope/vim-eunuch", -- commands like :Remove :Delete :Move :SudoWrite
    lazy = false, -- Load always. It makes files with shebang executables automatically.
  },

  { import = "astrocommunity.fuzzy-finder.fzf-lua" },
  {
    "junegunn/fzf.vim",
    enabled = false, -- using fzf-lua
    dependencies = {
      "junegunn/fzf",
      lazy = true,
      build = function()
        vim.cmd [[Lazy load fzf.vim]]
        vim.fn["fzf#install"]()
      end,
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

  -- Games
  { "vim/killersheep", cmd = { "KillKillKill" }, enabled = false },
  { "ThePrimeagen/vim-be-good", cmd = { "VimBeGood" }, enabled = false },
  { "felleg/TeTrIs.vim", cmd = { "Tetris" }, enabled = false },

  -- { import = "astrocommunity.syntax.vim-easy-align" }, -- never used, like :Tabularize
  { "godlygeek/tabular", lazy = false }, -- :Tabularize Vim script for text filtering and alignment

  -- }}}
  -- {{{1 UI

  { import = "astrocommunity.syntax.vim-cool" }, -- disable search highlight after done searching

  { "ntpeters/vim-better-whitespace", lazy = false }, -- Mark whitespaces :StripWhitespace

  {
    "HiPhish/rainbow-delimiters.nvim",
    submodules = false,
    enabled = false,
  },
  {
    "luochen1990/rainbow",
    lazy = false,
    init = function()
      vim.g.rainbow_active = 1
      vim.g.rainbow_conf = {
        ["parentheses"] = {
          "start=/(/ end=/)/ fold",
          "start=/\\[/ end=/\\]/ fold",
          "start=/{/ end=/}/ fold",
          "start=/«/ end=/»/",
        },
      }
      vim.cmd [[
	        " auto syntax * call rainbow_main#load()
	        " auto colorscheme * call rainbow_main#load()
	        " auto VimEnter * call rainbow_main#load()
	      ]]
      vim.api.nvim_set_hl(0, "@punctuation.bracket", { link = "" })
    end,
  },

  {
    -- "HampusHauffman/bionic.nvim",
    "kamilcuk/bionic.nvim",
    -- This plugin causes HIGH slow down when passing code from clipboard, disabling it solves the problem.
    enabled = false,
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

  "christoomey/vim-tmux-navigator", -- <ctrl-h> <ctrl-j> move between vim panes and tmux splits seamlessly
  "kshenoy/vim-signature", -- Show marks on the left and additiona m* motions

  -- { import = "astrocommunity.markdown-and-latex.markdown-preview-nvim" },
  -- {
  --   "markdown-preview.nvim",
  --   init = function() vim.g.mkdp_auto_close = 0 end,
  -- },
  {
    -- Install markdown preview, use npx if available.
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function(plugin)
      if vim.fn.executable "npx" then
        vim.cmd("!cd " .. plugin.dir .. " && cd app && npx --yes yarn install")
      else
        vim.cmd [[Lazy load markdown-preview.nvim]]
        vim.fn["mkdp#util#install"]()
      end
    end,
    init = function()
      if vim.fn.executable "npx" then vim.g.mkdp_filetypes = { "markdown" } end
    end,
  },

  {
    -- I wish something better would exists...
    "mkirc/vim-boxdraw",
    enabled = false, -- I use is so rarely... no reason to keep it
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
  -- {{{1 Filetypes

  "pranavpudasaini/vim-hcl",
  "NoahTheDuke/vim-just", -- syntax for justfile
  "grafana/vim-alloy", -- Grafana Alloy language support for vim

  -- }}}
  -- {{{1 lsp

  -- { import = "astrocommunity.completion.cmp-git" },
  -- { import = "astrocommunity.completion.cmp-emoji" },
  -- { import = "astrocommunity.completion.cmp-nvim-lua" },
  { import = "astrocommunity.completion.cmp-under-comparator" }, -- sort completion better for python
  { import = "astrocommunity.completion.cmp-calc" }, -- complete 1 + 1
  { import = "astrocommunity.completion.cmp-spell" },

  { import = "astrocommunity.lsp.garbage-day-nvim" },
  -- { import = "astrocommunity.lsp.inc-rename-nvim" }, -- replaced by lspsaga rename
  -- { import = "astrocommunity.lsp.lsp-lens-nvim" },
  { import = "astrocommunity.lsp.lsp-signature-nvim" },
  -- { import = "astrocommunity.diagnostics.lsp_lines-nvim" },
  { import = "astrocommunity.lsp.nvim-lsp-file-operations" },
  { import = "astrocommunity.lsp.nvim-lint" },
  { import = "astrocommunity.lsp.lspsaga-nvim" },

  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "andersevenrud/cmp-tmux", lazy = true },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "tmux", options = { all_panes = true } })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "quangnguyen30192/cmp-nvim-tags", lazy = true },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, { name = "tags" })
    end,
  },

  -- }}}
  -- {{{1 utils utilities programs that do something

  -- { import = "astrocommunity.search.sad-nvim" }, -- never used
  -- { import = "astrocommunity.diagnostics.trouble-nvim" }, -- lists of places with diagnostics. space+X . Never used it.

  -- { "salcode/vim-interactive-rebase-reverse", ft = { "gitrebase", "git" } }, -- reverse order commits during a Git rebase

  {
    "tpope/vim-dispatch", -- <leader>`
    dependencies = {
      "astrocore",
      opts = {
        mappings = {
          n = {
            ["<leader>r"] = { group = "Run vim-dispatch" },
            --
            ["<leader>rm"] = { group = "Make" },
            ["<leader>rm<CR>"] = { [[:.Make<CR>]] },
            ["<leader>rm<Space>"] = { [[:.Make<Space>]] },
            ["<leader>rm!"] = { [[:.Make!]] },
            ["<leader>rm?"] = {
              [[:<C-U>echo ":Dispatch" dispatch#make_focus(v:count > 1 ? 0 : v:count ? line(".") : -1)<CR>]],
              silent = true,
            },
            --
            ["<leader>rd"] = { group = "Dispatch" },
            ["<leader>rd<CR>"] = { [[:.Dispatch<CR>]] },
            ["<leader>rd<Space>"] = { [[:.Dispatch<Space>]] },
            ["<leader>rd!"] = { [[:.Dispatch!]] },
            ["<leader>rd?"] = { [[:.FocusDispatch<CR>]] },
            --
            ["<leader>rs"] = { group = "Start" },
            ["<leader>rs<CR>"] = { [[:.Start<CR>]] },
            ["<leader>rs<Space>"] = { [[:.Start<Space>]] },
            ["<leader>rs!"] = { [[:.Start!]] },
            ["<leader>rs?"] = {
              [[:<C-U>echo ":Start" dispatch#start_focus(v:count > 1 ? 0 : v:count ? line(".") : -1)<CR>]],
              silent = true,
            },
            --
            ["<leader>rS"] = { group = "Spawn" },
            ["<leader>rS<CR>"] = { [[:.Spawn<CR>]] },
            ["<leader>rS<Space>"] = { [[:.Spawn<Space>]] },
            ["<leader>rS!"] = { [[:.Spawn!]] },
            ["<leader>rS?"] = {
              [[:<C-U>echo ":Spawn" dispatch#spawn_focus(v:count > 1 ? 0 : v:count ? line(".") : -1)<CR>]],
              silent = true,
            },
          },
        },
      },
    },
  },

  { import = "astrocommunity.syntax.vim-sandwich" }, -- like vim-surround
  {
    "tpope/vim-surround", --  quoting/parenthesizing made simple cs\"' cst\" ds\" ysiw] cs]} ysiw<em>
    enabled = false, -- using vim-sandwich distributed as part of astronvim
    config = function()
      local ok, wk = pcall(require, "which-key")
      if not ok then return end
      wk.add {
        mode = "n",
        { [[cs"']], desc = [[Change " to ']] },
        { [[cs'<q>]], desc = [[Change ' to <q>]] },
        { [[cst"]], desc = [[Change XML tag to "]] },
        { [[ds"]], desc = [[Remove "]] },
        { "ysiw]", desc = "Embed word in []" },
        { [[ysw"]], desc = [[Quote word with "]] },
        { [[ysw']], desc = [[Quote word with ']] },
        { [[ysw`]], desc = [[Quote word with `]] },
        { [[ysW"]], desc = [[Quote WORD with "]] },
        { [[ysW']], desc = [[Quote WORD with ']] },
        { [[ysW`]], desc = [[Quote WORD with `]] },
        { [[ysiw"]], desc = [[Quote inside word with "]] },
        { [[ysiw']], desc = [[Quote inside word with ']] },
        { [[ysiw`]], desc = [[Quote inside word with `]] },
        { [[ysiW"]], desc = [[Quote inside WORD with "]] },
        { [[ysiW']], desc = [[Quote inside WORD with ']] },
        { [[ysiW`]], desc = [[Quote inside WORD with `]] },
      }
    end,
  },

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
          let output = system("env LC_ALL=C LANG=C hunspell -D")
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

  {
    "thaerkh/vim-workspace",
    priority = 10000,
    lazy = false,
    specs = {
      { "resession.nvim", enabled = false },
      {
        "AstroNvim/astrocore",
        ---@param opts AstroCoreOpts
        opts = function(_, opts)
          local sessionoptions = {} -- https://github.com/thaerkh/vim-workspace/issues/11
          for _, value in ipairs(vim.tbl_get(opts, "options", "opt", "sessionoptions") or vim.opt.sessionoptions:get()) do
            if value ~= "blank" then table.insert(sessionoptions, value) end
          end
          return require("astrocore").extend_tbl(opts, {
            autocmds = {
              autoclose_neotree = {
                {
                  event = "VimLeave",
                  callback = function()
                    if vim.fn.exists ":Neotree" == 2 then vim.cmd.Neotree "close" end
                    if vim.fn.exists ":NERDTreeClose" == 2 then vim.cmd.NERDTreeClose() end
                  end,
                },
              },
            },
            options = {
              opt = { sessionoptions = sessionoptions },
              g = {
                workspace_autosave_ignore = { "gitcommit", "neo-tree", "nerdtree", "qf", "tagbar" },
                workspace_session_disable_on_args = 1,
                workspace_session_directory = vim.fn.stdpath "cache" .. "/vim-workspace.sessions",
                workspace_undodir = vim.fn.stdpath "cache" .. "/vim-workspace.undodir",
                workspace_autocreate = 1,
                workspace_create_new_tabs = 0,
                -- Because a bug, these two populate search / history, just disable them.
                workspace_autosave_untrailtabs = 0,
                workspace_autosave_untrailspaces = 0,
                workspace_nocompatible = 0,
              },
            },
          })
        end,
      },
    },
  },
  -- { "resession.nvim", enabled = false },
  -- {
  --   "thaerkh/vim-workspace",
  --   enabled = true,
  --   priority = 0,
  --   lazy = false,
  --   init = function()
  --     vim.cmd [[
  --     let g:workspace_autosave_ignore = ['gitcommit', "neo-tree", "nerdtree", "qf", "tagbar"]
  --     let g:workspace_session_disable_on_args = 1
  --     let g:workspace_session_directory = stdpath("cache") . '/vim-workspace.sessions'
  --     let g:workspace_undodir= stdpath("cache") . "/vim-workspace.undodir"
  --     let g:workspace_autocreate = 1
  --     " nnoremap <leader>W :ToggleWorkspace<CR>
  --     autocmd VimLeave *
  --         \ if exists(":Neotree") | execute 'Neotree close' | endif |
  --         \ if exists(":NERDTreeClose") | execute 'NERDTreeClose' | endif
  --    let g:workspace_create_new_tabs = 0
  --    let g:workspace_persist_undo_history = 1  " enabled = 1 (default), disabled = 0
  --    " Because a bug, these two populate search / history, just disable them.
  --    let g:workspace_autosave_untrailtabs = 0
  --    let g:workspace_autosave_untrailspaces = 0
  --    let g:workspace_nocompatible = 0
  --    let g:workspace_session_disable_on_args = 1
  --    " https://github.com/thaerkh/vim-workspace/issues/11
  --    set sessionoptions-=blank
  --     ]]
  --   end,
  -- },

  -- }}}
  -- {{{1 colorscheme

  -- "cryptomilk/nightcity.nvim",
  {
    "dasupradyumna/midnight.nvim",
    -- enabled = false,
    lazy = false,
    priority = 10000,
    config = function() vim.cmd.colorscheme "midnight" end,
  },

  -- }}}
  -- {{{1 AI AI AI

  -- { import = "astrocommunity.editing-support.chatgpt-nvim" },

  -- { import = "astrocommunity.completion.copilot-lua-cmp" }, -- github copilot.vim so much better

  {
    "github/copilot.vim",
    enabled = false,
    init = function()
      -- copilot accept on ctrl+e
      vim.keymap.set("i", "<C-e>", 'copilot#Accept("\\<CR>")', {
        silent = true,
        expr = true,
        replace_keycodes = false,
      })
      vim.g.copilot_no_tab_map = true
    end,
  },

  {
    "yetone/avante.nvim",
    enabled = KcEnableAtHome(),
    enabled = false,
    event = "VeryLazy",
    lazy = false,
    version = "*", -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
      provider = "copilot",
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
      -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      -- "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
      -- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        enabled = false,
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },

  -- { import = "astrocommunity.completion.codeium-vim" },
  -- {
  --   "Exafunction/codeium.vim",
  --   cmd = {
  --     "Codeium",
  --     "CodeiumEnable",
  --     "CodeiumDisable",
  --     "CodeiumToggle",
  --     "CodeiumAuto",
  --     "CodeiumManual",
  --   },
  --   event = "BufEnter",
  --   dependencies = {
  --     "AstroNvim/astrocore",
  --     ---@type AstroCoreOpts
  --     opts = {
  --       mappings = {
  --         n = {
  --           ["<Leader>;"] = {
  --             "<Cmd>CodeiumToggle<CR>",
  --             noremap = true,
  --             desc = "Toggle Codeium active",
  --           },
  --         },
  --         i = {
  --           ["<C-g>"] = {
  --             function() return vim.fn["codeium#Accept"]() end,
  --             expr = true,
  --           },
  --           ["<C-;>"] = {
  --             function() return vim.fn["codeium#CycleCompletions"](1) end,
  --             expr = true,
  --           },
  --           ["<C-,>"] = {
  --             function() return vim.fn["codeium#CycleCompletions"](-1) end,
  --             expr = true,
  --           },
  --           ["<C-x>"] = {
  --             function() return vim.fn["codeium#Clear"]() end,
  --             expr = true,
  --           },
  --         },
  --       },
  --     },
  --   },
  -- },

  -- }}}
  -- {{{1 staging

  {
    "leath-dub/snipe.nvim",
    keys = {
      { "<leader>fB", function() require("snipe").open_buffer_menu() end, desc = "Open Snipe buffer menu" },
    },
    opts = {},
  },

  {
    -- Does not work with properly with undo
    -- Generate table of contents for markdown :GenToc*
    "mzlogin/vim-markdown-toc",
    ft = { "markdown" },
    enabled = true,
    cmd = { "GenTocGFM", "GenTocRedcarpet", "GenTocGitLab", "GenTocMarked", "UpdateToc", "RemoveToc" },
    init = function()
      local tmp = { "GenTocGFM", "GenTocRedcarpet", "GenTocGitLab", "GenTocMarked", "UpdateToc", "RemoveToc" }
      for _, i in ipairs(tmp) do
        vim.api.nvim_create_user_command("Markdown" .. i, i .. " <args>", {})
      end
      vim.g.vmt_auto_update_on_save = 0
    end,
  },
  {
    -- useless for me
    "preservim/vim-markdown",
    enabled = false,
    ft = "markdown",
  },
  {
    -- Does not work with properly with undo
    "hedyhli/markdown-toc.nvim",
    enabled = false,
    ft = "markdown", -- Lazy load on markdown filetype
    cmd = { "Mtoc", "MarkdownTableOfContent" }, -- Or, lazy load on "Mtoc" command
    opts = {
      -- Your configuration here (optional)
      auto_update = false,
    },
    init = function() vim.api.nvim_create_user_command("MarkdownTableOfContent", "Mtoc <args>", { nargs = 1 }) end,
  },

  { "Robitx/gp.nvim", enabled = false, config = true }, -- Talk with AI with neovim

  {
    -- it doesn't exactly work correctly, and is too noisy
    "inkarkat/vim-EnhancedJumps",
    enabled = false,
    lazy = false,
    dependencies = {
      "inkarkat/vim-ingo-library",
      lazy = false,
    },
  },

  {
    "jedrzejboczar/exrc.nvim",
    dependencies = { "neovim/nvim-lspconfig" }, -- (optional)
    config = true,
  },

  "tpope/vim-fugitive", -- git plugin

  {
    "MagicDuck/grug-far.nvim", -- find adn replace plugin
    opts = {},
  },

  {
    "astrocore",
    opts = function(_, opts)
      -- https://stackoverflow.com/a/63883912/9072753
      local maps = opts.mappings
      maps.n["<leader>bw"] = { group = "bwipeout" }
      maps.n["<leader>bwN"] = {
        "for buf in getbufinfo() | if strlen(buf.name) == 0 | silent execute 'bwipeout!' buf.bufnr | endif | end",
        desc = "Wipeout unnamed buffers",
      }
      maps.n["<leader>bwU"] = {
        "for buf in getbufinfo() | if buf.changed == 0 | silent execute 'bwipeout!' buf.bufnr | endif | end",
        desc = "Wipeout unmodified buffers",
      }
      maps.n["<leader>bwB"] = {
        "for buf in getbufinfo() | if strlen(buf.name) == 0 && buf.changed == 0 | silent execute 'bwipeout!' buf.bufnr | endif | end",
        desc = "Wipeout unnamed and unmodified buffers",
      }
      maps.n["<leader>bwh"] = {
        "for buf in getbufinfo() | if buf.hidden != 0 | silent execute 'bwipeout!' buf.bufnr | endif | end",
        desc = "Wipeout hidden buffers",
      }
      maps.n["<leader>bwL"] = {
        "for buf in getbufinfo() | if buf.loaded == 0 | silent execute 'bwipeout!' buf.bufnr | endif | end",
        desc = "Wipeout unloaded buffers",
      }
    end,
  },

  {
    "nvim-treesitter",
    opts = function(_, opts)
      -- disable treesitter for big files
      opts.highlight = opts.hightlight or {}
      opts.highlight.disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        return false
        -- return ok and stats and stats.size > max_filesize
      end
    end,
  },

  "inkarkat/vim-AdvancedSorters",

  "marcussimonsen/let-it-snow.nvim",
  { "folke/drop.nvim", opts = { screensaver = false } },
  "eandrju/cellular-automaton.nvim",
  { "alanfortlink/animatedbg.nvim", opts = {} },

  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
  },

  { "somini/vim-textobj-fold", dependencies = "kana/vim-textobj-user" },

  {
    "Davidyz/inlayhint-filler.nvim",
    enabled = false,
    keys = {
      {
        "<Leader>E", -- Use whatever keymap you want.
        function() require("inlayhint-filler").fill() end,
        desc = "Insert the inlay-hint under cursor into the buffer.",
        mode = { "n", "v" }, -- include 'v' if you want to use it in visual selection mode
      },
    },
  },

  "michaeljsmith/vim-indent-object", -- objects ai ii aI iI , use in python

  -- }}}
}
