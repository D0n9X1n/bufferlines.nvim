local M = {}

local lazy = require("bufferlines.lazy")
local utils = lazy.require("bufferlines.utils") ---@module "bufferlines.utils"

-----------------------------------------------------------------------------//
-- State
-----------------------------------------------------------------------------//

---@type bufferlines.State
local state = {
  is_picking = false,
  hovered = nil,
  custom_sort = nil,
  current_element_index = nil,
  components = {},
  __components = {},
  visible_components = {},
  left_offset_size = 0,
  right_offset_size = 0,
}

---@param list bufferlines.Component[]
---@return bufferlines.Component[]
local function filter_invisible(list)
  return utils.fold(function(accum, item)
    if item.focusable ~= false and not item.hidden then table.insert(accum, item) end
    return accum
  end, list, {})
end

local component_keys = { "components", "visible_components" }

---@param new_state bufferlines.State
function M.set(new_state)
  for key, value in pairs(new_state) do
    if value == vim.NIL then value = nil end
    if vim.tbl_contains(component_keys, key) then
      value = filter_invisible(value --[=[@as bufferlines.Component[]]=])
    end
    state[key] = value
  end
end

return setmetatable(M, {
  __index = function(_, k) return state[k] end,
})
