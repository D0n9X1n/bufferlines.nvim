local api = vim.api

local utils = require("bufferlines.utils")
local constants = require("bufferlines.constants")

describe("Utils tests", function()
  it("should correctly truncate a long name", function()
    local truncated = utils.truncate_name("/user/test/long/file/folder/name/extension", 10)
    assert.is_true(api.nvim_strwidth(truncated) <= 10)
  end)

  it("should prefer dropping a filename extension in order to meet word limit", function()
    local truncated = utils.truncate_name("filename.md", 10)
    assert.is_equal(truncated, "filename" .. constants.ELLIPSIS)
  end)

  it("should prefer dropping a SINGLE filename extension in order to meet word limit", function()
    local truncated = utils.truncate_name("filename.md.md", 13)
    assert.is_equal(truncated, "filename.md" .. constants.ELLIPSIS)
  end)

  it("should save/restore positions correctly", function()
    -- remove existing buffers
    vim.cmd("silent %bwipeout!")

    local names = { "c.txt", "a.txt", "d.txt", "e.txt", "b.txt" }
    local bufs = {}
    for _, name in ipairs(names) do
      vim.cmd.edit(name)
      bufs[name] = api.nvim_get_current_buf()
    end

    local ids = {
      bufs["a.txt"],
      bufs["b.txt"],
      bufs["c.txt"],
      bufs["d.txt"],
      bufs["e.txt"],
    }

    utils.save_positions(ids)

    assert.same(utils.restore_positions(), ids)

    -- restore_positions should not return invalid bufids

    vim.cmd("bwipeout! " .. bufs["c.txt"])

    ids = {
      bufs["a.txt"],
      bufs["b.txt"],
      bufs["d.txt"],
      bufs["e.txt"],
    }
    assert.same(utils.restore_positions(), ids)

    vim.g[constants.positions_key] = '["INVALID_PATH"]'
    assert.same(utils.restore_positions(), {})

    -- empty or invalid JSON should return nil

    vim.g[constants.positions_key] = "[]"
    assert.is_equal(utils.restore_positions(), nil)

    vim.g[constants.positions_key] = ""
    assert.is_equal(utils.restore_positions(), nil)
  end)
end)

describe("apply_buffer_filter", function()
  local utils = require("bufferlines.utils")
  it("filters in order and passes (buf, all)", function()
    local seen = {}
    assert.same(
      { 1, 3 },
      utils.apply_buffer_filter({ 1, 2, 3 }, function(b, all)
        seen[#seen + 1] = { b, all }
        return b ~= 2
      end, "buffers")
    )
    assert.same({ { 1, { 1, 2, 3 } }, { 2, { 1, 2, 3 } }, { 3, { 1, 2, 3 } } }, seen)
  end)
  it("reject-all: {} for buffers, original for tabs; nil callback passes through", function()
    local no = function() return false end
    assert.same({}, utils.apply_buffer_filter({ 1, 2 }, no, "buffers"))
    assert.same({ 1, 2 }, utils.apply_buffer_filter({ 1, 2 }, no, "tabs"))
    assert.same({ 1, 2 }, utils.apply_buffer_filter({ 1, 2 }, nil, "buffers"))
  end)
end)

describe("clip_cells", function()
  local clip = require("bufferlines.utils").clip_cells
  it("never splits wide or combining characters", function()
    assert.equals("abc", clip("abcdef", 3))
    assert.equals("", clip("abc", 0))
    assert.equals("日", clip("日本語", 3))
    assert.equals("", clip("日本", 1))
    assert.equals("e\204\129", clip("e\204\129x", 1))
    assert.equals("100%", clip("100%x", 4))
  end)
  it("accepts a display-width measure", function() assert.equals("\t", clip("\tx", 8, vim.fn.strdisplaywidth)) end)
  it(
    "truncate_name keeps its output",
    function() assert.equals("abcd…", require("bufferlines.utils").truncate_name("abcdefghij", 5)) end
  )
end)
