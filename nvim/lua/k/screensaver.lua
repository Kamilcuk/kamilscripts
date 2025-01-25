--

local M = {}

---@param delay_ms number The delay in milliseconds of inactivity to wait before starting the screensaver
---@param start fun(): any The function that starts the screensaver
---@param stop fun(any): nil The function that stops the screensaver
---@param header string? Custom header to print when starting and stopping the screensaver
---@return any The timer object that waits for the screensaver.
function M.run_screensaving(delay_ms, start, stop, header)
  ---@diagnostic disable-next-line: undefined-field
  local timer = vim.loop.new_timer()
  local running = false
  local starting = false
  local stopping = false
  local data = nil
  ---@diagnostic disable-next-line: unused-local
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
    timer:start(delay_ms, 0, function()
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
  return timer
end

---@class ScreensaverInstanceConfig
---@field plugin string The plugin name, without directory.
---@field themes [any] The list of themes that the screensaver supports.
---@field module string The require module name of the plugin.
---@field start fun(): any The function that starts the screensaver.
---@field stop fun(any): nil The function that stops the screensaver.
---@field msg fun(): string The function that returns the message to print when starting and stopping the screensaver.

---@type [ScreensaverInstanceConfig]
M.screensavers = {
  {
    plugin = "let-it-snow.nvim",
    themes = { "" },
    module = "let-it-snow",
    start = function() require("let-it-snow").let_it_snow() end,
    stop = function()
      local snow = require "let-it-snow.snow"
      for k in pairs(snow.running) do
        snow.end_hygge(k)
      end
    end,
    msg = function() return "let-it-snow" end,
  },
  {
    plugin = "animatedbg.nvim",
    themes = { "matrix", "fireworks", "demo" },
    module = "animatedbg-nvim",
    start = function() require("animatedbg-nvim").play { animation = M.state.theme, duration = 32000000 } end,
    stop = function() require("animatedbg-nvim").stop_all() end,
    msg = function() return "animatedbg.nvim " .. M.state.theme end,
  },
  {
    plugin = "cellular-automaton.nvim",
    themes = { "make_it_rain", "game_of_life" },
    module = "cellular-automaton",
    start = function()
      -- cellular automation requires treesitter
      local buf = vim.api.nvim_get_current_buf()
      local highlighter = require "vim.treesitter.highlighter"
      if highlighter.active[buf] then
        -- cellular automation looks much nicer with disabled wrap
        local wrapsave = vim.o.wrap
        vim.o.wrap = false
        require("cellular-automaton").start_animation(M.state.theme)
        return wrapsave
      end
    end,
    stop = function(wrapsave)
      if wrapsave ~= nil then vim.o.wrap = wrapsave end
      require("cellular-automaton.manager").clean()
    end,
    msg = function() return "cellular-automaton " .. M.state.theme end,
  },
  {
    plugin = "drop.nvim",
    themes = {
      "april_fools",
      "arcade",
      "art",
      "bakery",
      "beach",
      "binary",
      "bugs",
      "business",
      "candy",
      "cards",
      "carnival",
      "casino",
      "cats",
      "coffee",
      "cyberpunk",
      "deepsea",
      "desert",
      "dice",
      "diner",
      "easter",
      "emotional",
      "explorer",
      "fantasy",
      "farm",
      "garden",
      "halloween",
      "jungle",
      "leaves",
      "lunar",
      "magical",
      "mathematical",
      "matrix",
      "medieval",
      "musical",
      "mystery",
      "mystical",
      "new_year",
      "nocturnal",
      "ocean",
      "pirate",
      "retro",
      "snow",
      "spa",
      "space",
      "sports",
      "spring",
      "stars",
      "steampunk",
      "st_patricks_day",
      "summer",
      "temporal",
      "thanksgiving",
      "travel",
      "tropical",
      "urban",
      "us_independence_day",
      "valentines_day",
      "wilderness",
      "wildwest",
      "winter_wonderland",
      "xmas",
      "zodiac",
      "zoo",
    },
    module = "drop",
    start = function()
      ---@diagnostic disable-next-line: missing-fields
      require("drop").setup { theme = M.state.theme, screensaver = false }
      require("drop").show()
    end,
    stop = function() require("drop").hide() end,
    msg = function() return "drop.nvim " .. M.state.theme end,
  },
  {
    plugin = "you-are-an-idiot.nvim",
    themes = { "" },
    module = "you-are-an-idiot",
    start = function() require("you-are-an-idiot").run() end,
    stop = function() require("you-are-an-idiot").abort() end,
    msg = function() return "you-are-an-idiot" end,
  },
}

---@param idx number The index of the screensaver to find
---@return [ScreensaverInstanceConfig, any]?
function M.screensavers_find(idx)
  local i = 1
  for _, v in ipairs(M.screensavers) do
    for _, theme in ipairs(v.themes or {""}) do
      if i == idx then return { v, theme } end
      i = i + 1
    end
  end
end

---@return number The total number of screensavers configurations including themes.
function M.screensavers_count()
  local i = 0
  for _, v in ipairs(M.screensavers) do
    i = i + #(v.themes or {""})
  end
  return i
end

---@class ScreensaverSettings
---@field delay_ms boolean|integer? The delay in milliseconds of inactivity to wait before starting the screensaver. False or negative or zero to disable.
---@field number number? The index of the screensaver to start.
---@field module string? The module name of the screensaver to start. If number is set, this is ignored.
---@field theme any? The theme of the screensaver to start.

---@class ScreensaverState : ScreensaverSettings
---@field screensaver ScreensaverInstanceConfig? The screensaver configuration
---@field timer any? The timer object that runs the screensaver
---@field started boolean|number? Was the screensaver started?
---@field start_ret any? The return value of the start function

---@type ScreensaverState
M.state = {}

---@param setting ScreensaverSettings
function M.config(setting)
  M.stop()
  --
  ---@cast setting ScreensaverState
  ---@type ScreensaverState
  M.state = setting
  -- Find the configuration.
  if M.state.number ~= nil then
    local ret = M.screensavers_find(M.state.number)
    assert(ret ~= nil, "Invalid number: " .. M.state.number)
    M.state.screensaver, M.state.theme = ret[1], ret[2]
  else
    M.state.screensaver = nil
    for _, v in ipairs(M.screensavers) do
      if v.module == M.state.module then
        M.state.screensaver = v
        break
      end
    end
    assert(M.state.screensaver ~= nil, "Invalid module: " .. vim.inspect(M.state.module))
  end
  -- Arm the timer.
  if M.state.delay_ms ~= false and M.state.delay_ms ~= nil and M.state.delay_ms > 0 then
    if M.state.timer ~= nil then M.state.timer:stop() end
    M.state.timer = M.run_screensaving(M.state.delay_ms, M.start, M.stop)
  end
end

function M.reload() package.loaded["k.screensaver"] = nil end

function M.header()
  local header = M.state.screensaver.msg()
  if M.state.number then header = M.state.number .. " " .. header end
  return header
end

---@param idx number? The index of the screensaver to start. If nil, it will start the current screensaver. Runs M.config when idx is set.
function M.start(idx)
  if M.started then return end
  if idx ~= nil then
    M.state.number = idx
    M.config(M.state)
  end
  print(vim.fn.strftime "%c " .. "Starting " .. M.header())
  M.state.start_ret = M.state.screensaver.start()
  M.state.started = true
end

function M.stop()
  if not M.state.started then return end
  print(vim.fn.strftime "%c " .. "Stopping " .. M.header())
  M.state.screensaver.stop(M.state.start_ret)
  M.state.started = false
end

function M.next()
  M.stop()
  M.state.number = (M.state.number or 0) < M.screensavers_count() and (M.state.number or 0) + 1 or 1
  M.config(M.state)
  vim.schedule(M.start)
end

function M.prev()
  M.stop()
  M.state.number = (M.state.number or 0) > 1 and M.state.number - 1 or M.screensavers_count()
  M.config(M.state)
  vim.schedule(M.start)
end

function M.discover()
  print "Starting screensaver discover. Press q to stop. Press UP and DOWN to change screensaver. Some screensavers require to press ESC to stop."
  M.state.delay_ms = -1
  M.state.number = 0
  M.keymap_save = vim.api.nvim_buf_get_keymap(0, "n")
  for _, v in ipairs(M.discover_keymap) do
    -- print(v[1], v[2])
    vim.keymap.set("n", v[1], v[2])
  end
end

---@param maps table
---@param lhs string
---@return table?
local function find_mapping(maps, lhs)
  for _, value in ipairs(maps) do
    if value.lhs == lhs then return value end
  end
end

function M.discover_stop()
  M.stop()
  for _, v in ipairs(M.discover_keymap) do
    local keymap = find_mapping(M.keymap_save, v[1])
    if keymap then
      vim.keymap.set("n", v[1], keymap.rhs)
    else
      vim.keymap.del("n", v[1])
    end
  end
  print "Stopping screensaver discover"
end

---@type table<string, function> The keymap for the discover mode.
M.discover_keymap = {
  { "<UP>", M.next },
  { "<DOWN>", M.prev },
  { "q", M.discover_stop },
}

---@type LazySpec
M.plugins = {
  "marcussimonsen/let-it-snow.nvim",
  { "folke/drop.nvim", opts = { screensaver = false } },
  "eandrju/cellular-automaton.nvim",
  { "alanfortlink/animatedbg.nvim", opts = {} },
  "GitMarkedDan/you-are-an-idiot.nvim",
}

return M
