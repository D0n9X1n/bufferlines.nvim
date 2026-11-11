if vim.fn.has("nvim-0.12") == 0 then return end -- attributes recorded on 0.12.6; older versions run native specs
vim.o.columns, vim.o.lines, vim.o.hidden = 120, 40, true
vim.cmd("filetype off") -- ftplugins start treesitter parsers that the isolated test runtime lacks; icons key off extensions
local H, map = require("tests.golden.harness"), require("tests.golden.name_map")
local DIR, RECORD = "tests/golden/data/", vim.env.GOLDEN_RECORD == "1"
local function check(id, rec)
  local file = DIR .. id .. ".lua"
  if RECORD then vim.fn.mkdir(DIR, "p"); vim.fn.writefile(vim.split("return " .. vim.inspect(rec), "\n"), file); return end
  assert(vim.uv.fs_stat(file), "missing golden " .. file)
  assert.same(map.normalise(dofile(file)), map.normalise(rec))
end
local function shown(rec)
  local s = (rec.tabline or ""):gsub("%%#[%w_]+#", ""):gsub("%%%d*@[^@]*@", "")
  return s .. table.concat(type(rec.lines) == "table" and rec.lines or {}, "\n")
end
describe("golden rendering", function()
  for _, fx in ipairs(H.FIXTURES) do for _, p in ipairs({ "dark", "light" }) do
    it(fx.name .. "/" .. p, function()
      local rec = H.capture(fx, p)
      assert.is_nil(shown(rec):find("[Bb]uffer[Ll]ine"), "fixture text must not contain identifiers")
      check(fx.name .. "-" .. p, rec)
    end)
  end end
  for _, p in ipairs(H.FALLBACK_PALETTES) do for _, ind in ipairs({ "icon", "underline" }) do
    it(("derived fallback %s/%s"):format(p, ind), function()
      check(("derived-fallback-%s-%s"):format(p, ind), { derived = H.derived({ 1 }, p, ind) })
    end)
  end end
  for _, d in ipairs(H.DERIVED) do for _, p in ipairs({ "dark", "light" }) do for _, ind in ipairs({ "icon", "underline" }) do
    it(("derived %s/%s/%s"):format(d[1], p, ind), function()
      check(("derived-%s-%s-%s"):format(d[1], p, ind), { derived = H.derived(d[2], p, ind) })
    end)
  end end end
end)
