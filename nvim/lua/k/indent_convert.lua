-- lua/k/indent_convert.lua
-- Space ↔ tab conversion commands (KcConvertSpaceToTabs / KcConvertTabsToSpace)

-- KcConvertSpaceToTabs [count]
-- Convert leading spaces (and mixed tab/space indentation) to tabs.
-- count = spaces per tab (default 2). 'e' flag suppresses E486 when a line
-- has no leading whitespace.
vim.api.nvim_create_user_command(
  "KcConvertSpaceToTabs",
  function(opts)
    local n = tonumber(opts.args) or 2
    if n <= 0 then n = 2 end
    vim.cmd(
      opts.line1 .. "," .. opts.line2
        .. [[s#^\s\+#\=repeat("\t", indent(line('.')) / ]]
        .. n
        .. [[) . repeat(" ", indent(line('.')) % ]]
        .. n
        .. [[)#e]]
    )
  end,
  { nargs = "?", range = "%", desc = "Convert spaces to tabs. Usage: :%KcConvertSpaceToTabs [count]. Default count: 2" }
)

-- KcConvertTabsToSpace [count]
-- Expand leading tabs (and mixed tab/space indentation) to spaces.
-- count = spaces per tab (default 2). Uses ^\s\+ to catch mixed indentation
-- lines like "  \t  \t  ". The substitute() call expands only \t chars to
-- count spaces, preserving existing space indentation. 'e' flag suppresses
-- E486 when a line has no leading whitespace.
vim.api.nvim_create_user_command(
  "KcConvertTabsToSpace",
  function(opts)
    local n = tonumber(opts.args) or 2
    if n <= 0 then n = 2 end
    vim.cmd(
      opts.line1 .. "," .. opts.line2
        .. [[s#^\s\+#\=substitute(submatch(0), "\t", repeat(' ', ]]
        .. n
        .. [[), 'g')#e]]
    )
  end,
  { nargs = "?", range = "%", desc = "Convert tabs to spaces. Usage: :%KcConvertTabsToSpace [count]. Default count: 2" }
)
