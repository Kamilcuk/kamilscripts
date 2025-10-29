-- plugins_home.lua
-- These plugins are loaded only on my home computer

return {
  -- {{{1 AI AI AI

  -- { import = "astrocommunity.editing-support.chatgpt-nvim" },

  -- { import = "astrocommunity.completion.copilot-lua-cmp" }, -- github copilot.vim so much better

  -- {
  --   "github/copilot.vim",
  --   init = function()
  --     -- copilot accept on ctrl+e
  --     vim.keymap.set("i", "<C-e>", 'copilot#Accept("\\<CR>")', {
  --       silent = true,
  --       expr = true,
  --       replace_keycodes = false,
  --     })
  --     vim.g.copilot_no_tab_map = true
  --   end,
  -- },

  { import = "astrocommunity.completion.avante-nvim" },
  {
    "avante.nvim",
    optional = true,
    enabled = not not vim.env.TOGETHER_API_KEY,
    opts = {
      -- provider = "claude",
      -- behavior = { enable_claude_text_editor_tool_mode = true },
      provider = "together",
      providers = {
        together = {
          __inherited_from = "openai",
          endpoint = "https://api.together.xyz/v1/",
          api_key_name = "TOGETHER_API_KEY",
          -- model = "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free",
          model = "meta-llama/Meta-Llama-3.1-8B-Instruct-Turbo",
        },
      },
    },
  },


  -- This is chat api
  { import = "astrocommunity/completion/minuet-ai-nvim" },
  {
    "minuet-ai.nvim",
    optional = true,
    enabled = not not vim.env.TOGETHER_API_KEY,
    opts = {
      provider = "openai_fim_compatible",
      n_completions = 1,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TOGETHER_API_KEY",
          name = "Ollama",
          end_point = "https://api.together.xyz/v1/completions",
          model = "Qwen/Qwen2.5-7B-Instruct-Turbo",
          -- model = "Qwen/Qwen2.5-Coder-32B-Instruct",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
        },
      },
      cmp = { enable_auto_complete = false },
      blink = { enable_auto_complete = false },
      virtualtext = {
        auto_trigger_ft = { "*" },
        keymap = {
          accept = "<C-e>",
        },
        show_on_completion_menu = true,
      },
      throttle = 3000,
      debounce = 3000,
    },
  },

  -- {
  --   "yetone/avante.nvim",
  --   enabled = KcEnableAtHome(),
  --   enabled = false,
  --   event = "VeryLazy",
  --   lazy = false,
  --   version = "*", -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
  --   opts = {
  --     provider = "copilot",
  --   },
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   build = "make",
  --   -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  --   dependencies = {
  --     "stevearc/dressing.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     --- The below dependencies are optional,
  --     -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
  --     -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
  --     -- "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
  --     -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
  --     -- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
  --     "zbirenbaum/copilot.lua", -- for providers='copilot'
  --     {
  --       -- support for image pasting
  --       "HakonHarnes/img-clip.nvim",
  --       event = "VeryLazy",
  --       opts = {
  --         -- recommended settings
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           -- required for Windows users
  --           use_absolute_path = true,
  --         },
  --       },
  --     },
  --     {
  --       -- Make sure to set this up properly if you have lazy=true
  --       "MeanderingProgrammer/render-markdown.nvim",
  --       enabled = false,
  --       opts = {
  --         file_types = { "markdown", "Avante" },
  --       },
  --       ft = { "markdown", "Avante" },
  --     },
  --   },
  -- },

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
}
