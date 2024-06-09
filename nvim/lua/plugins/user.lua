-- user.lua

function KcPythonBool(script) return vim.fn.has "python3" and pcall(vim.fn.py3eval, script) end

function KcPythonHasVersionAndImport(major, minor, import)
  return KcPythonBool(([[
      sys.version.infor.major == %d
      and sys.version.info.minor >= %d
      and __import__("importlib.util").util.find_spec(%s) is not None
      ]]).format(major, minor, import))
end

function KcLog(what) end

---@type LazySpec
return {
  { "folke/noice.nvim", enabled = false },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      automatic_installation = true,
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      automatic_installation = true,
    },
  },
  {
    "windwp/nvim-autopairs",
    enabled = false,
  },
  {
    "tpope/vim-eunuch",
  },

  {
    "junegunn/fzf",
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
    setup = function()
      vim.cmd [[
          augroup BionicAutocmd
            autocmd!
            autocmd FileType * BionicOn
          augroup END
        ]]
    end,
  },

  "christoomey/vim-tmux-navigator", -- <ctrl-h> <ctrl-j> move bewteen vim panes and tmux splits seamlessly
  "kshenoy/vim-signature", -- Show marks on the left and additiona m* motions
  "NoahTheDuke/vim-just", -- syntax for justfile
  "sheerun/vim-polyglot", -- Solid language pack for vim

  { "vim/killersheep", cmd = { "KillKillKill" } },
  { "ThePrimeagen/vim-be-good", cmd = { "VimBeGood" } },
  { "felleg/TeTrIs.vim", cmd = { "Tetris" } },

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
    "iamcco/markdown-preview.nvim",
    setup = function()
      if vim.fn.executable "npx" then
        vim.cmd [[cd app && npx --yes yarn install]]
      else
        vim.cmd [[mkdp#util#install() ]]
      end
    end,
    ft = "markdown",
  },
}
