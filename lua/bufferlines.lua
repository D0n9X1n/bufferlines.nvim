local lazy = require("bufferlines.lazy")
local ui = lazy.require("bufferlines.ui") ---@module "bufferlines.ui"
local utils = lazy.require("bufferlines.utils") ---@module "bufferlines.utils"
local state = lazy.require("bufferlines.state") ---@module "bufferlines.state"
local groups = lazy.require("bufferlines.groups") ---@module "bufferlines.groups"
local config = lazy.require("bufferlines.config") ---@module "bufferlines.config"
local sorters = lazy.require("bufferlines.sorters") ---@module "bufferlines.sorters"
local buffers = lazy.require("bufferlines.buffers") ---@module "bufferlines.buffers"
local commands = lazy.require("bufferlines.commands") ---@module "bufferlines.commands"
local tabpages = lazy.require("bufferlines.tabpages") ---@module "bufferlines.tabpages"
local highlights = lazy.require("bufferlines.highlights") ---@module "bufferlines.highlights"
local hover = lazy.require("bufferlines.hover") ---@module "bufferlines.hover"

-- @v:lua@ in the tabline only supports global functions, so this is
-- the only way to add click handlers without autoloaded vimscript functions
_G.___bufferlines_private = _G.___bufferlines_private or {} -- to guard against reloads

local api = vim.api

-----------------------------------------------------------------------------//
--- API values
-----------------------------------------------------------------------------//
local M = {
  move = commands.move,
  move_to = commands.move_to,
  exec = commands.exec,
  go_to = commands.go_to,
  cycle = commands.cycle,
  sort_by = commands.sort_by,
  pick = commands.pick,
  get_elements = commands.get_elements,
  close_with_pick = commands.close_with_pick,
  close_in_direction = commands.close_in_direction,
  rename_tab = commands.rename_tab,
  close_others = commands.close_others,
  unpin_and_close = commands.unpin_and_close,

  style_preset = config.STYLE_PRESETS,

  groups = groups,
}
-----------------------------------------------------------------------------//

function M.compute()
  local is_tabline = config:is_tabline()
  local components = is_tabline and tabpages.get_components(state) or buffers.get_components(state)

  -- NOTE: keep track of the previous state so it can be used for sorting
  -- specifically to position newly opened buffers next to the buffer that was previously open
  local prev_idx, prev_components = state.current_element_index, state.components

  local function sorter(list)
    return sorters.sort(list, {
      current_index = prev_idx,
      prev_components = prev_components,
      custom_sort = state.custom_sort,
    })
  end

  local _, current_idx = utils.find(function(component) return component:current() end, components)

  state.set({ current_element_index = current_idx })
  components = not is_tabline and groups.render(components, sorter) or sorter(components)
  state.set({ __components = components, components = components })
  return components
end

--- @return string, bufferlines.Segment[][]
local function bufferlines()
  local tabline = ui.tabline(M.compute(), tabpages.get())
  state.set({
    visible_components = tabline.visible_components,
    --- size data stored for use elsewhere e.g. hover positioning
    left_offset_size = tabline.left_offset_size,
    right_offset_size = tabline.right_offset_size,
  })
  return tabline.str, tabline.segments
end

--- If the item count has changed and the next tabline status is different then update it
local function toggle_bufferline(saved)
  local runtime = package.loaded["bufferlines.multiline.runtime"]
  if runtime and runtime.selected() then
    vim.o.showtabline = 0
    return
  end
  if not config.options.auto_toggle_bufferline then
    if saved ~= nil then vim.o.showtabline = saved end
    return
  end
  local item_count = config:is_tabline() and utils.get_tab_count() or utils.get_buf_count()
  local status = (config.options.always_show_bufferline or item_count > 1) and 2 or 0
  if vim.o.showtabline ~= status then vim.o.showtabline = status end
end

---@private
function _G.nvim_bufferlines()
  local runtime = package.loaded["bufferlines.multiline.runtime"]
  if runtime and runtime.selected() then return "", {} end
  toggle_bufferline() -- Always populate state regardless of if tabline status is less than 2 #352
  return bufferlines()
end

local function multiline_frame(width, max_rows, viewport)
  local components = M.compute()
  local visible = {}
  for _, component in ipairs(components) do
    if not component.hidden then visible[#visible + 1] = component end
  end
  local entries = {}
  for index, component in ipairs(visible) do
    entries[#entries + 1] = ui.multiline_entry(component, component.component(visible[index + 1]))
  end
  local frame = require("bufferlines.multiline.layout").plan(entries, {
    width = width,
    max_rows = max_rows,
    fill_hl = config.highlights.fill.hl_group,
    marker_hl = config.highlights.trunc_marker.hl_group,
  }, viewport)
  state.set({
    visible_components = frame.visible_components or {},
    left_offset_size = 0,
    right_offset_size = 0,
  })
  return frame
end

---@param conf bufferlines.Config
local function setup_autocommands(conf)
  local BUFFERLINE_GROUP = "BufferlinesCmds"
  local options = conf.options
  api.nvim_create_augroup(BUFFERLINE_GROUP, { clear = true })
  api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    group = BUFFERLINE_GROUP,
    callback = function()
      highlights.reset_icon_hl_cache()
      highlights.set_all(config.update_highlights())
      ui.refresh()
    end,
  })
  if not options or vim.tbl_isempty(options) then return end
  if options.persist_buffer_sort then
    api.nvim_create_autocmd("SessionLoadPost", {
      pattern = "*",
      group = BUFFERLINE_GROUP,
      callback = function() state.custom_sort = utils.restore_positions() end,
    })
  end
  if not options.always_show_bufferline then
    -- toggle tabline
    api.nvim_create_autocmd({ "BufAdd", "TabEnter" }, {
      pattern = "*",
      group = BUFFERLINE_GROUP,
      callback = function() toggle_bufferline() end,
    })
  end

  api.nvim_create_autocmd("BufRead", {
    pattern = "*",
    group = BUFFERLINE_GROUP,
    once = true,
    callback = function() vim.schedule(groups.handle_group_enter) end,
  })

  api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    group = BUFFERLINE_GROUP,
    callback = function() groups.handle_group_enter() end,
  })

  api.nvim_create_autocmd("User", {
    group = BUFFERLINE_GROUP,
    pattern = "BufferLinesHoverOver",
    callback = function(args) ui.on_hover_over(args.buf, args.data) end,
  })

  api.nvim_create_autocmd("User", {
    group = BUFFERLINE_GROUP,
    pattern = "BufferLinesHoverOut",
    callback = ui.on_hover_out,
  })
end

local function command(name, cmd, opts) api.nvim_create_user_command(name, cmd, opts or {}) end

local function setup_commands()
  command("BufferLinesPick", function() M.pick() end)
  command("BufferLinesPickClose", function() M.close_with_pick() end)
  command("BufferLinesCycleNext", function() M.cycle(1) end)
  command("BufferLinesCyclePrev", function() M.cycle(-1) end)
  command("BufferLinesCloseRight", function() M.close_in_direction("right") end)
  command("BufferLinesCloseLeft", function() M.close_in_direction("left") end)
  command("BufferLinesCloseOthers", function() M.close_others() end)
  command("BufferLinesMoveNext", function() M.move(1) end)
  command("BufferLinesMovePrev", function() M.move(-1) end)
  command("BufferLinesSortByExtension", function() M.sort_by("extension") end)
  command("BufferLinesSortByDirectory", function() M.sort_by("directory") end)
  command("BufferLinesSortByRelativeDirectory", function() M.sort_by("relative_directory") end)
  command("BufferLinesSortByTabs", function() M.sort_by("tabs") end)
  command("BufferLinesGoToBuffer", function(opts) M.go_to(opts.args) end, { nargs = 1 })
  command("BufferLinesTogglePin", function() groups.toggle_pin() end, { nargs = 0 })
  command("BufferLinesTabRename", function(opts) M.rename_tab(opts.fargs) end, { nargs = "*" })
  command("BufferLinesGroupClose", function(opts) groups.action(opts.args, "close") end, {
    nargs = 1,
    complete = groups.complete,
  })
  command("BufferLinesGroupToggle", function(opts) groups.action(opts.args, "toggle") end, {
    nargs = 1,
    complete = groups.complete,
  })
end

local function setup_diagnostic_handler(preferences)
  if preferences.options.diagnostics == "nvim_lsp" and preferences.options.diagnostics_update_on_event then
    vim.diagnostic.handlers["bufferlines"] = {
      show = function() ui.refresh() end,
      hide = function() ui.refresh() end,
    }
  end
end

---@param conf bufferlines.UserConfig?
function M.setup(conf)
  conf = require("bufferlines.multiline.options").normalize(conf)
  local runtime = package.loaded["bufferlines.multiline.runtime"]
  if runtime then runtime.disable() end
  config.setup(conf)
  groups.setup(conf) -- Groups must be set up before the config is applied
  local preferences = config.apply()
  -- on loading (and reloading) the plugin's config reset all the highlights
  highlights.set_all(preferences)
  hover.setup(preferences)
  setup_commands()
  setup_autocommands(preferences)
  setup_diagnostic_handler(preferences)
  vim.o.tabline = "%!v:lua.nvim_bufferlines()"
  if preferences.options.multiline and preferences.options.multiline.enabled then
    require("bufferlines.multiline.runtime").enable(preferences.options, {
      frame = multiline_frame,
      native_visibility = toggle_bufferline,
      dispatch = commands.dispatch,
    })
  else
    toggle_bufferline()
  end
end

return M
