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
      sys.version.info.major == %d
      and sys.version.info.minor >= %d
      ]]).format(major, minor, import))
end

---Check if python version is higher than major:minor and has import.
---@param major number
---@param minor number
---@param import string
local function KcHasPythonVersionAndImport(major, minor, import)
  return KcPythonBool(([[
      sys.version.info.major == %d
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
  return vim.env.USER ~= "cukrowsk"
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
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = { -- extend the plugin options
      diagnostics = {
        virtual_text = false, -- disable diagnostics virtual text
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

  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        layout = { -- the layout config
          layout = { -- the layout itself
            fullscreen = true,
            width = 0, -- 0 is max
            height = 0,
          },
        },
      },
      dashboard = { enabled = false },
      scroll = { enabled = false },
    },
  }, -- disable entry dashboard by astronvim

  { import = "astrocommunity.editing-support.bigfile-nvim" }, -- LunarVim/bigfile.nvim Make editing big files faster 🚀
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      treesitter = {
        highlight = {
          disable = function(lang, buf)
            local max_filesize = 300 * 1024 -- 300 KB
            local max_lines = 5000
            if vim.api.nvim_buf_line_count(buf) > max_lines then return true end
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            return ok and stats and stats.size > max_filesize
          end,
        },
      },
    },
  },

  { "alpha-nvim", enabled = false }, -- disable entry screen, I do not use it anyway
  { "aerial.nvim", enabled = false }, -- A code outline window for skimming and quick navigation
  { "mason-lspconfig.nvim", opts = { automatic_installation = false } },
  { "mason-nvim-dap.nvim", opts = { automatic_installation = false } },
  { "nvim-autopairs", enabled = false }, -- och god no, no autopairs
  { "lazygit.nvim", enabled = false }, -- I have no idea how to use it, I like the tpope plugin
  { "nvim-ts-autotag", enabled = false }, -- no autoclosin
  { "todo-comments.nvim", enabled = false }, -- todo comments are not important

  {
    "folke/snacks.nvim",
    opts = {
      notifier = {
        --- @type fun(notif: snacks.notifier.Notif): boolean
        filter = function(notif) return not notif.msg:find "vim.tbl_islist is deprecated" end,
      },
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
    optional = true,
    opts = function(_, opts)
      local status = require "astroui.status"
      local function my_tabline_file_info()
        local tmp = status.component.tabline_file_info()
        table.insert(tmp, 2, {
          provider = function(self) return self and self.bufnr and self.bufnr or "" end,
          hl = { bold = true, underline = true, fg = "cyan" },
        })
        return tmp
      end
      opts.tabline[2] = status.heirline.make_buflist(my_tabline_file_info())
    end,
  },

  {
    -- Add find jumps and jumpsfiles shortcuts.
    "astrocore",
    optional = true,
    opts = function(_, opts)
      local maps = opts.mappings
      -- astronvim v5 no telescope.nvim
      --     maps.n["<Leader>fj"] = { function() require("telescope.builtin").jumplist() end, desc = "Find jumps" }
      --     maps.n["<Leader>fq"] = { function() require("k.telescope-add").jumpfilelist() end, desc = "Find jump files" }
      maps.n["<Leader>fj"] = { function() return require("snacks.picker").jumps() end, desc = "Find jumps" }
      maps.n["<Leader>fq"] = {
        function() return require("k.snack_jumpfiles").picker_jumpfiles() end,
        desc = "Find jump files",
      }
    end,
  },

  {
    -- Forces specific paths to be visible while hiding others in Neo-tree.
    "neo-tree.nvim",
    optional = true,
    opts = function(_, opts)
      opts.filesystem = vim.tbl_deep_extend("keep", opts.filesystem or {}, {
        filtered_items = {
          always_show = {},
          always_show_by_pattern = {},
          never_show = {},
          never_show_by_pattern = {},
          hide_dotfiles = false,
        },
      })
      vim.list_extend(
        opts.filesystem.filtered_items.always_show,
        KcSplit [[
          .gitignore .github .gitlab .gitlab-runner-local .gitlab-ci.yml 
          local.lua .clangd .clang-format .editorconfig Makefile Justfile 
          .env .env.example .nvimrc .exrc .prettierignore .nvmrc 
          .dockerignore Dockerfile docker-compose.yml 
          package.json package-lock.json yarn.lock pnpm-lock.yaml 
          Cargo.toml Cargo.lock go.mod go.sum 
          CMakeLists.txt CMakePresets.json .python-version
        ]]
      )
      vim.list_extend(
        opts.filesystem.filtered_items.never_show,
        KcSplit [[
          __pycache__ .ruff_cache .tox .cache .nox .eggs 
          .pytest_cache .mypy_cache .ipynb_checkpoints 
          .DS_Store Thumbs.db .git
        ]]
      )
      vim.list_extend(opts.filesystem.filtered_items.never_show_by_pattern, KcSplit "*.egg-info *.egg *.pyc *.pyo")
    end,
  },

  -- }}}
  -- {{{1 :commmands plugins that add various :commands to be executed

  {
    "tpope/vim-eunuch", -- Commands like :Remove :Delete :Move :SudoWrite
    lazy = false, -- Load always. It makes files with shebang executables automatically.
  },
  { "godlygeek/tabular", lazy = false }, -- :Tabularize Vim script for text filtering and alignment
  "tpope/vim-fugitive", -- git plugin

  -- }}}
  -- {{{1 UI Display displaying highlight showing gui related tools

  { import = "astrocommunity.syntax.vim-cool" }, -- disable search highlight after done searching
  { "ntpeters/vim-better-whitespace", lazy = false }, -- Mark whitespaces :StripWhitespace
  {
    -- Fix vim-better-whitespace not disabling itself for snacks_dashboard
    "ntpeters/vim-better-whitespace",
    lazy = false,
    dependencies = {
      "AstroNvim/astrocore",
      opts = {
        autocmds = {
          vim_better_whitespace = {
            {
              event = "User",
              pattern = "SnacksDashboardOpened",
              desc = "Fix vim-better-whitespace not disabling itself for snacks_dashboard",
              callback = function() vim.cmd [[DisableWhitespace]] end,
            },
          },
        },
      },
    },
  },

  { import = "astrocommunity.editing-support.rainbow-delimiters-nvim" },

  { "nvim-treesitter/nvim-treesitter-context", opts = { max_lines = 3 } },

  "kshenoy/vim-signature", -- Show marks on the left and additiona m* motions

  -- }}}
  -- {{{1 Filetypes additional support for syntax of specific file extensions and languages.

  "pranavpudasaini/vim-hcl",
  "NoahTheDuke/vim-just", -- syntax for justfile
  "grafana/vim-alloy", -- Grafana Alloy language support for vim
  -- { import = "astrocommunity.lsp.nvim-java" }, -- enable for java

  -- }}}
  -- {{{1 LSP Configuration related to autocompletion.

  -- Disable UP and Down completion.
  {
    "blink.cmp",
    optional = true,
    opts = function(_, opts)
      -- https://github.com/AstroNvim/AstroNvim/blob/91af3dc567ebf1a62916021f8094d5ffad848c7c/lua/astronvim/plugins/blink.lua#L92
      opts.keymap = opts.keymap or {}
      opts.keymap["<Up>"] = nil
      opts.keymap["<Down>"] = nil
    end,
  },

  { import = "astrocommunity.completion.blink-cmp-tmux" },
  -- Use tmux from all panels. Tmux should be last.
  {
    "blink.cmp",
    optional = true,
    opts = {
      sources = {
        -- https://github.com/saghen/blink.cmp/blob/main/lua/blink/cmp/config/sources.lua#L54
        providers = {
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            fallbacks = { "buffer" },
          },
          path = {
            module = "blink.cmp.sources.path",
            score_offset = 3,
            fallbacks = { "buffer" },
          },
          snippets = {
            module = "blink.cmp.sources.snippets",
            score_offset = -1, -- receives a -3 from top level snippets.score_offset
          },
          buffer = {
            module = "blink.cmp.sources.buffer",
            score_offset = -3,
          },
          cmdline = {
            module = "blink.cmp.sources.cmdline",
          },
          omni = {
            module = "blink.cmp.sources.complete_func",
            enabled = function() return vim.bo.omnifunc ~= "v:lua.vim.lsp.omnifunc" end,
            ---@type blink.cmp.CompleteFuncOpts
            opts = {
              complete_func = function() return vim.bo.omnifunc end,
            },
          },
          -- tmux = { score_offset = -10, opts = { all_panes = true } },
        },
      },
    },
  },

  { "blink.cmp", optional = true, opts = { completion = { menu = { auto_show_delay_ms = 1000 } } } },

  {
    "blink.cmp",
    optional = true,
    opts = {
      completion = {
        menu = {
          draw = {
            -- When presetting completions, show where they are coming from.
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" }, { "source_name" } },
          },
        },
      },
    },
  },

  -- https://docs.astronvim.com/recipes/advanced_lsp/#automatic-signature-help
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      features = {
        signature_help = true, -- enable automatic signature help popup globally on startup
      },
    },
  },

  -- { import = "astrocommunity.completion.blink-cmp-git" },

  -- {
  --   "ribru17/blink-cmp-spell",
  --   lazy = true,
  --   specs = {
  --     {
  --       "saghen/blink.cmp",
  --       optional = true,
  --       opts = {
  --         sources = {
  --           default = { "spell" },
  --           providers = {
  --             spell = {
  --               name = "Spell",
  --               module = "blink-cmp-spell",
  --               opts = {
  --                 -- EXAMPLE: Only enable source in `@spell` captures, and disable it
  --                 -- in `@nospell` captures.
  --                 enable_in_context = function()
  --                   local curpos = vim.api.nvim_win_get_cursor(0)
  --                   local captures = vim.treesitter.get_captures_at_pos(0, curpos[1] - 1, curpos[2] - 1)
  --                   local in_spell_capture = false
  --                   for _, cap in ipairs(captures) do
  --                     if cap.capture == "spell" then
  --                       in_spell_capture = true
  --                     elseif cap.capture == "nospell" then
  --                       return false
  --                     end
  --                   end
  --                   return in_spell_capture
  --                 end,
  --                 use_cmp_spell_sorting = true,
  --               },
  --             },
  --           },
  --         },
  --       },
  --     },
  --     -- {
  --     --   "saghen/blink.cmp",
  --     --   optional = true,
  --     --   opts = function(_, opts)
  --     --     opts.fuzzy = opts.fuzzy or {}
  --     --     -- default from https://github.com/saghen/blink.cmp/blob/main/lua/blink/cmp/config/fuzzy.lua#L39
  --     --     opts.fuzzy.sorts = opts.fuzzy.sorts or { "score", "sort_text" }
  --     --     table.insert(
  --     --       opts.fuzzy.sorts,
  --     --       1,
  --     --       -- It is recommended to put the "label" sorter as the primary sorter for the
  --     --       -- spell source.
  --     --       -- If you set use_cmp_spell_sorting to true, you may want to skip this step.
  --     --       function(a, b)
  --     --         if a.source_id == "spell" and b.source_id == "spell" then
  --     --           return require("blink.cmp.fuzzy.sort").label(a, b)
  --     --         end
  --     --       end
  --     --       -- Preserve normal default order, which we fall back to
  --     --     )
  --     --   end,
  --     -- },
  --   },
  -- },

  { import = "astrocommunity.lsp.garbage-day-nvim" },
  -- { import = "astrocommunity.lsp.inc-rename-nvim" }, -- replaced by lspsaga rename
  -- { import = "astrocommunity.lsp.lsp-lens-nvim" },
  -- { import = "astrocommunity.diagnostics.lsp_lines-nvim" },
  { import = "astrocommunity.lsp.nvim-lsp-file-operations" },
  { import = "astrocommunity.lsp.nvim-lint" },

  -- {
  --   "alllsp",
  --   dir = vim.fn.expand "~/.kamilscripts/nvim/lua/alllsp",
  --   opts = { ignore = { black = true } },
  -- },
  -- {
  --   "AstroNvim/astrolsp",
  --   opts = function(_, opts)
  --     opts.servers = require("astrocore").list_insert_unique(opts.servers, require("alllsp").for_lspconfig())
  --   end,
  -- },
  -- {
  --   "nvimtools/none-ls.nvim",
  --   opts = function(_, opts)
  --     opts.sources = require("astrocore").list_insert_unique(opts.servers, require("alllsp").for_none_ls())
  --   end,
  -- },

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
      if vim.fn.executable "hunspell" == 1 or vim.fn.executable "aspell" == 1 then
        return true
      else
        KcLog "DetectSpellLang disabled: no hunspell and no aspell"
        return false
      end
    end,
  },

  { "tpope/vim-scriptease", lazy = false }, -- :Verbose :Messages zS - show syntax hihlight under cursor, g= - eval vimscript inline

  { "christoomey/vim-tmux-navigator", lazy = false }, -- <ctrl-h> <ctrl-j> move between vim panes and tmux splits seamlessly

  {
    import = "astrocommunity.markdown-and-latex.markdown-preview-nvim",
    enabled = function() return vim.fn.executable "yarn" == 1 or vim.fn.executable "npx" == 1 end,
  },

  -- { import = "astrocommunity.session.vim-workspace" },
  -- https://docs.astronvim.com/recipes/sessions/#automatically-restore-previous-session
  { import = "astrocommunity.recipes.auto-session-restore" },

  -- }}}
  -- {{{1 colorscheme

  {
    "astroui",
    optional = true,
    opts = {
      -- colorscheme = "astrodark",
      -- colorscheme = "midnight",
      colorscheme = "onedark_dark",
      -- colorscheme = "onedark",
    },
  },
  { import = "astrocommunity.colorscheme.onedarkpro-nvim" },
  -- { import = "astrocommunity.colorscheme.catppuccin" },
  -- "cryptomilk/nightcity.nvim",
  -- { "dasupradyumna/midnight.nvim", lazy = false, priority = 10000 },

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
    -- :Exrc* and other utilities
    "jedrzejboczar/exrc.nvim",
    dependencies = { "neovim/nvim-lspconfig", optional = true }, -- (optional)
    config = true,
  },

  -- find and replace plugin
  { import = "astrocommunity.search.grug-far-nvim" },
  {
    "MagicDuck/grug-far.nvim",
    -- only enable for neovim 0.10 and above
    enabled = vim.fn.has "nvim-0.10" == 1,
    -- pin to version 1.6.3 specifically for neovim 0.10; unpinned for 0.11+
    version = (vim.fn.has "nvim-0.10" == 1 and vim.fn.has "nvim-0.11" == 0) and "1.6.3" or nil,
    opts = {
      -- open in a new tab for a "fullscreen" experience
      windowCreationCommand = "tab split",
    },
    dependencies = {
      {
        "astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          -- shortcut to open grug-far
          maps.n["<leader>,R"] = { "<cmd>GrugFar<cr>", desc = "GrugFar" }

          -- disable completion in grug-far buffers to avoid UI interference
          if not opts.autocmds then opts.autocmds = {} end
          opts.autocmds.grug_far_completion_disable = {
            {
              event = "FileType",
              pattern = "grug-far",
              callback = function()
                -- disable blink.cmp
                vim.b.blink_cmp_enabled = false
                -- also disable nvim-cmp as a fallback
                local ok, cmp = pcall(require, "cmp")
                if ok then cmp.setup.buffer { enabled = false } end
              end,
            },
          }
        end,
      },
    },
  },

  {
    "astrocore",
    optional = true,
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
    "inkarkat/vim-AdvancedSorters",
    dependencies = { "inkarkat/vim-ingo-library" },
  }, -- :Sort* :Recorder* :Uniq* Sorting of certain areas or by special needs.
  "michaeljsmith/vim-indent-object", -- objects ai ii aI iI , use in python

  {
    -- "nvzone/menu",
    "kamilcuk/menu",
    dir = (function()
      local dir = vim.fn.fnamemodify("~/myprojects/menu", ":p")
      return vim.fn.isdirectory(dir) ~= 0 and dir or nil
    end)(),
    opts = {
      border = true,
      nested_col = 0,
    },
    dependencies = {
      { "nvzone/volt" },
      {
        "astrocore",
        opts = function(_, opts)
          local handler = require("menu").handler
          local maps = opts.mappings
          maps.n["<leader>m"] = { function() handler { mouse = false } end, desc = "Open menu" }
          maps.n["<RightMouse>"] = { function() handler { mouse = true } end }
          maps.v["<RightMouse>"] = maps.n["<RightMouse>"]
        end,
      },
    },
  },

  -- }}}
}
