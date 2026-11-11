-- Deterministic golden capture: fixed palettes, ASCII icons, fixed geometry.
local api = vim.api
local M = {}
local common = { WinSeparator = { fg = "#343d46" }, Directory = { fg = "#6699cc" }, WildMenu = { fg = "#fac863" } }
M.PALETTES = {
  dark = vim.tbl_extend("force", common, { background = "dark", Normal = { fg = "#c0c5ce", bg = "#1b1f27" },
    Comment = { fg = "#65737e" }, String = { fg = "#99c794" }, TabLine = { fg = "#a7adba", bg = "#2b303b" },
    TabLineSel = { fg = "#ffffff", bg = "#4f5b66" }, DiagnosticError = { fg = "#ec5f67" }, DiagnosticWarn = { fg = "#fac863" },
    DiagnosticInfo = { fg = "#6699cc" }, DiagnosticHint = { fg = "#5fb3b3" } }),
  light = vim.tbl_extend("force", common, { background = "light", Normal = { fg = "#383a42", bg = "#fafafa" },
    Comment = { fg = "#a0a1a7" }, String = { fg = "#50a14f" }, TabLine = { fg = "#696c77", bg = "#e5e5e6" },
    TabLineSel = { fg = "#000000", bg = "#d0d0d0" }, DiagnosticError = { fg = "#e45649" }, DiagnosticWarn = { fg = "#c18401" },
    DiagnosticInfo = { fg = "#4078f2" }, DiagnosticHint = { fg = "#0184bc" } }),
}
-- Fallback palettes: TabLineSel colours that collide with Normal.bg, and a scheme missing source groups.
M.PALETTES.sel_bg_match = vim.tbl_extend("force", M.PALETTES.dark, { TabLineSel = { fg = "#ffffff", bg = "#1b1f27" } })
M.PALETTES.sel_both_match = vim.tbl_extend("force", M.PALETTES.dark, { TabLineSel = { fg = "#1b1f27", bg = "#1b1f27" } })
M.PALETTES.sparse = { background = "dark", Normal = { fg = "#c0c5ce", bg = "#1b1f27" }, Directory = { fg = "#6699cc" },
  WildMenu = { fg = "#fac863" }, VertSplit = { fg = "#343d46" }, Error = { fg = "#ec5f67" }, WarningMsg = { fg = "#fac863" } }
M.FALLBACK_PALETTES = { "sel_bg_match", "sel_both_match", "sparse" }
function M.apply_palette(name)
  local p = M.PALETTES[name]
  vim.o.termguicolors, vim.o.background = true, p.background
  vim.cmd("highlight clear")
  for group, attrs in pairs(p) do if group ~= "background" then api.nvim_set_hl(0, group, attrs) end end
end
function M.pin_icons()
  local ok, d = pcall(require, "nvim-web-devicons")
  if not ok then return end
  d.setup({ default = true, override_by_extension = {
    lua = { icon = "L", color = "#51a0cf", name = "GoldenLua" }, txt = { icon = "T", color = "#89e051", name = "GoldenTxt" } } })
  d.set_default_icon("D", "#6d8086", 66)
  pcall(d.set_up_highlights, true)
end
function M.reset()
  local rt = package.loaded["bufferlines.multiline.runtime"]
  if rt then pcall(rt.disable) end
  vim.cmd("silent! tabonly | silent! only | silent! %bwipeout!")
end
local function open(names) for _, n in ipairs(names) do vim.cmd.edit(n) end end
local three = function() open({ "golden-1.txt", "golden-2.txt", "golden-3.txt" }) end
M.BASE = { show_buffer_icons = false, persist_buffer_sort = false, always_show_bufferline = true }
-- Append-only: buffer numbers in click tokens depend on fixture order.
M.FIXTURES = {
  { name = "default", setup = three },
  { name = "slant", options = { separator_style = "slant" }, setup = three },
  { name = "slope", options = { separator_style = "slope" }, setup = three },
  { name = "thin", options = { separator_style = "thin" }, setup = three },
  { name = "numbers", options = { numbers = "ordinal", custom_areas = { right = function() return { { text = " R ", fg = "#ff0000" } } end } },
    setup = function() open({ "golden-1.txt", "a-very-long-golden-file-name-to-truncate.txt" }) end },
  { name = "diagnostics", options = { diagnostics = "nvim_lsp" }, setup = function()
      three()
      vim.diagnostic.set(api.nvim_create_namespace("golden"), vim.fn.bufnr("golden-1.txt"),
        { { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "golden" } })
    end },
  { name = "groups", options = { groups = { items = { { name = "Docs", highlight = { fg = "#d08770", underline = true }, matcher = function(b) return b.name:match("%.md$") ~= nil end } } } },
    setup = function() open({ "golden-1.txt", "golden-notes.md", "golden-2.txt" }) end }, -- no repo file shares this name (case-insensitive FS)
  { name = "sidebar", options = { offsets = { { filetype = "golden-tree", text = "Tree", separator = true } } }, setup = function()
      three(); vim.cmd("topleft 20vnew"); vim.bo.buflisted, vim.bo.filetype = false, "golden-tree"; vim.cmd("wincmd l")
    end },
  { name = "overflow", setup = function() for i = 1, 30 do vim.cmd.edit(("golden-%02d.txt"):format(i)) end end },
  { name = "tabpages", multiline = false, options = { mode = "tabs" }, setup = function()
      three(); vim.cmd("tabnew golden-4.txt | tabnew golden-5.txt | tabfirst")
    end },
  { name = "icon", options = { show_buffer_icons = true }, setup = function() open({ "init.lua", "notes.txt", "plain" }) end },
  -- buffer mode with several tabpages: native %NT tab targets (tab indicators are off in mode=tabs, config.lua:723)
  { name = "tabindicators", setup = function()
      three(); vim.cmd("tabnew golden-4.txt | tabnew golden-5.txt | tabfirst")
    end },
}
local function fresh()
  for k in pairs(package.loaded) do if k:match("^bufferlines") then package.loaded[k] = nil end end
  return require("bufferlines")
end
local function hl(g) return api.nvim_get_hl(0, { name = g, link = false }) end -- what compat.get_hl returns on 0.12
function M.capture(fx, palette)
  M.reset(); M.apply_palette(palette); M.pin_icons()
  local opts = vim.tbl_deep_extend("force", M.BASE, fx.options or {})
  local bl = fresh(); bl.setup({ options = opts }); fx.setup()
  local rec = { tabline = (_G.nvim_bufferlines()), hls = {} }
  for g in rec.tabline:gmatch("%%#([%w_]+)#") do rec.hls[g] = hl(g) end
  if fx.multiline ~= false then
    local mopts = vim.tbl_deep_extend("force", opts, { multiline = { enabled = true, max_rows = 3 } })
    mopts.custom_areas = nil -- multiline rejects custom_areas (multiline/options.lua:28-31); the native capture keeps them
    bl.setup({ options = mopts })
    local rt = require("bufferlines.multiline.runtime"); rt.flush("golden")
    local h = rt.handles()[api.nvim_get_current_tabpage()]
    if h then
      local ns = api.nvim_get_namespaces()["bufferlines.multiline.runtime"]
      rec.lines, rec.marks, rec.mhls = api.nvim_buf_get_lines(h.buf, 0, -1, false), {}, {} -- multiline attrs kept apart from native
      for _, m in ipairs(api.nvim_buf_get_extmarks(h.buf, ns, 0, -1, { details = true })) do
        rec.marks[#rec.marks + 1] = { m[2], m[3], m[4].end_col, m[4].hl_group, m[4].priority }
        if m[4].hl_group then rec.mhls[m[4].hl_group] = hl(m[4].hl_group) end
      end
    else rec.lines = "unavailable" end
    rt.disable()
  end
  return rec
end
M.DERIVED = { { "default", { 1 } }, { "minimal", { 2 } }, { "no_bold", { 3 } }, { "no_italic", { 4 } }, { "minimal_plain", { 2, 3, 4 } } }
function M.derived(preset, palette, indicator)
  M.reset(); M.apply_palette(palette)
  fresh().setup({ options = { style_preset = preset, indicator = { style = indicator } } })
  return vim.deepcopy(require("bufferlines.config").highlights)
end
return M
