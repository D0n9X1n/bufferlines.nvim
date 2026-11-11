---@diagnostic disable: need-check-nil
describe("Highlights -", function()
  local highlights ---@module "bufferlines.highlights"
  local config ---@module "bufferlines.config"

  before_each(function()
    package.loaded["bufferlines.highlights"] = nil
    package.loaded["bufferlines.config"] = nil

    highlights = require("bufferlines.highlights")
    config = require("bufferlines.config")
  end)

  it("should set highlights as default", function()
    config.setup({ options = { themable = true } })
    config.apply()
    local hl = highlights.set("BufferLinesBufferSelected", { bold = true })
    assert.truthy(hl)
    assert.is_true(hl.default)
  end)

  it("should not set highlights as default if themable = false", function()
    config.setup({ options = { themable = true } })
    config.apply()
    local hl = highlights.set("BufferLinesBufferSelected", { bold = true })
    assert.truthy(hl)
    assert.is_true(hl.default)
  end)
end)
