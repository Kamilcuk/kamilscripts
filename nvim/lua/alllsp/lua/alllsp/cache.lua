
---@class Cache
---@field version integer
---@field timestamp integer
---@field lspconfig CacheEntry
---@field null_diagnostic CacheEntry
---@field null_formatter CacheEntry

---@class CacheEntry
---@field timestamp integer
---@field data CacheEntryData

---@class CacheEntryData
---@field name string
---@field cmd string
---@field module string

local M = {}

---@return Cache?
local function get_cache()
  local cache = vim.fn.stdpath "cache" .. "/alllsp.json"
  local cache_file = io.open(cache, "r")
  if not cache_file then
    return nil
  end
  local ret = vim.json.decode(cache_file:read "*a")
  if not ret or ret.version ~= 1 then
    return nil
  end
  cache_file:close()
  return ret
end

---@param cache Cache
local function save_cache(cache)
  cache.version = 1
  cache.timestamp = os.time()
  local cache_file = io.open(vim.fn.stdpath "cache" .. "/alllsp.json", "w")
  if not cache_file then
    return nil
  end
  cache_file:write(vim.json.encode(cache))
  cache_file:close()
end

---@return Cache
---@param lspconfig bool?
---@param null_ls bool?
M.get = function()
  local cache = get_cache()
  if cache then
  end
  return cache
end
