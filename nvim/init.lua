-- init.lua

---@param byuser boolean
local function lazyinstall(byuser)
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if byuser then
    vim.notify("Checking if Lazy is installed...")
  end
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    if byuser then
      vim.notify("Lazy not found, installing...")
      load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
    else
      vim.notify("Lazy not installed, use :KcInstall to install")
      return
    end
  end
  vim.opt.rtp:prepend(lazypath)
  if byuser then
    vim.notify("Lazy installed, loading...")
  end

  -- validate that lazy is available
  if not pcall(require, "lazy") then
    error(("Unable to load lazy from: %s\n"):format(lazypath))
  end
  if byuser then
    vim.notify("Lazy loaded successfully")
  end

  -- ./lua/community.lua
  -- ./lua/plugins/user.lua
  require "lazy_setup"
  -- ./lua/polish.lua
  require "polish"
end

vim.api.nvim_create_user_command("KcInstall", function() lazyinstall(true) end, {})

lazyinstall(false)
