-- tests/hygiene_spec.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local function lines(rel) return vim.fn.readfile(root .. "/" .. rel) end
describe("source hygiene", function()
  it("routes every message through utils.notify", function()
    for _, f in ipairs(vim.fn.globpath(root .. "/lua", "**/*.lua", false, true)) do
      if not f:match("utils/init%.lua$") then
        for i, l in ipairs(vim.fn.readfile(f)) do
          assert.is_nil(l:find("vim%.notify"), f .. ":" .. i)
        end
      end
    end
  end)
  it("has no unreachable terminal branch and a correct log annotation", function()
    for _, l in ipairs(lines("lua/bufferlines/utils/init.lua")) do
      assert.is_nil(l:find('if type == "terminal"', 1, true))
    end
    assert.truthy(lines("lua/bufferlines/utils/log.lua")[3]:find('---@module "bufferlines.utils"', 1, true))
  end)
  it("annotates every public multiline function", function()
    for _, m in ipairs({ "layout", "options", "runtime" }) do
      local ls = lines("lua/bufferlines/multiline/" .. m .. ".lua")
      for i, l in ipairs(ls) do
        if l:match("^function M%.") then assert.truthy(ls[i - 1]:match("^%-%-%-"), m .. ":" .. i) end
      end
    end
  end)
end)
