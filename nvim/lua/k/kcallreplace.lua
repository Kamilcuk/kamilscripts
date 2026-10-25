-- KcAllReplace / KcAllReplaceUndo (requires grug-far.nvim)
-- Provides command-line-wide search & replace across all git-tracked files,
-- plus an undo that reverts only the lines affected by the last replacement.

local has_grugfar = pcall(require, "grug-far")
if not has_grugfar then return end

--- stored pattern/replacement from the last KcAllReplace, for undo
vim.g.kc_all_replace_last = nil

---@return string[] git-tracked files (relative paths)
local function kc_git_tracked_files()
  local out = vim.fn.systemlist "git ls-files"
  if vim.v.shell_error ~= 0 then return {} end
  return out
end

---@return string[] files changed since HEAD
local function kc_git_changed_files()
  local out = vim.fn.systemlist "git diff --name-only HEAD"
  if vim.v.shell_error ~= 0 then return {} end
  return out
end

---Escape a path for GrugFar's splitPaths (handles spaces).
---@param path string
---@return string
local function kc_escape_path(path)
  return path:gsub(" ", "\\ ")
end

---Check if a file is binary (null byte in first line).
---@param file string
---@return boolean
local function kc_is_binary(file)
  local ok_read, first = pcall(vim.fn.readfile, file, 1)
  return ok_read and #first > 0 and tostring(first[1]):find("\0") ~= nil
end

---Get original file content from git HEAD as a list of lines.
---@param file string relative path (as returned by git diff/ls-files)
---@return string[]? lines, string? error
local function kc_git_show_head(file)
  local out = vim.fn.systemlist({ "git", "show", "HEAD:" .. file })
  if vim.v.shell_error ~= 0 then return nil, "git show failed for " .. file end
  return out
end

---Parse command arguments, supporting three syntaxes:
---  1. Two separate args:  pattern replacement  → wraps pattern in \<...\> (word-boundary)
---  2. Slash-delimited:    /pattern/replacement/  (s/// style, raw regex)
---  3. s///-style:         s/pattern/replacement/
---@param fargs string[]
---@return string? pattern, string? replacement
local function kc_parse_args(fargs)
  if #fargs >= 2 then
    return "\\<" .. fargs[1] .. "\\>", fargs[2]
  elseif #fargs == 1 then
    local arg = fargs[1]
    -- strip optional leading 's' or 's/'
    if arg:sub(1, 2) == "s/" then
      arg = arg:sub(3)
    elseif arg:sub(1, 1) == "/" then
      arg = arg:sub(2)
    else
      return nil, nil
    end
    -- now arg is pattern/replacement/ or pattern/replacement
    local rest = arg
    -- find unescaped '/' that ends the pattern
    local i = 1
    while i <= #rest do
      local c = rest:sub(i, i)
      if c == "/" then break end
      if c == "\\" then i = i + 1 end
      i = i + 1
    end
    local pattern = rest:sub(1, i - 1)
    rest = rest:sub(i + 1)
    -- find unescaped '/' that ends the replacement
    local j = 1
    while j <= #rest do
      if rest:sub(j, j) == "/" then break end
      j = j + 1
    end
    local replacement = rest:sub(1, j - 1)
    if pattern ~= "" and replacement ~= nil then return pattern, replacement end
  end
  return nil, nil
end

-- KcAllReplace ──────────────────────────────────────────────────
-- Usage:
--   :KcAllReplace /old/new/
--   :KcAllReplace old new
vim.api.nvim_create_user_command("KcAllReplace", function(args)
  local pattern, replacement = kc_parse_args(args.fargs)
  if not pattern or not replacement then
    vim.notify(
      "KcAllReplace: usage: :KcAllReplace /pattern/replacement/  or  :KcAllReplace pattern replacement",
      vim.log.levels.ERROR
    )
    return
  end

  -- Store for undo
  vim.g.kc_all_replace_last = {
    pattern = pattern,
    replacement = replacement,
  }

  -- Build paths string (newline-separated, space-escaped for splitPaths)
  local files = kc_git_tracked_files()
  if #files == 0 then
    vim.notify("KcAllReplace: no git-tracked files found", vim.log.levels.WARN)
    return
  end
  local escaped = {}
  for _, f in ipairs(files) do
    table.insert(escaped, kc_escape_path(f))
  end
  local paths_str = table.concat(escaped, "\n")

  -- Use GrugFar's headless replace (async, fires callback when done)
  require("grug-far").headless_replace({
    prefills = {
      search = pattern,
      replacement = replacement,
      paths = paths_str,
    },
  }, function(status, error_message)
    if status and status == "error" then
      vim.notify(
        "KcAllReplace: failed — " .. (error_message or "unknown error"),
        vim.log.levels.ERROR
      )
    else
      vim.notify("KcAllReplace: done", vim.log.levels.INFO)
    end
  end)
end, {
  nargs = "*",
  bar = true,
  desc = "Replace pattern in all git-tracked files (via grug-far)",
})

-- KcAllReplaceUndo ──────────────────────────────────────────────
-- Reverses the *last* KcAllReplace, reverting only lines that
-- match what the substitution would have produced.
-- Pre-existing occurrences of the replacement text are left untouched.
--
-- Usage:
--   :KcAllReplaceUndo              " uses stored pattern/replacement
--   :KcAllReplaceUndo /old/new/    " explicit
--   :KcAllReplaceUndo old new
vim.api.nvim_create_user_command("KcAllReplaceUndo", function(args)
  local pattern, replacement = kc_parse_args(args.fargs)
  if not pattern or not replacement then
    if vim.g.kc_all_replace_last then
      pattern = vim.g.kc_all_replace_last.pattern
      replacement = vim.g.kc_all_replace_last.replacement
    else
      vim.notify(
        "KcAllReplaceUndo: no previous KcAllReplace found. Usage: :KcAllReplaceUndo [pattern replacement]",
        vim.log.levels.ERROR
      )
      return
    end
  end

  local changed_files = kc_git_changed_files()
  if #changed_files == 0 then
    vim.notify("KcAllReplaceUndo: no changed files since HEAD", vim.log.levels.INFO)
    return
  end

  local lines_reverted = 0
  local files_changed = 0

  for _, file in ipairs(changed_files) do
    if vim.fn.filereadable(file) == 1 and not kc_is_binary(file) then
      local orig = kc_git_show_head(file)
      if orig then
        local current = vim.fn.readfile(file)
        local modified = false
        for i = 1, #current do
          if orig[i] then
            -- Check: does applying pattern→replacement to the original line
            -- produce the current line? If so AND the line actually changed,
            -- this line was altered by our substitution — revert it.
            -- Pre-existing matches of the replacement text are safe: they
            -- were already in the original, so applying the substitution
            -- doesn't change them, so current[i] == orig[i] and the
            -- "current[i] ~= orig[i]" guard prevents reverting.
            local expected = vim.fn.substitute(orig[i], pattern, replacement, "g")
            if current[i] == expected and current[i] ~= orig[i] then
              current[i] = orig[i]
              lines_reverted = lines_reverted + 1
              modified = true
            end
          end
        end
        if modified then
          vim.fn.writefile(current, file)
          files_changed = files_changed + 1
        end
      end
    end
  end

  -- Reload any open buffers that were modified
  vim.cmd "checktime"

  vim.notify(string.format(
    "KcAllReplaceUndo: %d lines reverted in %d files",
    lines_reverted, files_changed
  ))
end, {
  nargs = "*",
  bar = true,
  desc = "Undo last KcAllReplace across git-tracked files",
})
