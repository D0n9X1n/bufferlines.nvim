-- tests/diagnostics_spec.lua (CoC insert-mode regression; keeps diagnostics_update_in_insert alive)
describe("coc diagnostics in insert mode", function()
  local get_mode, buf
  before_each(function()
    package.loaded["bufferlines.diagnostics"] = nil
    vim.g.coc_service_initialized = 1
    buf = vim.api.nvim_create_buf(true, false); vim.api.nvim_buf_set_name(buf, vim.fn.tempname() .. "-coc.lua")
    vim.fn.CocActionAsync = function(_, cb) cb(vim.NIL, { { file = vim.api.nvim_buf_get_name(buf), level = 1 } }) end
    get_mode = vim.api.nvim_get_mode
    vim.api.nvim_get_mode = function() return { mode = "i", blocking = false } end
  end)
  after_each(function() vim.api.nvim_get_mode = get_mode; vim.g.coc_service_initialized = nil end)
  local function count(opts)
    local d = require("bufferlines.diagnostics"); d.get({ diagnostics = "coc" }) -- builds the coc closure
    d.refresh_coc_diagnostics()
    return d.get(vim.tbl_extend("force", { diagnostics = "coc" }, opts))[buf].count
  end
  it("updates with diagnostics_update_in_insert = true", function() assert.equals(1, count({ diagnostics_update_in_insert = true })) end)
  it("keeps the last result when the option is absent", function() assert.equals(0, count({})) end)
end)
