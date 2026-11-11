local lazy = require("bufferlines.lazy")
local ui = lazy.require("bufferlines.ui") ---@module "bufferlines.ui"
local groups = lazy.require("bufferlines.groups") ---@module "bufferlines.groups"
local config = lazy.require("bufferlines.config") ---@module "bufferlines.config"
local utils = lazy.require("bufferlines.utils") ---@module "bufferlines.utils"
local pick = require("bufferlines.pick") ---@module "bufferlines.pick"
local duplicates = require("bufferlines.duplicates") ---@module "bufferlines.duplicates"
local diagnostics = require("bufferlines.diagnostics") ---@module "bufferlines.diagnostics"
local models = require("bufferlines.models") ---@module "bufferlines.models"

local M = {}

local api = vim.api

--- sorts buf_names in place, but doesn't add/remove any values
--- @param buf_nums number[]
--- @param sorted number[]
--- @return number[]
local function get_updated_buffers(buf_nums, sorted)
  if not sorted then return buf_nums end
  local nums = { unpack(buf_nums) }
  local reverse_lookup_sorted = utils.tbl_reverse_lookup(sorted)

  --- a comparator that sorts buffers by their position in sorted
  local sort_by_sorted = function(buf_id_1, buf_id_2)
    local buf_1_rank = reverse_lookup_sorted[buf_id_1]
    local buf_2_rank = reverse_lookup_sorted[buf_id_2]
    if not buf_1_rank then return false end
    if not buf_2_rank then return true end
    return buf_1_rank < buf_2_rank
  end
  table.sort(nums, sort_by_sorted)
  return nums
end

---Return a list of the buffers open in nvim as Components
---@param state bufferlines.State
---@return bufferlines.Buffer[]
function M.get_components(state)
  local options = config.options
  local buf_nums = utils.get_valid_buffers()
  local filter = options.custom_filter
  buf_nums = filter and utils.apply_buffer_filter(buf_nums, filter, "buffers") or buf_nums
  buf_nums = get_updated_buffers(buf_nums, state.custom_sort)

  pick.reset()
  duplicates.reset()
  ---@type bufferlines.Buffer[]
  local components = {}
  local all_diagnostics = diagnostics.get(options)
  local Buffer = models.Buffer
  for i, buf_id in ipairs(buf_nums) do
    local buf = Buffer:new({
      path = api.nvim_buf_get_name(buf_id),
      id = buf_id,
      ordinal = i,
      diagnostics = all_diagnostics[buf_id],
      name_formatter = options.name_formatter,
    })
    buf.letter = pick.get(buf)
    buf.group = groups.set_id(buf)
    components[i] = buf
  end

  return vim.tbl_map(function(buf) return ui.element(state, buf) end, duplicates.mark(components))
end

return M
