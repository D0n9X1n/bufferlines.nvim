-- Fixed pre->post rename map, applied to identifier positions only: tabline %#Group# and v:lua click
-- tokens, hls/mhls keys, extmark hl_group, derived hl_group. Never to colours or displayed text.
local M = {}
local function id(s) return (s:gsub("^BufferLine(%u)", "BufferLines%1")) end
local function line(s)
  return (s:gsub("___bufferline_private%.", "___bufferlines_private."):gsub("%%#BufferLine(%u)", "%%#BufferLines%1"))
end
function M.normalise(rec)
  local out = vim.deepcopy(rec)
  if type(out.tabline) == "string" then out.tabline = line(out.tabline) end
  for _, key in ipairs({ "hls", "mhls" }) do
    if type(out[key]) == "table" then local h = {} for k, v in pairs(out[key]) do h[id(k)] = v end out[key] = h end
  end
  for _, m in ipairs(type(out.marks) == "table" and out.marks or {}) do if type(m[4]) == "string" then m[4] = id(m[4]) end end
  for _, spec in pairs(type(out.derived) == "table" and out.derived or {}) do
    if type(spec.hl_group) == "string" then spec.hl_group = id(spec.hl_group) end
  end
  return out
end
return M
