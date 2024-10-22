--

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local conf = require("telescope.config").values

local M = {}

-- synchronize with https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/builtin/__internal.lua#L1483
M.jumpfilelist = function(opts)
  opts = opts or {}
  local jumplist = vim.fn.getjumplist()[1]

  -- Only unique files from jumplist
  local seen = {}
  for i = #jumplist, 1, -1 do
    local jump = jumplist[i]
    if seen[jump.bufnr] then table.remove(jumplist, seen[jump.bufnr]) end
    seen[jump.bufnr] = i
  end

  -- reverse the list
  local sorted_jumplist = {}
  for i = #jumplist, 1, -1 do
    if vim.api.nvim_buf_is_valid(jumplist[i].bufnr) then
      jumplist[i].text = vim.api.nvim_buf_get_lines(jumplist[i].bufnr, jumplist[i].lnum - 1, jumplist[i].lnum, false)[1]
        or ""
      table.insert(sorted_jumplist, jumplist[i])
    end
  end

  pickers
    .new(opts, {
      prompt_title = "JumpFileList",
      finder = finders.new_table {
        results = sorted_jumplist,
        entry_maker = make_entry.gen_from_quickfix(opts),
      },
      previewer = conf.qflist_previewer(opts),
      sorter = conf.generic_sorter(opts),
    })
    :find()
end

return M
