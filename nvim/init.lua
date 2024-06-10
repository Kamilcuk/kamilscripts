-- init.lua

---@param fail boolean
local function lazyinstall(fail)
  local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
  if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
    if fail then
      error "Lazy not installed, use :KcInstall to install"
      return
    else
        -- stylua: ignore
        vim.fn.system(
            {"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath}
        )
    end
  end
  vim.opt.rtp:prepend(lazypath)

  -- validate that lazy is available
  if not pcall(require, "lazy") then error(("Unable to load lazy from: %s\n"):format(lazypath)) end

  -- ./lua/community.lua
  -- ./lua/plugins/user.lua
  require "lazy_setup"
  -- ./lua/polish.lua
  require "polish"
end

vim.api.nvim_create_user_command(
  "KcNixInstall",
  function() vim.cmd [[!nix-env -iA nixpkgs.nvim nixpkgs.tree-sitter nixpkgs.node nixpkgs.ripgrep]] end,
  {}
)
vim.api.nvim_create_user_command("KcInstall", function() lazyinstall(false) end, {})
lazyinstall(true)
