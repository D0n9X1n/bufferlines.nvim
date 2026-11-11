-- lua/bufferlines/compat.lua: Neovim 0.8+ API shims; the only place that probes versions.
local M = {}
local cache = {}
---@param feature string e.g. "nvim-0.10"
---@return boolean
function M.has(feature)
  if cache[feature] == nil then cache[feature] = vim.fn.has(feature) == 1 end
  return cache[feature]
end
---@diagnostic disable: deprecated
M.islist = vim.isarray or vim.islist or vim.tbl_isarray or vim.tbl_islist
---@param t table
---@return table
function M.flatten(t) return vim.iter and vim.iter(t):flatten(math.huge):totable() or vim.tbl_flatten(t) end
---@param name string
---@param use_cterm boolean?
---@return table
function M.get_hl(name, use_cterm)
  if vim.api.nvim_get_hl then
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    if use_cterm then
      hl.fg, hl.bg = hl.ctermfg, hl.ctermbg
    end
    return hl
  end
  return vim.api.nvim_get_hl_by_name(name, not use_cterm)
end
---@param ns integer
---@param bufnr integer
---@return boolean
function M.diagnostic_enabled(ns, bufnr)
  if M.has("nvim-0.10") then return vim.diagnostic.is_enabled({ ns_id = ns, bufnr = bufnr }) end
  return not (vim.diagnostic.is_disabled and vim.diagnostic.is_disabled(bufnr, ns))
end
return M
