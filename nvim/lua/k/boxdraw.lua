local min = math.min
local max = math.max
---@param x string
---@return number
local function len(x) return x:len() end
---@return {number, number, number, number} y, x, height, width
local function block_pos(y1, x1, y2, x2)
  return min(y1, y2), min(x1, x2), max(y1, y2) - min(y1, y2) + 1, max(x1, x2) - min(x1, x2) + 1
end

local function draw_box() end
local function draw_box_with_label() end
local function fill_box() end
local function draw_line_vh() end
local function draw_line_hv() end
local function select_outer_box() end
local function select_inner_box() end

local CMDS = {
  -- Box drawing
  ["+o"] = { draw_box },
  ["+O"] = { draw_box_with_label, "middle", "center" },
  ["+{O"] = { draw_box_with_label, "middle", "left" },
  ["+}O"] = { draw_box_with_label, "middle", "right" },
  ["+[O"] = { draw_box_with_label, "top", "middle" },
  ["+]O"] = { draw_box_with_label, "bottom", "middle" },
  ["+{[O"] = { draw_box_with_label, "top", "left" },
  ["+{]O"] = { draw_box_with_label, "top", "right" },
  ["+}[O"] = { draw_box_with_label, "bottom", "left" },
  ["+}]O"] = { draw_box_with_label, "bottom", "right" },

  -- Label drawing
  ["+c"] = { fill_box, "middle", "center" },
  ["+[c"] = { fill_box, "middle", "left" },
  ["+]c"] = { fill_box, "middle", "right" },
  ["+{c"] = { fill_box, "top", "center" },
  ["+}c"] = { fill_box, "bottom", "center" },
  ["+{[c"] = { fill_box, "top", "left" },
  ["+{]c"] = { fill_box, "top", "right" },
  ["+}[c"] = { fill_box, "bottom", "left" },
  ["+}]c"] = { fill_box, "bottom", "right" },

  -- Line drawing
  ["+>"] = { draw_line_vh, "-->" },
  ["+<"] = { draw_line_vh, "-->" },
  ["+V"] = { draw_line_hv, "-->" },
  ["+v"] = { draw_line_hv, "-->" },
  ["+^"] = { draw_line_hv, "-->" },

  ["++>"] = { draw_line_vh, "<->" },
  ["++<"] = { draw_line_vh, "<->" },
  ["++V"] = { draw_line_hv, "<->" },
  ["++v"] = { draw_line_hv, "<->" },
  ["++^"] = { draw_line_hv, "<->" },

  ["+-"] = { draw_line_vh, "---" },
  ["+_"] = { draw_line_vh, "---" },
  ["+|"] = { draw_line_hv, "---" },

  -- Selection
  ["ao"] = { select_outer_box },
  ["io"] = { select_inner_box },
  ["+ao"] = { select_outer_box },
  ["+io"] = { select_inner_box },
}

local function get_end_pos()
  local m = vim.fn.getpos "'m"
  vim.cmd [[normal! gvmm\<Esc>]]
  local p = vim.fn.getpos "'m"
  vim.fn.setpos("'m", m)
  return p
end

local function get_start_pos(startPos)
  local p1 = vim.fn.getpos "'<"
  local p2 = vim.fn.getpos "'>"
  if p1 == startPos then
    return p2
  else
    return p1
  end
end

local function draw(cmd, args)
  local p2 = get_end_pos()
  local p1 = get_start_pos()
  local y1 = p1[1] - 1
  local y2 = p2[1] - 1
  local x1 = p1[2] + p1[3] - 1
  local x2 = p2[2] + p2[3] - 1

end
