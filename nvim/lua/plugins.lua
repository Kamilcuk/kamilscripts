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
  local timer = vim.uv.new_timer()
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

---@param txt string
---@return string[]
local function KcSplit(txt)
  local r = {}
  for w in txt:gmatch "%S+" do
    table.insert(r, w)
  end
  return r
end

-- }}}

---@type LazySpec
return {
  -- {{{1 astrocommunity astronvim modifications of configurations in astro customizations
  -- https://github.com/AstroNvim/AstroNvim
  -- https://docs.astronvim.com/configuration/v5_migration/
  -- https://astronvim.github.io/astrocommunity/
  -- https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity

  "AstroNvim/astrocommunity",
  { import = "astrocommunity.editing-support.auto-save-nvim" },

  {
    "astrocore",
    ---@type AstroCoreOpts
    opts = { -- extend the plugin options
      diagnostics = {
        virtual_text = false, -- disable diagnostics virtual text
      },
      autocmds = {
        alpha_autostart = false, -- disable entry screen, TODO: port to astronvim v5
      },
      features = {
        large_buf = {
          lines = 3000, -- = 10000, -- max number of lines (or false to disable check)
        },
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

  { import = "astrocommunity.editing-support.bigfile-nvim" }, -- LunarVim/bigfile.nvim Make editing big files faster 🚀
  {
    -- https://www.mikecoutermarsh.com/astrovim-slow-on-large-files/
    -- Disable to speed up on larger files.
    "vim-illuminate",
    event = "User AstroFile",
    opts = {
      large_file_cutoff = 3000,
    },
  },

  { "alpha-nvim", enabled = false }, -- disable entry screen, I do not use it anyway
  { "mason-lspconfig.nvim", opts = { automatic_installation = false } },
  { "mason-nvim-dap.nvim", opts = { automatic_installation = false } },
  { "nvim-autopairs", enabled = false }, -- och god no, no autopairs
  { "lazygit.nvim", enabled = false }, -- I have no idea how to use it, I like the tpope plugin
  { "nvim-ts-autotag", enabled = false }, -- no autoclosin
  { "todo-comments.nvim", enabled = false }, -- todo comments are not important

  {
    -- I hate terminal in the middle, how people work with that?
    "noice.nvim",
    opts = function(_, opts)
      opts.cmdline = opts.cmdline or {}
      opts.cmdline.view = "cmdline"
      opts.cmdline.format = {
        cmdline = false,
        search_down = false,
        search_up = false,
        filter = false,
        lua = false,
        help = false,
        input = false,
      }
      opts.presets = opts.presets or {}
      opts.presets.bottom_search = true
      return opts
    end,
  },

  {
    "snacks.nvim",
    ---@type snacks.Config
    opts = {
      ---@type table<string, snacks.win.Config>
      styles = {
        notification = {
          wo = {
            wrap = true,
          },
        },
      },
    },
  },

  {
    -- Add buffer number in front of buffer name in the tabline.
    "heirline.nvim",
    opts = function(_, opts)
      local status = require "astroui.status"
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
    "astrocore",
    opts = function(_, opts)
      local maps = opts.mappings
      -- astronvim v5 no telescope.nvim
      --     maps.n["<Leader>fj"] = { function() require("telescope.builtin").jumplist() end, desc = "Find jumps" }
      --     maps.n["<Leader>fq"] = { function() require("k.telescope-add").jumpfilelist() end, desc = "Find jump files" }
      maps.n["<Leader>fj"] = { function() return Snacks.picker.jumps() end, desc = "Find jumps" }
      maps.n["<Leader>fq"] = {
        function() return require("k.snack_jumpfiles").picker_jumpfiles() end,
        desc = "Find jump files",
      }
    end,
  },

  {
    "neo-tree.nvim",
    opts = function(_, opts)
      opts.filesystem = vim.tbl_deep_extend("keep", opts.filesystem or {}, {
        filtered_items = {
          always_show = {},
          always_show_by_pattern = {},
          newer_show = {},
          newer_show_by_pattern = {},
          hide_dotfiles = false,
        },
      })
      vim.list_extend(
        opts.filesystem.filtered_items.always_show,
        KcSplit ".gitignore .github .gitlab .gitlab-runner-local .gitlab-ci.yml local.lua"
      )
      vim.list_extend(
        opts.filesystem.filtered_items.newer_show,
        KcSplit "__pycache__ .ruff_cache .tox .cache .nox .eggs"
      )
      vim.list_extend(opts.filesystem.filtered_items.newer_show_by_pattern, KcSplit "*.egg-info *.egg")
    end,
  },

  -- }}}
  -- {{{1 :commmands plugins that add various :commands to be executed

  {
    "tpope/vim-eunuch", -- commands like :Remove :Delete :Move :SudoWrite
    lazy = false, -- Load always. It makes files with shebang executables automatically.
  },

  -- { import = "astrocommunity.fuzzy-finder.fzf-lua" }, -- using snacks.nvim

  -- { import = "astrocommunity.syntax.vim-easy-align" }, -- never used, like :Tabularize
  { "godlygeek/tabular", lazy = false }, -- :Tabularize Vim script for text filtering and alignment

  { import = "astrocommunity.editing-support.refactoring-nvim" }, -- :Refactor command

  "tpope/vim-fugitive", -- git plugin

  -- }}}
  -- {{{1 UI Display displaying highlight showing gui related tools

  { import = "astrocommunity.syntax.vim-cool" }, -- disable search highlight after done searching

  { "ntpeters/vim-better-whitespace", lazy = false }, -- Mark whitespaces :StripWhitespace

  { import = "astrocommunity.editing-support.rainbow-delimiters-nvim" },
  -- {
  --   "saghen/blink.pairs",
  --   version = "v0.2.0", -- (recommended) only required with prebuilt binaries
  --   -- download prebuilt binaries from github releases
  --   dependencies = { "saghen/blink.download" },
  --   -- dependencies = { "saghen/blink.download", enabled = not vim.fn.executable "cargo" },
  --   -- build = vim.fn.executable "cargo" and "cargo build --release" or nil,
  -- },

  "kshenoy/vim-signature", -- Show marks on the left and additiona m* motions

  -- }}}
  -- {{{1 Filetypes additional support for syntax of specific file extensions and languages.

  "pranavpudasaini/vim-hcl",
  "NoahTheDuke/vim-just", -- syntax for justfile
  "grafana/vim-alloy", -- Grafana Alloy language support for vim
  -- { import = "astrocommunity.lsp.nvim-java" }, -- enable for java

  -- }}}
  -- {{{1 LSP Configuration related to autocompletion.

  -- Delay blink.cmp completion by 1 second.
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      local delay_ms = 5000
      -- disable auto_show
      opts.completion = opts.completion or {}
      opts.completion.menu = opts.completion.menu or {}
      opts.completion.menu.auto_show = false
      -- setup timer
      local timer = vim.uv.new_timer()
      assert(timer)
      vim.api.nvim_create_autocmd({ "CursorMovedI", "TextChangedI" }, {
        callback = function()
          timer:stop()
          timer:start(delay_ms or 1000, 0, function()
            timer:stop()
            vim.schedule(function()
              -- Only run in insert mode.
              if vim.api.nvim_get_mode()["mode"] == "i" then require("blink.cmp").show() end
            end)
          end)
        end,
      })
    end,
  },

  {
    "saghen/blink.cmp",
    dependencies = { "mgalliou/blink-cmp-tmux" },
    opts = function(_, opts)
      opts.sources = vim.tbl_deep_extend("keep", opts.sources or {}, {
        default = {},
        providers = {
          tmux = {
            module = "blink-cmp-tmux",
            name = "tmux",
            -- default options
            opts = {
              all_panes = true,
              capture_history = false,
              -- only suggest completions from `tmux` if the `trigger_chars` are
              -- used
              triggered_only = false,
              trigger_chars = { "." },
            },
          },
        },
      })
      vim.list_extend(opts.sources.default, { "tmux" })
    end,
  },

  {
    "saghen/blink.cmp",
    dependencies = {
      "Kaiser-Yang/blink-cmp-git",
      dependencies = { "nvim-lua/plenary.nvim" },
    },
    opts = function(_, opts)
      opts.sources = vim.tbl_deep_extend("keep", opts.sources or {}, {
        default = {},
        providers = {
          git = {
            module = "blink-cmp-git",
            name = "Git",
            opts = {
              -- options for the blink-cmp-git
            },
          },
        },
      })
      vim.list_extend(opts.sources.default, { "git" })
    end,
  },

  {
    "saghen/blink.cmp",
    dependencies = { "ribru17/blink-cmp-spell" },
    opts = function(_, opts)
      opts.sources = vim.tbl_deep_extend("keep", opts.sources or {}, {
        default = {},
        providers = {
          spell = {
            name = "Spell",
            module = "blink-cmp-spell",
            opts = {
              -- EXAMPLE: Only enable source in `@spell` captures, and disable it
              -- in `@nospell` captures.
              enable_in_context = function()
                local curpos = vim.api.nvim_win_get_cursor(0)
                local captures = vim.treesitter.get_captures_at_pos(0, curpos[1] - 1, curpos[2] - 1)
                local in_spell_capture = false
                for _, cap in ipairs(captures) do
                  if cap.capture == "spell" then
                    in_spell_capture = true
                  elseif cap.capture == "nospell" then
                    return false
                  end
                end
                return in_spell_capture
              end,
            },
          },
        },
      })
      vim.list_extend(opts.sources.default, { "spell" })
      opts.fuzzy = opts.fuzzy or {}
      opts.fuzzy.sorts = opts.fuzzy.sorts or {}
      table.insert(
        opts.fuzzy.sorts,
        1,
        -- It is recommended to put the "label" sorter as the primary sorter for the
        -- spell source.
        -- If you set use_cmp_spell_sorting to true, you may want to skip this step.
        function(a, b)
          local sort = require "blink.cmp.fuzzy.sort"
          if a.source_id == "spell" and b.source_id == "spell" then return sort.label(a, b) end
        end
        -- Preserve normal default order, which we fall back to
      )
    end,
  },

  { import = "astrocommunity.lsp.garbage-day-nvim" },
  -- { import = "astrocommunity.lsp.inc-rename-nvim" }, -- replaced by lspsaga rename
  -- { import = "astrocommunity.lsp.lsp-lens-nvim" },
  { import = "astrocommunity.lsp.lsp-signature-nvim" },
  -- { import = "astrocommunity.diagnostics.lsp_lines-nvim" },
  { import = "astrocommunity.lsp.nvim-lsp-file-operations" },
  { import = "astrocommunity.lsp.nvim-lint" },
  { import = "astrocommunity.lsp.lspsaga-nvim" },

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

  { "tpope/vim-scriptease", lazy = false }, -- :Verbose :Messages zS - show syntax hihlight under cursor, g= - eval vimscript inline

  { "christoomey/vim-tmux-navigator", lazy = false }, -- <ctrl-h> <ctrl-j> move between vim panes and tmux splits seamlessly

  {
    import = "astrocommunity.markdown-and-latex.markdown-preview-nvim",
    enabled = function() return vim.fn.executable "yarn" or vim.fn.executable "npx" end,
  },

  { import = "astrocommunity.session.vim-workspace" },

  -- }}}
  -- {{{1 colorscheme

  {
    "astroui",
    opts = {
      -- colorscheme = "astrodark",
      -- colorscheme = "midnight",
      colorscheme = "onedark_dark",
      -- colorscheme = "onedark",
    },
  },
  -- { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.colorscheme.onedarkpro-nvim" },
  -- "cryptomilk/nightcity.nvim",
  -- { "dasupradyumna/midnight.nvim", lazy = false, priority = 10000 },

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
    "jedrzejboczar/exrc.nvim",
    dependencies = { "neovim/nvim-lspconfig", optional = true }, -- (optional)
    config = true,
  }, -- :Exrc* and other utilities

  {
    "MagicDuck/grug-far.nvim", -- find and replace plugin
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

  "inkarkat/vim-AdvancedSorters",

  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
  },

  "michaeljsmith/vim-indent-object", -- objects ai ii aI iI , use in python

  -- }}}
}
