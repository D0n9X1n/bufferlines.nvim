local lazy = require("bufferlines.lazy")
local config = lazy.require("bufferlines.config") ---@module "bufferlines.config"
local utils = lazy.require("bufferlines.utils") ---@module "bufferlines.utils"

local M = {}

local fmt = string.format

---@return boolean
local function check_logging() return config.options.debug.logging end

---@param msg string
function M.debug(msg)
  if check_logging() then
    local info = debug.getinfo(2, "S")
    utils.notify(fmt("%s\n%s:%s", msg, info.linedefined, info.short_src), "debug", { once = true })
  end
end

return M
