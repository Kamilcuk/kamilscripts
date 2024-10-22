-- alternative compact renderer for nvim-notify.
-- Wraps text and adds some padding (only really to the left, since padding to
-- the right is somehow not display correctly).
-- Modified version of https://github.com/rcarriga/nvim-notify/blob/master/lua/notify/render/compact.lua
--------------------------------------------------------------------------------

local api = vim.api
local base = require "notify.render.base"

---@param line string
---@param width number
---@return string[]
local function split_length(line, width)
  local text = {}
  local next_line
  while true do
    if #line == 0 then return text end
    text[#text + 1] = line:sub(1, width)
    line = line:sub(width)
  end
end

---@param lines string[]
---@param max_width number
---@return string[]
local function custom_wrap(lines, max_width)
  local wrapped_lines = {}
  for _, line in pairs(lines) do
    local new_lines = split_length(line, max_width)
    for _, nl in ipairs(new_lines) do
      -- nl = nl:gsub("^%s*", " "):gsub("%s*$", " ") -- ensure padding
      table.insert(wrapped_lines, nl)
    end
  end
  return wrapped_lines
end

---@param bufnr number
---@param notif object
---@param highlights object
---@param config object plugin config_obj
return function(bufnr, notif, highlights, config)
  local namespace = base.namespace()
  local icon = notif.icon
  local title = notif.title[1]

  local prefix
  if type(title) == "string" and #title > 0 then
    prefix = string.format("%s %s:", icon, title)
  else
    prefix = string.format("%s", icon)
  end
  notif.message[1] = string.format("%s %s", prefix, notif.message[1])

  notif.message = custom_wrap(notif.message, config.max_width() or 80)

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, notif.message)

  local icon_length = vim.str_utfindex(icon)
  local prefix_length = vim.str_utfindex(prefix)

  vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
    hl_group = highlights.icon,
    end_col = icon_length + 1,
    priority = 50,
  })
  vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, icon_length + 1, {
    hl_group = highlights.title,
    end_col = prefix_length + 1,
    priority = 50,
  })
  vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, prefix_length + 1, {
    hl_group = highlights.body,
    end_line = #notif.message,
    priority = 50,
  })
end
