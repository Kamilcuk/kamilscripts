local M = {}

---@param timeout_s number
---@param start fun(): any
---@param stop fun(any): nil
---@param header string?
function M.screensaver(timeout_s, start, stop, header)
  local timer = vim.loop.new_timer()
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

---@class ScreensaverConfig
---@field themes [any]?
---@field try fun(): nil
---@field start fun(): any
---@field stop fun(any): nil
---@field msg string?
---
---@type { [string]: ScreensaverConfig }
M.screensavers = {
  ["let-it-snow.nvim"] = {
    try = function() require "let-it-snow" end,
    start = function() require("let-it-snow").let_it_snow() end,
    stop = function()
      local snow = require "let-it-snow.snow"
      for k in pairs(snow.running) do
        snow.end_hygge(k)
      end
    end,
    msg = "let-it-snow",
  },
  ["animatedbg.nvim"] = {
    themes = { "matrix", "fireworks", "demo" },
    try = function() require "animatedbg-nvim" end,
    start = function() require("animatedbg-nvim").play { animation = vim.g.screensaver.theme, duration = 32000000 } end,
    stop = function() require("animatedbg-nvim").stop_all() end,
    msg = "animatedbg.nvim " .. vim.g.screensaver.theme,
  },
  { "cellular-automaton.nvim", animation = "make_it_rain" },
  { "cellular-automaton.nvim", animation = "game_of_life" },
}

---@class ScreensaverConfig
---@field [1] string
---@field delay integer

vim.g.screensaver = {
  "1",
  delay = 120,
}

function M.configure() vim.g.screensaver = vim.tbl_deep_extend(vim.g.screensaver, M.screensavers[vim.g.screensaver[1]]) end

M.configure()

return {
  {
    "marcussimonsen/let-it-snow.nvim",
    enable = false,
    cmd = "LetItSnow",
    opts = { delay = 100 },
  },

  {
    "folke/drop.nvim",
    enabled = false,
    opts = { screensaver = 1000 * 60 * 5, theme = "winter_wonderland" },
  },

  {
    "eandrju/cellular-automaton.nvim",
    enabled = false,
    cmd = { "CellularAutomaton" },
    init = function()
      M.screensaver(60, function()
        -- cellular automation requires treesitter
        local buf = vim.api.nvim_get_current_buf()
        local highlighter = require "vim.treesitter.highlighter"
        if highlighter.active[buf] then
          -- cellular automation looks much nicer with disabled wrap
          local wrapsave = vim.o.wrap
          vim.o.wrap = false
          local a = require("cellular-automaton").start_animation
          -- a "game_of_life"
          a "make_it_rain"
          return wrapsave
        end
      end, function(wrapsave)
        if wrapsave ~= nil then vim.o.wrap = wrapsave end
        require("cellular-automaton.manager").clean()
      end, "cellular automaton")
    end,
  },

  {
    "alanfortlink/animatedbg.nvim",
    opts = { fps = 30 },
  },
}
