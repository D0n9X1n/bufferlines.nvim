-- tests/filter_spec.lua
local api = vim.api
local function fresh(options)
  vim.cmd("silent! tabonly | silent! %bwipeout!")
  for k in pairs(package.loaded) do if k:match("^bufferlines") then package.loaded[k] = nil end end
  require("bufferlines").setup({ options = options })
  for _, n in ipairs({ "keep-1.txt", "drop.txt", "keep-2.txt" }) do vim.cmd.edit(n) end
  return require("bufferlines.state")
end
describe("custom_filter", function()
  it("rejecting everything yields no components in buffer mode", function()
    fresh({ custom_filter = function() return false end }); nvim_bufferlines()
    assert.equals(0, #require("bufferlines.state").components)
  end)
  it("falls back to the tab's buffers in tab mode", function()
    local state = fresh({ mode = "tabs", custom_filter = function() return false end }); nvim_bufferlines()
    assert.equals(1, #state.components)
    assert.equals(api.nvim_get_current_buf(), state.components[1]:as_element().buffers[1])
  end)
  it("keeps order and passes (buf, all_bufs)", function()
    local calls = {}
    local state = fresh({ custom_filter = function(buf, bufs) calls[#calls + 1] = { buf, bufs }; return api.nvim_buf_get_name(buf):match("keep") ~= nil end })
    nvim_bufferlines()
    local names = vim.tbl_map(function(c) return vim.fn.fnamemodify(c:as_element().path, ":t") end, state.components)
    assert.same({ "keep-1.txt", "keep-2.txt" }, names)
    for _, c in ipairs(calls) do assert.is_true(vim.tbl_contains(c[2], c[1])); assert.same(calls[1][2], c[2]) end
  end)
  it("tab mode keeps window order, passes (buf, tab_bufs), then (active_buf)", function()
    local calls = {}
    local state = fresh({ mode = "tabs", custom_filter = function(buf, bufs) calls[#calls + 1] = { buf, bufs }; return api.nvim_buf_get_name(buf):match("keep") ~= nil end })
    vim.cmd("only | edit keep-1.txt | vsplit drop.txt | vsplit keep-2.txt")
    calls = {}; nvim_bufferlines()
    local wins = vim.tbl_map(api.nvim_win_get_buf, api.nvim_tabpage_list_wins(0))
    local listed = vim.tbl_filter(function(c) return c[2] ~= nil end, calls)
    assert.same(wins, vim.tbl_map(function(c) return c[1] end, listed))
    for _, c in ipairs(listed) do assert.same(wins, c[2]) end
    assert.same(vim.tbl_filter(function(b) return api.nvim_buf_get_name(b):match("keep") ~= nil end, wins), state.components[1]:as_element().buffers)
    local single = vim.tbl_filter(function(c) return c[2] == nil end, calls)
    assert.equals(1, #single); assert.equals(api.nvim_get_current_buf(), single[1][1])
  end)
end)
