-- Declarative default highlights: SOURCES (scheme lookups) -> context (derived shades) -> GROUPS (attributes).
local lazy = require("bufferlines.lazy")
local colors = lazy.require("bufferlines.colors") ---@module "bufferlines.colors"
local M = {}
local function diag(name, last)
  return { name = name, attribute = "fg", fallback = { name = name, attribute = "sp", fallback = last } }
end
M.SOURCES = { -- ordered: tabline_sel_bg's not_match reads normal_bg
  { "comment_fg", { name = "Comment", attribute = "fg", fallback = { name = "Normal", attribute = "fg" } } },
  { "normal_fg", { name = "Normal", attribute = "fg" } },
  { "normal_bg", { name = "Normal", attribute = "bg" } },
  { "string_fg", { name = "String", attribute = "fg" } },
  { "error_fg", diag("DiagnosticError", { name = "Error", attribute = "fg" }) },
  { "warning_fg", diag("DiagnosticWarn", { name = "WarningMsg", attribute = "fg" }) },
  { "info_fg", diag("DiagnosticInfo", { name = "Normal", attribute = "fg" }) },
  { "hint_fg", diag("DiagnosticHint", { name = "Directory", attribute = "fg" }) },
  {
    "tabline_sel_bg",
    {
      name = "TabLineSel",
      attribute = "bg",
      not_match = "normal_bg",
      fallback = {
        name = "TabLineSel",
        attribute = "fg",
        not_match = "normal_bg",
        fallback = { name = "WildMenu", attribute = "fg" },
      },
    },
  },
  {
    "win_separator_fg",
    { name = "WinSeparator", attribute = "fg", fallback = { name = "VertSplit", attribute = "fg" } },
  },
}
local function bind(spec, ctx)
  if not spec then return nil end
  local out = vim.deepcopy(spec)
  if out.not_match then out.not_match = ctx[out.not_match] end
  out.fallback = bind(spec.fallback, ctx)
  return out
end
---@param flags {is_minimal: boolean, italic: boolean, bold: boolean, indicator_style: string?}
---@return table<string, any>
function M.context(flags)
  local hex, tint = colors.get_color, colors.shade_color
  local c = { is_minimal = flags.is_minimal, italic = flags.italic, bold = flags.bold }
  for _, s in ipairs(M.SOURCES) do
    c[s[1]] = hex(bind(s[2], c))
  end
  local bright = colors.color_is_bright(c.normal_bg)
  local sep, bg, diag_shade = bright and -20 or -45, bright and -12 or -25, bright and -12 or -25
  c.duplicate_color = tint(c.comment_fg, -5)
  c.visible_bg = c.is_minimal and c.normal_bg or tint(c.normal_bg, -8)
  c.visible_fg = c.is_minimal and tint(c.normal_fg, -30) or c.comment_fg
  c.separator_background_color = c.is_minimal and c.normal_bg or tint(c.normal_bg, sep)
  c.background_color = c.is_minimal and c.normal_bg or tint(c.normal_bg, bg)
  for _, k in ipairs({ "normal", "comment", "hint", "info", "warning", "error" }) do
    c[k .. "_diagnostic_fg"] = tint(c[k .. "_fg"], diag_shade)
  end
  c.has_underline_indicator = flags.indicator_style == "underline"
  c.underline_sp = c.has_underline_indicator and c.tabline_sel_bg or nil
  c.trunc_marker_fg, c.trunc_marker_bg = c.comment_fg, c.separator_background_color
  return c
end
M.GROUPS = {
  trunc_marker = {
    fg = "trunc_marker_fg",
    bg = "trunc_marker_bg",
  },
  fill = {
    fg = "comment_fg",
    bg = "separator_background_color",
  },
  group_separator = {
    fg = "comment_fg",
    bg = "separator_background_color",
  },
  group_label = {
    bg = "comment_fg",
    fg = "separator_background_color",
  },
  tab = {
    fg = "comment_fg",
    bg = "background_color",
  },
  tab_selected = {
    fg = "tabline_sel_bg",
    bg = "normal_bg",
    sp = "underline_sp",
    bold = { "and", "is_minimal", "bold" },
    underline = "has_underline_indicator",
  },
  tab_close = {
    fg = "comment_fg",
    bg = "background_color",
  },
  close_button = {
    fg = "comment_fg",
    bg = "background_color",
  },
  close_button_visible = {
    fg = "visible_fg",
    bg = "visible_bg",
  },
  close_button_selected = {
    fg = "normal_fg",
    bg = "normal_bg",
    sp = "underline_sp",
    underline = "has_underline_indicator",
  },
  background = {
    fg = "comment_fg",
    bg = "background_color",
  },
  buffer = {
    fg = "comment_fg",
    bg = "background_color",
  },
  buffer_visible = {
    fg = "visible_fg",
    bg = "visible_bg",
    italic = { "and", "is_minimal", "italic" },
    bold = { "and", "is_minimal", "bold" },
  },
  buffer_selected = {
    fg = "normal_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    sp = "underline_sp",
    underline = "has_underline_indicator",
  },
  numbers = {
    fg = "comment_fg",
    bg = "background_color",
  },
  numbers_selected = {
    fg = "normal_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    sp = "underline_sp",
    underline = "has_underline_indicator",
  },
  numbers_visible = {
    fg = "visible_fg",
    bg = "visible_bg",
  },
  diagnostic = {
    fg = "comment_diagnostic_fg",
    bg = "background_color",
  },
  diagnostic_visible = {
    fg = "comment_diagnostic_fg",
    bg = "visible_bg",
  },
  diagnostic_selected = {
    fg = "normal_diagnostic_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    sp = "underline_sp",
    underline = "has_underline_indicator",
  },
  hint = {
    fg = "comment_fg",
    sp = "hint_fg",
    bg = "background_color",
  },
  hint_visible = {
    fg = "visible_fg",
    bg = "visible_bg",
    italic = { "and", "is_minimal", "italic" },
    bold = { "and", "is_minimal", "bold" },
  },
  hint_selected = {
    fg = "hint_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    underline = "has_underline_indicator",
    sp = { "or", "underline_sp", "hint_fg" },
  },
  hint_diagnostic = {
    fg = "comment_diagnostic_fg",
    sp = "hint_diagnostic_fg",
    bg = "background_color",
  },
  hint_diagnostic_visible = {
    fg = "comment_diagnostic_fg",
    bg = "visible_bg",
  },
  hint_diagnostic_selected = {
    fg = "hint_diagnostic_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    underline = "has_underline_indicator",
    sp = { "or", "underline_sp", "hint_diagnostic_fg" },
  },
  info = {
    fg = "comment_fg",
    sp = "info_fg",
    bg = "background_color",
  },
  info_visible = {
    fg = "visible_fg",
    bg = "visible_bg",
    italic = { "and", "is_minimal", "italic" },
    bold = { "and", "is_minimal", "bold" },
  },
  info_selected = {
    fg = "info_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    underline = "has_underline_indicator",
    sp = { "or", "underline_sp", "info_fg" },
  },
  info_diagnostic = {
    fg = "comment_diagnostic_fg",
    sp = "info_diagnostic_fg",
    bg = "background_color",
  },
  info_diagnostic_visible = {
    fg = "comment_diagnostic_fg",
    bg = "visible_bg",
  },
  info_diagnostic_selected = {
    fg = "info_diagnostic_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    underline = "has_underline_indicator",
    sp = { "or", "underline_sp", "info_diagnostic_fg" },
  },
  warning = {
    fg = "comment_fg",
    sp = "warning_fg",
    bg = "background_color",
  },
  warning_visible = {
    fg = "visible_fg",
    bg = "visible_bg",
    italic = { "and", "is_minimal", "italic" },
    bold = { "and", "is_minimal", "bold" },
  },
  warning_selected = {
    fg = "warning_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    underline = "has_underline_indicator",
    sp = { "or", "underline_sp", "warning_fg" },
  },
  warning_diagnostic = {
    fg = "comment_diagnostic_fg",
    sp = "warning_diagnostic_fg",
    bg = "background_color",
  },
  warning_diagnostic_visible = {
    fg = "comment_diagnostic_fg",
    bg = "visible_bg",
  },
  warning_diagnostic_selected = {
    fg = "warning_diagnostic_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    underline = "has_underline_indicator",
    sp = { "or", "underline_sp", "warning_diagnostic_fg" },
  },
  error = {
    fg = "comment_fg",
    bg = "background_color",
    sp = "error_fg",
  },
  error_visible = {
    fg = "visible_fg",
    bg = "visible_bg",
    italic = { "and", "is_minimal", "italic" },
    bold = { "and", "is_minimal", "bold" },
  },
  error_selected = {
    fg = "error_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    underline = "has_underline_indicator",
    sp = { "or", "underline_sp", "error_fg" },
  },
  error_diagnostic = {
    fg = "comment_diagnostic_fg",
    bg = "background_color",
    sp = "error_diagnostic_fg",
  },
  error_diagnostic_visible = {
    fg = "comment_diagnostic_fg",
    bg = "visible_bg",
  },
  error_diagnostic_selected = {
    fg = "error_diagnostic_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    underline = "has_underline_indicator",
    sp = { "or", "underline_sp", "error_diagnostic_fg" },
  },
  modified = {
    fg = "string_fg",
    bg = "background_color",
  },
  modified_visible = {
    fg = "string_fg",
    bg = "visible_bg",
  },
  modified_selected = {
    fg = "string_fg",
    bg = "normal_bg",
    sp = "underline_sp",
    underline = "has_underline_indicator",
  },
  duplicate_selected = {
    fg = "duplicate_color",
    italic = "italic",
    bg = "normal_bg",
    sp = "underline_sp",
    underline = "has_underline_indicator",
  },
  duplicate_visible = {
    fg = "duplicate_color",
    italic = "italic",
    bg = "visible_bg",
  },
  duplicate = {
    fg = "duplicate_color",
    italic = "italic",
    bg = "background_color",
  },
  separator_selected = {
    fg = "separator_background_color",
    bg = "normal_bg",
    sp = "underline_sp",
    underline = "has_underline_indicator",
  },
  separator_visible = {
    fg = "separator_background_color",
    bg = "visible_bg",
  },
  separator = {
    fg = "separator_background_color",
    bg = "background_color",
  },
  tab_separator = {
    fg = "separator_background_color",
    bg = "background_color",
  },
  tab_separator_selected = {
    fg = "separator_background_color",
    bg = "normal_bg",
    sp = "underline_sp",
    underline = "has_underline_indicator",
  },
  indicator_selected = {
    fg = "tabline_sel_bg",
    bg = "normal_bg",
    sp = "underline_sp",
    underline = "has_underline_indicator",
  },
  indicator_visible = {
    fg = "visible_bg",
    bg = "visible_bg",
  },
  pick_selected = {
    fg = "error_fg",
    bg = "normal_bg",
    bold = "bold",
    italic = "italic",
    sp = "underline_sp",
    underline = "has_underline_indicator",
  },
  pick_visible = {
    fg = "error_fg",
    bg = "visible_bg",
    bold = "bold",
    italic = "italic",
  },
  pick = {
    fg = "error_fg",
    bg = "background_color",
    bold = "bold",
    italic = "italic",
  },
  offset_separator = {
    fg = "win_separator_fg",
    bg = "separator_background_color",
  },
}

local function value(expr, c)
  if type(expr) == "string" then return c[expr] end
  if type(expr) ~= "table" then return expr end
  local a, b = c[expr[2]], c[expr[3]]
  if expr[1] == "and" then return a and b end
  return a or b
end
---@param groups table<string, table<string, any>>
---@param c table<string, any>
---@return bufferlines.Highlights
function M.resolve(groups, c)
  local out = {}
  for name, attrs in pairs(groups) do
    local hl = {}
    for attr, expr in pairs(attrs) do
      hl[attr] = value(expr, c)
    end
    out[name] = hl
  end
  return out
end
return M
