-- Read-through for globals persisted under the pre-rename names.
-- When the new key is nil, the legacy value is copied into it once; the legacy key is never written or deleted.
local M = {}

local LEGACY = { BufferlinesPositions = "BufferlinePositions", BufferlinesPinnedBuffers = "BufferlinePinnedBuffers" }

---@param key string new global name
---@return any
function M.read(key)
  if vim.g[key] == nil and LEGACY[key] and vim.g[LEGACY[key]] ~= nil then vim.g[key] = vim.g[LEGACY[key]] end
  return vim.g[key]
end

return M
