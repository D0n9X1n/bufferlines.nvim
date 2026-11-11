-- tests/palette_spec.lua
local palette = require("bufferlines.palette")
describe("palette", function()
  it("resolves names, and/or with Lua truthiness, literals", function()
    local ctx = { x = "#111111", f = false, t = true }
    assert.same(
      { a = "#111111", b = false, c = "#111111", d = true },
      palette.resolve({ g = { a = "x", b = { "and", "f", "x" }, c = { "or", "missing", "x" }, d = true } }, ctx).g
    )
  end)
  it("every GROUPS reference names a context key", function()
    require("tests.golden.harness").apply_palette("dark")
    local ctx = palette.context({ is_minimal = true, italic = true, bold = true, indicator_style = "underline" })
    for group, attrs in pairs(palette.GROUPS) do
      for attr, expr in pairs(attrs) do
        for _, k in ipairs(type(expr) == "table" and { expr[2], expr[3] } or { expr }) do
          if type(k) == "string" then assert.is_not_nil(ctx[k], group .. "." .. attr .. " -> " .. k) end
        end
      end
    end
  end)
end)
