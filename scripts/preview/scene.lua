-- Preview scenes for README screenshots. Env: PREVIEW_SCENE (default|slope|multiline|pick|groups), PREVIEW_READY.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
vim.opt.rtp:prepend(root)
vim.opt.rtp:append(vim.env.NVIM_TEST_DEPS .. "/nvim-web-devicons")
vim.o.termguicolors = true
vim.o.showmode, vim.o.ruler, vim.o.laststatus, vim.o.shortmess = false, false, 2, "atIF"
vim.cmd.colorscheme("habamax")
require("nvim-web-devicons").setup({ default = true })

local scene = vim.env.PREVIEW_SCENE or "default"
local scenes = {
  default = {},
  slope = { separator_style = "slope" },
  multiline = {
    multiline = { enabled = true, max_rows = 3 },
    offsets = { { filetype = "preview-tree", text = "Explorer", separator = true } },
  },
  pick = {},
  groups = {
    groups = {
      items = {
        require("bufferlines.groups").builtin.pinned:with({ icon = "󰐃" }),
        {
          name = "Lua",
          highlight = { fg = "#87afd7" },
          matcher = function(b) return b.name:match("%.lua$") ~= nil end,
        },
        {
          name = "Docs",
          highlight = { fg = "#d7af87" },
          matcher = function(b) return b.name:match("%.md$") ~= nil end,
        },
      },
    },
  },
}
local function indicator(count, level) return " " .. (level:match("error") and " " or " ") .. count end
require("bufferlines").setup({
  options = vim.tbl_extend(
    "force",
    { diagnostics = "nvim_lsp", diagnostics_indicator = indicator, always_show_bufferline = true },
    scenes[scene]
  ),
})
if scene == "multiline" then vim.o.laststatus = 3 end

local files = {
  "lua/bufferlines.lua",
  "lua/bufferlines/ui.lua",
  "README.md",
  "wiki/Home.md",
  "lua/bufferlines/config.lua",
  "doc/bufferlines.txt",
}
if scene == "multiline" then
  vim.list_extend(files, {
    "lua/bufferlines/groups.lua",
    "lua/bufferlines/commands.lua",
    "lua/bufferlines/multiline/layout.lua",
    "lua/bufferlines/multiline/runtime.lua",
    "wiki/Multiline-Buffer-Tabs.md",
    "CHANGELOG.md",
  })
end
for _, f in ipairs(files) do
  vim.cmd.edit(vim.fn.fnameescape(root .. "/" .. f))
end
local ui = vim.fn.bufnr(root .. "/lua/bufferlines/ui.lua")
vim.diagnostic.set(vim.api.nvim_create_namespace("preview"), ui, {
  { lnum = 0, col = 0, severity = vim.diagnostic.severity.ERROR, message = "preview" },
  { lnum = 1, col = 0, severity = vim.diagnostic.severity.WARN, message = "preview" },
})
if scene == "groups" then require("bufferlines.groups").toggle_pin() end
vim.cmd.edit(vim.fn.fnameescape(root .. "/lua/bufferlines/ui.lua"))

if scene == "multiline" then
  vim.cmd("topleft 30vnew")
  vim.bo.buftype, vim.bo.bufhidden, vim.bo.buflisted, vim.bo.filetype = "nofile", "wipe", false, "preview-tree"
  local tree = {
    "  bufferlines.nvim",
    "  ├ lua",
    "  │ ├ bufferlines",
    "  │ └ bufferlines.lua",
    "  ├ doc",
    "  ├ wiki",
  }
  vim.list_extend(tree, { "  ├ README.md", "  └ CHANGELOG.md" })
  vim.api.nvim_buf_set_lines(0, 0, -1, false, tree)
  vim.cmd("wincmd l")
end

vim.defer_fn(function()
  vim.cmd("redraw!")
  if scene == "pick" then
    vim.defer_fn(function() vim.fn.writefile({}, vim.env.PREVIEW_READY) end, 400)
    vim.cmd("BufferLinesPick")
  else
    vim.fn.writefile({}, vim.env.PREVIEW_READY)
  end
end, 800)
