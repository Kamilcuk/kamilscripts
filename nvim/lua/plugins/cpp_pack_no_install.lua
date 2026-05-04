-- DESCRIPTION: AstroNvim CPP Development Pack Configuration
--
-- PURPOSE: 
-- This file integrates the 'astrocommunity.pack.cpp' into the AstroNvim setup while 
-- explicitly disabling all automatic background installations typically managed by 
-- Mason and Treesitter.
--
-- USER GOALS:
-- 1. Manual Environment Control: The user prefers to manage their own toolchain 
--    (clangd, codelldb, compilers) via system package managers or manual builds 
--    rather than letting Neovim manage binaries in the background.
-- 2. Minimalist Footprint: Prevent Neovim from downloading and storing redundant 
--    binaries in the local data directory (~/.local/share/nvim/mason).
-- 3. Feature Preservation: Retain high-level C++ features such as the 
--    <Leader>lw mapping (Switch Source/Header) and clangd_extensions.nvim 
--    functionality without the automated overhead.

return {
  -- Import the community CPP pack
  { import = "astrocommunity.pack.cpp" },

  -- Block Treesitter auto-install
  {
    "AstroNvim/astrocore",
    optional = true,
    opts = { treesitter = { ensure_installed = {} } },
  },

  -- Block Mason LSP auto-install
  {
    "mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts) opts.ensure_installed = {} end,
  },

  -- Block Mason DAP auto-install
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts) opts.ensure_installed = {} end,
  },

  -- Block Mason Tool auto-install
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts) opts.ensure_installed = {} end,
  },
}
