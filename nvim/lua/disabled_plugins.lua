
-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-local
---@type LazySpec
return {

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
    enabled = false,
    lazy = false,
    config = function()
      require("soundme"):setup {
        debug = true,
        theme = "oxygen",
      }
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

  -- makes vim sooooo slow
  -- "sheerun/vim-polyglot", -- Solid language pack for vim

  -- Games
  { "vim/killersheep", cmd = { "KillKillKill" }, enabled = false },
  { "ThePrimeagen/vim-be-good", cmd = { "VimBeGood" }, enabled = false },
  { "felleg/TeTrIs.vim", cmd = { "Tetris" }, enabled = false },

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

  {
    import = "astrocommunity.completion.tabby-nvim",
    enabled = false,
    cond = function() return vim.fn.filereadable(vim.fn.expand "~/.tabby-client/agent/config.toml") ~= 0 end,
  },

  {
    -- make nvim-notify smaller. I would make it even smaller smaller
    "nvim-notify",
    enabled = false, -- astronvim v5 no nvim-notify
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

  -- { import = "astrocommunity.recipes.astrolsp-no-insert-inlay-hints" }, -- disable insert hits in insert mode only. I disable inlay hits everywhere.


  {
    -- previous neovim v4 config, moving to blink-cmp.nvim
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
    -- { import = "astrocommunity.completion.cmp-git" },
    -- { import = "astrocommunity.completion.cmp-emoji" },
    -- { import = "astrocommunity.completion.cmp-nvim-lua" },
    -- { import = "astrocommunity.completion.cmp-under-comparator" }, -- sort completion better for python
    -- { import = "astrocommunity.completion.cmp-calc" }, -- complete 1 + 1
    -- { import = "astrocommunity.completion.cmp-spell" },
  },


  -- I do not want to "talk". I want to edit.
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
    -- scresavers, while fun, they just slow down the neovim. Remove them.
    "marcussimonsen/let-it-snow.nvim",
    { "folke/drop.nvim", opts = { screensaver = false } },
    "eandrju/cellular-automaton.nvim",
    { "alanfortlink/animatedbg.nvim", opts = {} },
  },


  -- never used it
  { "somini/vim-textobj-fold", dependencies = "kana/vim-textobj-user" }, -- select current fold with  vaz

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
  }, -- Ascii box drawing.


  {
    -- just moved to astrocommunity
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

  {
    -- rainbow-delimiters-nvim is just better, usiung from astrocommunity
    "luochen1990/rainbow",
    enabled = false,
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
}
