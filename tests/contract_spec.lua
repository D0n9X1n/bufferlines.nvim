-- tests/contract_spec.lua
local api = vim.api
local function fresh(opts)
  for k in pairs(package.loaded) do
    if k:match("^bufferline") then package.loaded[k] = nil end
  end
  local bl = require("bufferlines")
  bl.setup(opts or {})
  return bl
end
describe("public contract", function()
  it("dispatches all 18 Ex commands with arguments", function()
    local bl, groups, calls = fresh(), require("bufferlines.groups"), {}
    local function spy(t, k)
      t[k] = function(...) calls[#calls + 1] = { k, ... } end
    end
    for _, k in ipairs({
      "pick",
      "close_with_pick",
      "cycle",
      "close_in_direction",
      "close_others",
      "move",
      "sort_by",
      "go_to",
      "rename_tab",
    }) do
      spy(bl, k)
    end
    spy(groups, "toggle_pin")
    spy(groups, "action")
    local cases = {
      { "BufferLinesPick", { "pick" } },
      { "BufferLinesPickClose", { "close_with_pick" } },
      { "BufferLinesCycleNext", { "cycle", 1 } },
      { "BufferLinesCyclePrev", { "cycle", -1 } },
      { "BufferLinesCloseRight", { "close_in_direction", "right" } },
      { "BufferLinesCloseLeft", { "close_in_direction", "left" } },
      { "BufferLinesCloseOthers", { "close_others" } },
      { "BufferLinesMoveNext", { "move", 1 } },
      { "BufferLinesMovePrev", { "move", -1 } },
      { "BufferLinesSortByExtension", { "sort_by", "extension" } },
      { "BufferLinesSortByDirectory", { "sort_by", "directory" } },
      { "BufferLinesSortByRelativeDirectory", { "sort_by", "relative_directory" } },
      { "BufferLinesSortByTabs", { "sort_by", "tabs" } },
      { "BufferLinesGoToBuffer 3", { "go_to", "3" } },
      { "BufferLinesTogglePin", { "toggle_pin" } },
      { "BufferLinesTabRename a b", { "rename_tab", { "a", "b" } } },
      { "BufferLinesGroupClose g", { "action", "g", "close" } },
      { "BufferLinesGroupToggle g", { "action", "g", "toggle" } },
    }
    for _, c in ipairs(cases) do
      calls = {}
      vim.cmd(c[1])
      assert.same({ c[2] }, calls, c[1])
    end
    local cmds = vim.tbl_filter(function(n) return n:match("^BufferLines") end, vim.tbl_keys(api.nvim_get_commands({})))
    assert.equals(18, #cmds)
    assert.equals(
      0,
      #vim.tbl_filter(function(n) return n:match("^BufferLine%u") end, vim.tbl_keys(api.nvim_get_commands({})))
    )
  end)
  it("exposes renamed globals, augroups, events, handler and keys", function()
    fresh({
      options = {
        diagnostics = "nvim_lsp",
        diagnostics_update_on_event = true,
        groups = { items = { { name = "G", matcher = function() return false end } } },
      },
    })
    require("bufferlines.hover")
    assert.equals("%!v:lua.nvim_bufferlines()", vim.o.tabline)
    assert.is_function(_G.nvim_bufferlines)
    assert.is_nil(_G.nvim_bufferline)
    assert.is_function(_G.___bufferlines_private.handle_click)
    assert.is_nil(rawget(_G, "___bufferline_private"))
    for _, g in ipairs({ "BufferlinesCmds", "BufferLinesHover", "BufferlinesGroups" }) do
      assert.is_true(pcall(api.nvim_get_autocmds, { group = g }), g)
    end
    local events = vim.tbl_map(
      function(a) return a.pattern end,
      api.nvim_get_autocmds({ group = "BufferlinesCmds", event = "User" })
    )
    table.sort(events)
    assert.same({ "BufferLinesHoverOut", "BufferLinesHoverOver" }, events)
    assert.is_table(rawget(vim.diagnostic.handlers, "bufferlines"))
    assert.is_nil(rawget(vim.diagnostic.handlers, "bufferline"))
    assert.equals("BufferlinesPositions", require("bufferlines.constants").positions_key)
    local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
    assert.truthy(vim.fn.readfile(root .. "/doc/bufferlines.txt")[1]:find("*bufferlines.nvim*", 1, true))
    assert.is_false(pcall(require, "bufferline"))
  end)
  it("marks the multiline header with the renamed filetype and marker", function()
    if vim.fn.has("nvim-0.12") == 0 then return end
    vim.cmd("silent! %bwipeout!")
    fresh({ options = { multiline = { enabled = true } } })
    vim.cmd.edit("c-1.txt")
    vim.cmd.edit("c-2.txt")
    local rt = require("bufferlines.multiline.runtime")
    rt.flush("contract")
    local h = assert(rt.handles()[api.nvim_get_current_tabpage()])
    assert.equals("bufferlines", vim.bo[h.buf].filetype)
    assert.is_not_nil(vim.w[h.win].bufferlines_multiline)
    assert.is_true(pcall(api.nvim_get_autocmds, { group = "BufferlinesMultilineRuntime" }))
    rt.disable()
  end)
end)
