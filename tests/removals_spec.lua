-- tests/removals_spec.lua
describe("removed legacy surface", function()
  local deprecate, seen; local function sync() local done = false; vim.schedule(function() done = true end); assert(vim.wait(1000, function() return done end, 1)) end
  before_each(function()
    for k in pairs(package.loaded) do if k:match("^bufferlines") then package.loaded[k] = nil end end
    deprecate, seen = vim.deprecate, {}
    vim.deprecate = function(name) seen[#seen + 1] = name end
  end)
  after_each(function() vim.deprecate = deprecate end)
  it("drops API aliases and the dead window click handler", function()
    local bl = require("bufferlines")
    for _, k in ipairs({ "pick_buffer", "go_to_buffer", "sort_buffers_by", "close_buffer_with_pick" }) do assert.is_nil(bl[k], k) end
    assert.is_nil(require("bufferlines.commands").handle_win_click)
  end)
  it("emits no deprecation notices and keeps the CoC option", function()
    require("bufferlines").setup({ options = { diagnostics = "nvim_lsp", diagnostics_update_in_insert = true, show_buffer_default_icon = true } })
    sync() -- deterministic: vim.deprecate notices are scheduled
    assert.same({}, seen); assert.is_true(require("bufferlines.config").options.diagnostics_update_in_insert)
  end)
  it("passes group matchers a plain table", function()
    local arg
    require("bufferlines").setup({ options = { groups = { items = { { name = "G", matcher = function(x) arg = x; return true end } } } } })
    vim.cmd.edit("removals.txt"); nvim_bufferlines(); sync() -- deterministic: vim.deprecate notices are scheduled
    assert.is_table(arg); assert.is_nil(getmetatable(arg)); assert.same({}, seen)
  end)
end)
