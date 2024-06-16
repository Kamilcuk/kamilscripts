-- soundme/init.lua

local Job = require "plenary.job"

-------------------------------------------------------------------------------

---@class SoundmeTheme
---@field public path string
---@field public dir string
---@field public events table<string, string>

---@class SoundmeOpts
---@field public debug boolean?
---@field public command string[]?
---@field public theme string

-------------------------------------------------------------------------------

---@class Soundme
---@field public c SoundmeOpts
---@field public theme SoundmeTheme
---@field public dir string
local M = {}

---@type string[]
M.PLAYERS = {
  "aplay",
  "paplay",
}

---@type table<string, SoundmeTheme>
M.PRESETS = {

  clackclack = {
    path = "clackclack.symphony",
    dir = "autoload",
    events = {
      CursorMoved = "pat.wav",
      CursorMovedI = "keyboard_slow.wav",
      WinEnter = "woosh.wav",
      InsertEnter = "penin.wav",
      InsertLeave = "punch.wav",
      BufRead = "blop.wav",
      BufWritePost = "woosh.wav",
      CursorHoldI = "woosh.wav",
      FocusGained = "woosh.wav",
      FocusLost = "woosh.wav",
      VimLeave = "woosh.wav",
    },
  },

  bubbletrouble = {
    path = "bubbletrouble.symphony",
    dir = "autoload",
    events = {
      CursorMoved = "plop.wav",
      CursorMovedI = "bub.wav",
      WinEnter = "techno.wav",
      InsertEnter = "bubble.wav",
      InsertLeave = "mouth_pop.wav",
    },
  },

  kamil = {
    path = "bubbletrouble.symphony",
    dir = "autoload",
    events = {
      -- CursorMoved = "plop.wav",
      -- CursorMovedI = "bub.wav",
      WinEnter = "techno.wav",
      InsertEnter = "bubble.wav",
      InsertLeave = "mouth_pop.wav",
    },
  },
}

---@param msg string
function M:log(msg)
  if self.c.debug then print("soundme: " .. msg) end
end

---@param opts SoundmeOpts?
function M:setup(opts)
  self.c = opts or {}
  --
  if self.c.theme == nil then
    self:log "no theme"
    return
  elseif type(self.c.theme) == "string" then
    self.theme = M.PRESETS[self.c.theme]
  else
    error "TODO"
  end
  --
  local rt = vim.api.nvim_list_runtime_paths()
  for _, v in ipairs(rt) do
    if v:find("/" .. self.theme.path) then
      self.dir = v
      break
    end
  end
  if self.dir == nil then error("Theme " .. self.theme.path .. " not found in runtimepaths: " .. vim.inspect(rt)) end
  self.dir = self.dir .. "/" .. (self.theme.dir and self.theme.dir .. "/" or "")
  --
  self.command = self.c.command or self.command
  if self.command == nil then
    for _, v in ipairs(self.PLAYERS) do
      if vim.fn.executable(v) then self.command = { v } end
    end
  end
  if self.command == nil then
    self:log "Could not determine command to play sound with"
    return
  end
  --
  for _, v in pairs(self.theme.events) do
    if not vim.fn.filereadable(self.dir .. v) then error("File is not readable: " .. self.dir .. v) end
  end
  --
  local group = vim.api.nvim_create_augroup("soundme", {})
  for k, v in pairs(self.theme.events) do
    vim.api.nvim_create_autocmd(k, {
      group = group,
      callback = function() self:play(self.dir .. v) end,
    })
  end
  --
  self:log(vim.inspect(self))
end

--- Play the file
---@param file string
function M:play(file)
  if self.command == nil then return end
  if not vim.fn.filereadable(file) then return end
  ---@type string[]
  local cmd = {
    unpack(self.command),
    file,
  }
  Job:new({
    command = cmd[1],
    args = { unpack(cmd, 2) },
  }):start()
end

return M
