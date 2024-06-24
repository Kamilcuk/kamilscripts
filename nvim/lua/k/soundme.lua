-- soundme/init.lua

local Job = require "plenary.job"

-------------------------------------------------------------------------------

---@class SoundmeTheme
---@field public prefix string?
---@field public suffix string?
---@field public events table<string, string>

---@class SoundmeOpts
---@field public debug boolean?
---@field public command string[]?
---@field public theme string|SoundmeTheme

-------------------------------------------------------------------------------

---@class Soundme
---@field public c SoundmeOpts
---@field public theme SoundmeTheme
---@field public path string
---@field public command string[]
local M = {}

---@type string[][]
M.PLAYERS = {
  { "aplay" },
  { "paplay" },
  { "vlc", "--quiet" },
  { "mpv" },
}

---@type table<string, SoundmeTheme>
M.PRESETS = {

  clackclack = {
    prefix = "clackclack.symphony/autoload/",
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
    prefix = "bubbletrouble.symphony/autoload/",
    events = {
      CursorMoved = "plop.wav",
      CursorMovedI = "bub.wav",
      WinEnter = "techno.wav",
      InsertEnter = "bubble.wav",
      InsertLeave = "mouth_pop.wav",
    },
  },

  kamil = {
    prefix = "bubbletrouble/autoload/",
    events = {
      -- CursorMoved = "plop.wav",
      -- CursorMovedI = "bub.wav",
      WinEnter = "techno.wav",
      InsertEnter = "bubble.wav",
      InsertLeave = "mouth_pop.wav",
    },
  },

  freedesktop = {
    prefix = "/usr/share/sounds/freedesktop/stereo/",
    suffix = ".oga",
    events = {
      WinEnter = "service-login",
      InsertEnter = "power-plug",
      InsertLeave = "power-unplug",
      BufWritePost = "complete",
    },
  },

  oxygen = {
    prefix = "/usr/share/sounds/oxygen/stereo/",
    suffix = ".ogg",
    events = {
      WinEnter = "desktop-login-short",
      InsertEnter = "power-plug",
      InsertLeave = "power-unplug",
      BufWritePost = "completion-success",
    },
  },
}

---@param msg string
function M:log(msg)
  if self.c.debug then print("soundme: " .. msg) end
end

local function string_endswith(str, suffix) return str:sub(-#suffix) == suffix end

---@param path string
---@return string?
local function find_path(path)
  if path:sub(1, 1) == "/" then
    return path
  else
    local slash = path:find "/"
    local plugin = slash and path:sub(1, slash - 1) or path
    local sub = slash and path:sub(slash) or ""
    local rt = vim.api.nvim_list_runtime_paths()
    for _, v in ipairs(rt) do
      if string_endswith(v, "/" .. plugin) then return v .. sub end
    end
  end
  return nil
end

---@param opts SoundmeOpts?
function M:setup(opts)
  self.c = opts or {}
  --
  if self.theme == nil then
    if self.c.theme == nil then
      self:log "no theme"
      return
    elseif type(self.c.theme) == "string" then
      self.theme = M.PRESETS[self.c.theme]
    else
      ---@diagnostic disable-next-line: assign-type-mismatch
      self.theme = self.c.theme
    end
  end
  assert(self.theme ~= nil)
  --
  self.command = self.c.command or self.command
  if self.command == nil then
    for _, v in ipairs(self.PLAYERS) do
      if vim.fn.executable(v[1]) ~= 0 then
        self.command = { unpack(v) }
        break
      end
    end
  end
  self.command = nil
  if self.command == nil then
    self:log "Could not determine command to play sound with"
    return
  end
  --
  local group = vim.api.nvim_create_augroup("soundme", {})
  for event, file in pairs(self.theme.events) do
    file = (self.theme.prefix or "") .. file .. (self.theme.suffix or "")
    local path = find_path(file)
    assert(path ~= nil, "File for event " .. event .. " not found in runtimepath: " .. file)
    assert(vim.fn.filereadable(path), "File for event " .. event .. " does not exists: " .. path)
    vim.api.nvim_create_autocmd(event, {
      group = group,
      callback = function() self:play(path) end,
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
  local cmd = { unpack(self.command), file }
  Job:new({
    command = cmd[1],
    args = { unpack(cmd, 2) },
  }):start()
end

return M
