local M = {}

local api = vim.api
local fmt = string.format
local lazy = require("bufferlines.lazy")
local groups = lazy.require("bufferlines.groups") ---@module "bufferlines.groups"
local utils = lazy.require("bufferlines.utils") ---@module "bufferlines.utils"
local highlights = lazy.require("bufferlines.highlights") ---@module "bufferlines.highlights"
local colors = lazy.require("bufferlines.colors") ---@module "bufferlines.colors"
local constants = lazy.require("bufferlines.constants") ---@module "bufferlines.colors"

---@enum bufferlines.StylePreset
local PRESETS = {
  default = 1,
  minimal = 2,
  no_bold = 3,
  no_italic = 4,
}

---The local class instance of the merged user's configuration
---this includes all default values and highlights filled out
---@type bufferlines.Config
local config = {}

---The class definition for the user configuration
---@type bufferlines.Config
local Config = {}

function Config:new(o)
  assert(o, "User options must be passed in")
  self.__index = self
  -- save a copy of the user's preferences so we can reference exactly what they
  -- wanted after the config and defaults have been merged. Do this using a copy
  -- so that reference isn't unintentionally mutated
  self.user = vim.deepcopy(o)
  setmetatable(o, self)
  return o
end

---Combine user preferences with defaults preferring the user's own settings
---@param defaults bufferlines.Config
---@return bufferlines.Config
function Config:merge(defaults)
  assert(defaults and type(defaults) == "table", "A valid config table must be passed to merge")
  self.options = vim.tbl_deep_extend("force", defaults.options, self.options or {})
  self.highlights = vim.tbl_deep_extend("force", defaults.highlights, self.highlights or {})
  return self
end

---@param options bufferlines.Options
---@return {[string]: table}[]
local function get_offset_highlights(options)
  if not options or not options.offsets then return {} end
  return utils.fold(function(accum, offset, i)
    if offset.highlight and type(offset.highlight) == "table" then accum[fmt("offset_%d", i)] = offset.highlight end
    return accum
  end, options.offsets)
end

---@param options bufferlines.Options
---@return table[]
local function get_group_highlights(options)
  if not options or not options.groups then return {} end
  return utils.fold(function(accum, group)
    if group.highlight then accum[group.name] = group.highlight end
    return accum
  end, options.groups.items)
end

local function validate_user_highlights(opts, defaults, hls)
  if not hls then return end
  local incorrect = { invalid_hl = {} }

  local offset_highlights = get_offset_highlights(opts)
  local group_highlights = get_group_highlights(opts)
  local all_hls = vim.tbl_extend("force", {}, hls, offset_highlights, group_highlights)

  for k, _ in pairs(all_hls) do
    if hls[k] then
      if not defaults.highlights[k] then table.insert(incorrect.invalid_hl, k) end
    end
  end

  -- Don't continue if there are no incorrect highlights
  if next(incorrect.invalid_hl) then
    local is_plural = #incorrect > 1
    local msg = table.concat({
      table.concat(incorrect.invalid_hl, ", "),
      is_plural and " are " or " is ",
      "not",
      is_plural and " " or " a ",
      "valid highlight",
      is_plural and " groups. " or " group. ",
      "Please check :help bufferlines-highlights for all valid highlights",
    })
    utils.notify(msg, "error")
  end
end

--- Check that the user has not placed setting in the wrong tables
---@param conf bufferlines.UserConfig
local function validate_config_structure(conf)
  local invalid = {}
  for key, _ in pairs(conf) do
    if key ~= "options" and key ~= "highlights" then table.insert(invalid, " - " .. key) end
  end
  if next(invalid) then
    utils.notify({
      "All configuration should be inside of the options or highlights table",
      "the following keys are in the wrong place",
      unpack(invalid),
    }, "warn")
  end
end

---Ensure the user has only specified highlight groups that exist
---@param defaults bufferlines.Config
---@param resolved bufferlines.Highlights
function Config:validate(defaults, resolved)
  validate_config_structure(self.user)
  validate_user_highlights(self.user.options, defaults, resolved)
end

function Config:mode()
  if not self.options then return "buffers" end
  return self.options.mode
end

function Config:is_bufferline() return self:mode() == "buffers" end

function Config:is_tabline() return self:mode() == "tabs" end

---Derive the colors for the bufferlines
---@param preset bufferlines.StylePreset | bufferlines.StylePreset[]
---@return bufferlines.Highlights
local function derive_colors(preset)
  if type(preset) ~= "table" then preset = { preset } end
  local palette = require("bufferlines.palette")
  return palette.resolve(
    palette.GROUPS,
    palette.context({
      is_minimal = vim.tbl_contains(preset, PRESETS.minimal),
      italic = not vim.tbl_contains(preset, PRESETS.no_italic),
      bold = not vim.tbl_contains(preset, PRESETS.no_bold),
      indicator_style = vim.tbl_get(config, "user", "options", "indicator", "style"),
    })
  )
end

-- Ideally this plugin should generate a beautiful tabline a little similar
-- to what you would get on other editors. The aim is that the default should
-- be so nice it's what anyone using this plugin sticks with. It should ideally
-- work across any well designed colorscheme deriving colors automagically.
-- Icons from https://fontawesome.com/cheatsheet
---@return bufferlines.Config
local function get_defaults()
  local preset = vim.tbl_get(config, "user", "options", "style_preset") --[[@as bufferlines.StylePreset]]
  ---@type bufferlines.Options
  local opts = {
    mode = "buffers",
    themable = true, -- whether or not bufferlines highlights can be overridden externally
    style_preset = preset,
    numbers = "none",
    buffer_close_icon = "",
    modified_icon = "●",
    close_icon = "",
    close_command = "bdelete! %d",
    left_mouse_command = "buffer %d",
    right_mouse_command = "bdelete! %d",
    middle_mouse_command = nil,
    -- U+2590 ▐ Right half block, this character is right aligned so the
    -- background highlight doesn't appear in the middle
    -- alternatives:  right aligned => ▕ ▐ ,  left aligned => ▍
    indicator = { icon = constants.indicator, style = "icon" },
    left_trunc_marker = "",
    right_trunc_marker = "",
    separator_style = "thin",
    name_formatter = nil,
    truncate_names = true,
    tab_size = 18,
    max_name_length = 18,
    color_icons = true,
    show_buffer_icons = true,
    show_buffer_close_icons = true,
    get_element_icon = nil,
    show_close_icon = true,
    show_tab_indicators = true,
    show_duplicate_prefix = true,
    duplicates_across_groups = true,
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    auto_toggle_bufferline = true,
    persist_buffer_sort = true,
    move_wraps_at_ends = false,
    max_prefix_length = 15,
    sort_by = "id",
    diagnostics = false,
    diagnostics_indicator = nil,
    diagnostics_update_in_insert = true,
    diagnostics_update_on_event = true,
    offsets = {},
    groups = { items = {}, options = { toggle_hidden_on_enter = true } },
    hover = { enabled = false, reveal = {}, delay = 200 },
    debug = { logging = false },
    pick = {
      alphabet = "abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890",
    },
  }
  return { options = opts, highlights = derive_colors(opts.style_preset) }
end

--- Convert highlights specified as tables to the correct existing colours
---@param map bufferlines.Highlights
local function resolve_user_highlight_links(map)
  if not map or vim.tbl_isempty(map) then return {} end
  -- we deep copy the highlights table as assigning the attributes
  -- will only pass the references so will mutate the original table otherwise
  local updated = vim.deepcopy(map)
  for hl, attributes in pairs(map) do
    for attribute, value in pairs(attributes) do
      if type(value) == "table" then
        if value.highlight and value.attribute then
          updated[hl][attribute] = colors.get_color({
            name = value.highlight,
            attribute = value.attribute,
            cterm = attribute:match("cterm") ~= nil,
          })
        else
          updated[hl][attribute] = nil
          utils.notify(fmt("removing %s as it is not formatted correctly", hl), "warn")
        end
      end
    end
  end
  return updated
end

--- Resolve (and update) any incompatible options based on the values of other options
--- e.g. in tabline only certain values are valid/certain options no longer make sense.
function Config:resolve(defaults)
  local user, hl = self.user.highlights, self.highlights
  if type(user) == "function" then hl = user(defaults) end
  self.highlights = resolve_user_highlight_links(hl)

  local indicator_icon = vim.tbl_get(self, "options", "indicator_icon")
  if indicator_icon then self.options.indicator = { icon = indicator_icon, style = "icon" } end

  if self:is_tabline() then
    local opts = defaults.options
    opts.sort_by = "tabs"
    if opts.show_tab_indicators then opts.show_tab_indicators = false end
    opts.close_command = utils.close_tab
    opts.right_mouse_command = "tabclose %d"
    opts.left_mouse_command = api.nvim_set_current_tabpage
  end
  return hl
end

---Generate highlight groups from user
---@param map {[string]: {fg: string, bg: string}}
--- TODO: can this become part of a metatable for each highlight group so it is done at the point
---of usage
local function set_highlight_names(map)
  for name, opts in pairs(map) do
    opts.hl_group = highlights.generate_name(name)
  end
end

---Add highlight groups for a group
---@param hls bufferlines.Highlights
local function set_group_highlights(hls)
  for _, group in pairs(groups.get_all()) do
    local group_hl, name = group.highlight, group.name
    if group_hl and type(group_hl) == "table" then
      local sep_name = fmt("%s_separator", name)
      local label_name = fmt("%s_label", name)
      local selected_name = fmt("%s_selected", name)
      local visible_name = fmt("%s_visible", name)
      hls[sep_name] = {
        fg = group_hl.fg or group_hl.sp or hls.group_separator.fg,
        bg = hls.fill.bg,
      }
      hls[label_name] = {
        fg = hls.fill.bg,
        bg = group_hl.fg or group_hl.sp or hls.group_separator.fg,
      }

      hls[name] = vim.tbl_extend("keep", group_hl, hls.buffer)
      hls[visible_name] = vim.tbl_extend("keep", group_hl, hls.buffer_visible)
      hls[selected_name] = vim.tbl_extend("keep", group_hl, hls.buffer_selected)

      hls[name].hl_group = highlights.generate_name(name)
      hls[sep_name].hl_group = highlights.generate_name(sep_name)
      hls[label_name].hl_group = highlights.generate_name(label_name)
      hls[visible_name].hl_group = highlights.generate_name(visible_name)
      hls[selected_name].hl_group = highlights.generate_name(selected_name)
    end
  end
end

--- Merge user config with defaults
--- @param quiet boolean? whether or not to validate the configuration
--- @return bufferlines.Config
function M.apply(quiet)
  local defaults = get_defaults()
  local resolved = config:resolve(defaults)
  if not quiet then config:validate(defaults, resolved) end
  config:merge(defaults)
  set_highlight_names(config.highlights)
  set_group_highlights(config.highlights)
  return config
end

---Keep track of a users config for use throughout the plugin as well as ensuring
---defaults are set. This is also so we can diff what the user set this is useful
---for setting the highlight groups etc. once this has been merged with the defaults
---@param c bufferlines.UserConfig?
function M.setup(c) config = Config:new(c or {}) end

---Update highlight colours when the colour scheme changes by resetting the user config
---to what was initially passed in and reload the highlighting
function M.update_highlights()
  M.setup(config.user)
  M.apply(true)
  return config
end

---Get the user's configuration or a key from it
---@return bufferlines.Config?
function M.get()
  if config then return config end
end

if _G.__TEST then
  function M.__reset() config = nil end
end

M.STYLE_PRESETS = PRESETS

return setmetatable(M, {
  __index = function(_, k) return config[k] end,
})
