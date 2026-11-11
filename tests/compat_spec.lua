-- tests/compat_spec.lua
local compat = require("bufferlines.compat")
describe("compat", function()
  it("has/islist/flatten", function()
    assert.is_true(compat.has("nvim-0.8"))
    assert.is_false(compat.has("nvim-99.0"))
    assert.is_true(compat.islist({ 1, 2 }))
    assert.is_false(compat.islist({ a = 1 }))
    assert.same({ 1, 2, 3 }, compat.flatten({ 1, { 2, { 3 } } }))
  end)
  it("get_hl returns gui and cterm colours", function()
    vim.api.nvim_set_hl(0, "CompatProbe", { fg = "#112233", ctermfg = 4 })
    local gui = compat.get_hl("CompatProbe")
    assert.equals(0x112233, gui.fg or gui.foreground)
    local cterm = compat.get_hl("CompatProbe", true)
    assert.equals(4, cterm.fg or cterm.foreground)
  end)
  it("diagnostic_enabled honours per-buffer disable", function()
    local ns, buf = vim.api.nvim_create_namespace("compat"), vim.api.nvim_get_current_buf()
    assert.is_true(compat.diagnostic_enabled(ns, buf))
    if compat.has("nvim-0.10") then
      vim.diagnostic.enable(false, { bufnr = buf, ns_id = ns })
    elseif compat.has("nvim-0.9") then
      vim.diagnostic.disable(buf, ns)
    else
      return
    end
    assert.is_false(compat.diagnostic_enabled(ns, buf))
  end)
  it("every module loads", function()
    local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
    for _, f in ipairs(vim.fn.globpath(root .. "/lua", "**/*.lua", false, true)) do
      local mod = f:match("/lua/(.+)%.lua$"):gsub("/init$", ""):gsub("/", ".")
      if compat.has("nvim-0.12") or not mod:match("multiline") then
        package.loaded[mod] = nil
        local ok, err = pcall(require, mod)
        assert(ok, mod .. ": " .. tostring(err))
      end
    end
  end)
  it("is the only home for version probes", function()
    local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
    for _, f in ipairs(vim.fn.globpath(root .. "/lua", "**/*.lua", false, true)) do
      if not f:match("compat%.lua$") and not f:match("multiline/options%.lua$") then
        for _, l in ipairs(vim.fn.readfile(f)) do
          local code = l:gsub("%-%-.*", "")
          for _, p in ipairs({ "fn%.has%(", "vim%.version%(", "nvim_get_hl_by_name", "tbl_islist", "tbl_isarray" }) do
            assert.is_nil(code:find(p), f .. ": " .. l)
          end
        end
      end
    end
  end)
end)
