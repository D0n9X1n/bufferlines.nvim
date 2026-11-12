-- Preview scenes for README and wiki screenshots.
-- Env: PREVIEW_SCENE (a key of SCENES), PREVIEW_READY (file written once the frame is final).
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
vim.opt.rtp:prepend(root)
vim.opt.rtp:append(vim.env.NVIM_TEST_DEPS .. "/nvim-web-devicons")
vim.o.termguicolors = true
vim.o.showmode, vim.o.ruler, vim.o.laststatus, vim.o.shortmess = false, false, 2, "atIF"
vim.o.mousemoveevent = true
vim.o.number, vim.o.cursorline, vim.o.signcolumn, vim.o.fillchars = true, true, "yes", "eob: "
vim.o.wrap = false
-- The focused multiline header shows its keys instead of a scratch buffer name.
function _G.preview_statusline()
  if vim.bo.filetype == "bufferlines" then return " HEADER  h j k l move  <CR> open  x close  <Esc> back " end
  return " %f %m%= %{&filetype}  %l:%c "
end
vim.o.statusline = "%!v:lua.preview_statusline()"
-- -u skips filetype detection until after this file, but scenes open buffers right away.
vim.cmd("filetype plugin on | syntax on")
vim.o.background = "dark"
vim.cmd.colorscheme("catppuccin")
require("nvim-web-devicons").setup({ default = true })
-- Built-in Lua/Markdown parsers give the code real colours without extra plugins.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "markdown" },
  callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
})
-- Show ui.lua at the hover-aware close-icon code rather than the file banner.
local VIEW = { topline = 274, lnum = 278, col = 2 }

local api = vim.api
local function path(rel) return root .. "/" .. rel end
local function edit(rel) vim.cmd.edit(vim.fn.fnameescape(path(rel))) end
local function sidebar(lines)
  vim.cmd("topleft 30vnew")
  vim.bo.buftype, vim.bo.bufhidden, vim.bo.buflisted, vim.bo.filetype = "nofile", "wipe", false, "preview-tree"
  vim.wo.number, vim.wo.cursorline, vim.wo.signcolumn = false, false, "no"
  api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd("wincmd l")
end
local function diagnose(rel, severities)
  local list = {}
  for i, severity in ipairs(severities) do
    list[#list + 1] = { lnum = i - 1, col = 0, severity = vim.diagnostic.severity[severity], message = "preview" }
  end
  vim.diagnostic.set(api.nvim_create_namespace("preview"), vim.fn.bufnr(path(rel)), list)
end
local function indicator(count, level) return " " .. (level:match("error") and " " or " ") .. count end

local CORE = {
  "lua/bufferlines.lua",
  "lua/bufferlines/ui.lua",
  "README.md",
  "wiki/Home.md",
  "lua/bufferlines/config.lua",
  "doc/bufferlines.txt",
}
local MANY = vim.list_extend(vim.deepcopy(CORE), {
  "lua/bufferlines/groups.lua",
  "lua/bufferlines/commands.lua",
  "lua/bufferlines/multiline/layout.lua",
  "lua/bufferlines/multiline/runtime.lua",
  "wiki/Multiline-Buffer-Tabs.md",
  "CHANGELOG.md",
  "lua/bufferlines/palette.lua",
  "lua/bufferlines/highlights.lua",
  "lua/bufferlines/offset.lua",
  "wiki/Features.md",
  "scripts/gen_help.py",
  "tests/golden_spec.lua",
})
local TREE = {
  "  bufferlines.nvim",
  "  ├ lua",
  "  │ ├ bufferlines",
  "  │ └ bufferlines.lua",
  "  ├ doc",
  "  ├ wiki",
  "  ├ README.md",
  "  └ CHANGELOG.md",
}
local function pinned() return require("bufferlines.groups").builtin.pinned:with({ icon = "󰐃" }) end

-- Each scene: options for setup(), files to open, optional setup() after opening, optional action() before capture.
local SCENES = {
  ["multiline-sidebar"] = {
    options = { multiline = { enabled = true, max_rows = 3 } },
    files = vim.list_slice(MANY, 1, 12),
    setup = function() sidebar(TREE) end,
    laststatus = 3,
  },
  ["multiline-overflow"] = {
    options = { multiline = { enabled = true, max_rows = 2 } },
    files = MANY,
    laststatus = 3,
  },
  ["multiline-navigate"] = {
    options = { multiline = { enabled = true, max_rows = 3 } },
    files = vim.list_slice(MANY, 1, 12),
    laststatus = 3,
    action = function()
      local handle = require("bufferlines.multiline.runtime").handles()[api.nvim_get_current_tabpage()]
      api.nvim_set_current_win(handle.win)
      api.nvim_feedkeys(api.nvim_replace_termcodes("jl", true, false, true), "mx", false)
    end,
  },
  default = { options = {}, files = CORE },
  slant = { options = { separator_style = "slant" }, files = CORE },
  slope = { options = { separator_style = "slope" }, files = CORE },
  hover = {
    options = { hover = { enabled = true, delay = 1, reveal = { "close" } } },
    files = CORE,
    action = function()
      local col, target = 0, vim.fn.bufnr(path("README.md"))
      for _, c in ipairs(require("bufferlines.state").visible_components) do
        if c.id == target then break end
        col = col + c.length
      end
      api.nvim_exec_autocmds("User", { pattern = "BufferLinesHoverOver", data = { cursor_pos = col + 3 } })
    end,
  },
  underline = { options = { indicator = { style = "underline" } }, files = CORE },
  tabpages = {
    options = { mode = "tabs" },
    files = CORE,
    setup = function()
      vim.cmd("tabnew " .. vim.fn.fnameescape(path("README.md")))
      vim.cmd("vsplit " .. vim.fn.fnameescape(path("wiki/Home.md")))
      vim.cmd("tabnew " .. vim.fn.fnameescape(path("CHANGELOG.md")))
      vim.cmd("tabfirst")
    end,
    keep_window = true,
  },
  diagnostics = {
    options = { diagnostics = "nvim_lsp", diagnostics_indicator = indicator },
    files = CORE,
    setup = function()
      diagnose("lua/bufferlines/ui.lua", { "ERROR", "ERROR", "WARN" })
      diagnose("lua/bufferlines/config.lua", { "WARN" })
    end,
  },
  groups = {
    options = {
      groups = {
        items = {
          { name = "Lua", highlight = { fg = "#87afd7" }, matcher = function(b) return b.name:match("%.lua$") ~= nil end },
          { name = "Docs", highlight = { fg = "#d7af87" }, matcher = function(b) return b.name:match("%.md$") ~= nil end },
        },
      },
    },
    files = CORE,
  },
  offsets = {
    options = { offsets = { { filetype = "preview-tree", text = "File Explorer", separator = true } } },
    files = CORE,
    setup = function() sidebar(TREE) end,
    laststatus = 3,
  },
  numbers = { options = { numbers = "both" }, files = CORE },
  duplicates = {
    options = {},
    files = { "README.md" },
    setup = function()
      local dir = vim.fn.tempname()
      for _, sub in ipairs({ "app/components", "app/utils", "app/models" }) do
        vim.fn.mkdir(dir .. "/" .. sub, "p")
        vim.fn.writefile({ "return {}" }, dir .. "/" .. sub .. "/init.lua")
        vim.cmd.edit(vim.fn.fnameescape(dir .. "/" .. sub .. "/init.lua"))
      end
    end,
  },
  ["close-icons"] = {
    options = { show_buffer_close_icons = true, show_close_icon = true },
    files = CORE,
    setup = function()
      vim.cmd("buffer " .. vim.fn.bufnr(path("README.md")))
      api.nvim_buf_set_lines(0, 0, 0, false, { "" })
      vim.cmd("buffer " .. vim.fn.bufnr(path("lua/bufferlines/ui.lua")))
    end,
    keep_window = true,
  },
  reorder = {
    options = { persist_buffer_sort = false },
    files = CORE,
    action = function()
      for _ = 1, 3 do
        vim.cmd("BufferLinesMoveNext")
      end
    end,
  },
  pick = { options = {}, files = CORE, pick = true },
  pinning = {
    options = { groups = { items = { pinned() } } },
    files = CORE,
    setup = function()
      for _, rel in ipairs({ "README.md", "lua/bufferlines/config.lua" }) do
        vim.cmd("buffer " .. vim.fn.bufnr(path(rel)))
        _G.nvim_bufferlines()
        require("bufferlines.groups").toggle_pin()
      end
    end,
  },
  ["custom-areas"] = {
    options = {
      custom_areas = {
        left = function() return { { text = "  bufferlines ", fg = "#1c1c1c", bg = "#87afd7", bold = true } } end,
        right = function()
          return {
            { text = "  2 ", fg = "#d75f5f" },
            { text = "  1 ", fg = "#d7af5f" },
            { text = "  main ", fg = "#87af87" },
          }
        end,
      },
    },
    files = CORE,
  },
}

local name = vim.env.PREVIEW_SCENE or "default"
local scene = assert(SCENES[name], "unknown scene " .. name)
local ready = vim.env.PREVIEW_READY
local ok, err = pcall(function()
  if scene.laststatus then vim.o.laststatus = scene.laststatus end
  require("bufferlines").setup({ options = vim.tbl_extend("force", { always_show_bufferline = true }, scene.options) })
  for _, f in ipairs(scene.files) do
    edit(f)
  end
  edit("lua/bufferlines/ui.lua")
  if scene.setup then scene.setup() end
  if not scene.keep_window then edit("lua/bufferlines/ui.lua") end
end)
if not ok then
  vim.fn.writefile({ "setup failed: " .. tostring(err) }, ready .. ".err")
  return
end

vim.defer_fn(function()
  local ui = path("lua/bufferlines/ui.lua")
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_buf_get_name(api.nvim_win_get_buf(win)) == ui then
      api.nvim_win_call(win, function() vim.fn.winrestview(VIEW) end)
      -- Startup can leave a sidebar focused; capture with the editing window current.
      if not scene.keep_window then api.nvim_set_current_win(win) end
    end
  end
  if scene.action then
    local aok, aerr = pcall(scene.action)
    if not aok then vim.fn.writefile({ "action failed: " .. tostring(aerr) }, ready .. ".err") end
  end
  vim.defer_fn(function()
    vim.cmd("redraw!")
    if scene.pick then
      vim.defer_fn(function() vim.fn.writefile({}, ready) end, 400)
      vim.cmd("BufferLinesPick")
    else
      vim.fn.writefile({}, ready)
    end
  end, 400)
end, 600)
