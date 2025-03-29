local M = {}

function M.get_jumpfiles()
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
      if not jumplist[i].filename then
        jumplist[i].filename = vim.api.nvim_buf_get_name(jumplist[i].bufnr)
      end
      table.insert(sorted_jumplist, jumplist[i])
    end
  end
  return sorted_jumplist
end

function M.picker_jumpfiles()
  Snacks.picker {
    title = "Find jump files",
    items = (function()
      local sorted_jumplist = M.get_jumpfiles()
      print(vim.inspect(items))
      -- Create items for snack picker
      -- https://github.com/folke/snacks.nvim/discussions/498#discussioncomment-11859446
      local items = {}
      for i, j in ipairs(sorted_jumplist) do
        table.insert(items, {
          bufnr = j.bufnr,
          file = j.filename,
          text = j.text,
          pos = {j.col, j.lnum},
        })
      end
      return items
    end)(),
    confirm = function(picker, item) vim.api.nvim_win_set_buf(0, item.bufnr) end,
  }
end

return M
