local min = math.min
local max = math.max

---@param x string
---@return number
local function len(x) return x:len() end

---@return {number, number, number, number} y, x, height, width
local function block_pos(y1, x1, y2, x2)
  return min(y1, y2), min(x1, x2), max(y1, y2) - min(y1, y2) + 1, max(x1, x2) - min(x1, x2) + 1
end

---Returns the character at the given position, or default if it is out of bounds.
---@param lines string[][]
---@param y number
---@param x number
---@param default string
local function char_at(lines, y, x, default)
  default = default or " "
  return not (0 <= y < #lines) and default or not (0 <= x <= #lines[y]) and default or lines[y][x]
end

local function draw_box() end
local function draw_box_with_label() end
local function fill_box() end
local function draw_line_vh() end
local function draw_line_hv() end

-- -------- Selection --------

---@param lines string[][]
---@param y1 integer
---@param x1 integer
---@param y2 integer
---@param x2 integer
local function find_box(lines, y1, x1, y2, x2)
    -- Select left |
    local sx = min(x1,x2)
    while not ("|+\n"):find(char_at(lines, y1, sx, '\n')) do
        sx = sx - 1
    end
    -- Select right |
    local ex = max(x1,x2)
    while not ("|+\n"):find(char_at(lines, y2, ex, '\n')) do
        ex = ex - 1
    end
    -- Select top -
    local sy = min(y1,y2)
    while not ("|+\n"):find(char_at(lines, y2, ex, '\n')) do
        ex = ex - 1
    end
    while char_at(lines, sy, sx, '\n') not in '-+\n':
        sy -= 1
    -- Select bottom -
    local ey = max(y1,y2)
    while char_at(lines, ey, ex, '\n') not in '-+\n':
        ey += 1
    return sy, sx, ey, ex
end

def select_outer_box(lines, y1, x1, y2, x2):
    return ["%d,%d,%d,%d" % find_box(lines, y1, x1, y2, x2)]

def select_inner_box(lines, y1, x1, y2, x2):
    sy, sx, ey, ex = find_box(lines, y1, x1, y2, x2)
    return ["%d,%d,%d,%d" % (min(sy+1,ey), min(sx+1,ex), max(ey-1,sy), max(ex-1,sx))]

---@param lines string
---@param p Area
local function select_outer_box(lines, p)

end
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

---@alias Area [integer, integer, integer, integer]

---@return Area
local function get_p()
  local p2 = get_end_pos()
  local p1 = get_start_pos()
  local y1 = p1[1] - 1
  local y2 = p2[1] - 1
  local x1 = p1[2] + p1[3] - 1
  local x2 = p2[2] + p2[3] - 1
  return { y1, x1, y2, x2 }
end

local function draw(cmd, args) CMDS[cmd](cmd, unpack(get_p()), unpack(args)) end

local function draw_with_label(cmd, args)
  vim.fn.inputsave()
  local label = vim.fn.input "Label: "
  vim.fn.inputrestore()
  draw(cmd, { label, unpack(args) })
end

---@param cmd string
---@param p Area
---@param contents string
local function do_select(cmd, p, contents) end

local function select(cmd)
  local p = get_p()
  local contents = vim.fn.join(vim.fn.getline(1, "$"), "\n")
  p = do_select(cmd, p, contents)
  vim.fn.setpos("'<", { 0, p[0], p[1], 0 })
  vim.fn.setpos("'>", { 0, p[2], p[3], 0 })
  vim.fn.cmd [[normal! gv]]
end
