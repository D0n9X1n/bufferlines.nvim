describe("Multiline shared state", function()
  local bufferlines, state
  before_each(function()
    bufferlines = require("bufferlines")
    state = require("bufferlines.state")
    vim.o.hidden = true
    vim.o.termguicolors = true
    bufferlines.setup({ options = { show_buffer_icons = false, persist_buffer_sort = false } })
  end)
  after_each(function()
    bufferlines.setup({ options = { persist_buffer_sort = false } })
    vim.cmd("silent! %bwipeout!")
  end)

  it("computes complete ordered entries without evaluating a native tabline", function()
    vim.cmd("edit first.txt")
    vim.cmd("edit second.txt")
    vim.o.showtabline = 0
    local components = bufferlines.compute()
    assert.same(2, #components)
    assert.same(2, #state.components)
    assert.same(components[2].id, vim.api.nvim_get_current_buf())
  end)

  it("reuses native output after a standalone computation", function()
    vim.cmd("edit native.txt")
    local before = nvim_bufferlines()
    bufferlines.compute()
    assert.same(before, nvim_bufferlines())
  end)

  it("keeps selection authoritative and cycles with no renderable header", function()
    vim.cmd("edit mode-first.txt")
    local first = vim.api.nvim_get_current_buf()
    bufferlines.setup({ options = { multiline = { enabled = true }, persist_buffer_sort = false } })
    local runtime = require("bufferlines.multiline.runtime")
    runtime.flush("test")
    local plan = require("bufferlines.multiline.layout").plan
    require("bufferlines.multiline.layout").plan = function() return { valid = false } end
    local read, notify = vim.fn.getchar, vim.notify
    local ok, err = pcall(function()
      runtime.flush("test")
      local second = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_name(second, "mode-second.txt")
      vim.o.showtabline = 2
      vim.api.nvim_exec_autocmds("BufAdd", {})
      local done = false
      vim.schedule(function() done = true end)
      assert.is_true(vim.wait(1000, function() return done end, 1))
      assert.equals(0, vim.o.showtabline)
      assert.equals("", nvim_bufferlines())
      require("bufferlines.commands").cycle(1)
      assert.equals(second, vim.api.nvim_get_current_buf())
      require("bufferlines.commands").cycle(-1)
      assert.equals(first, vim.api.nvim_get_current_buf())
      local warned = false
      vim.notify = function() warned = true end
      vim.fn.getchar = function() error("must not wait for invisible pick labels") end
      require("bufferlines.pick").choose_then(function() error("must not activate") end)
      assert.is_true(vim.wait(500, function() return warned end))
      assert.is_false(state.is_picking)
      assert.is_true(runtime.selected())
      assert.equals(0, vim.o.showtabline)
    end)
    require("bufferlines.multiline.layout").plan = plan
    vim.fn.getchar, vim.notify = read, notify
    assert.is_true(ok, err)
    bufferlines.setup({ options = { multiline = { enabled = false }, persist_buffer_sort = false } })
    assert.is_false(runtime.selected())
    assert.is_true(#nvim_bufferlines() > 0)
  end)

  it("dispatches a click in its captured editing window", function()
    vim.cmd("edit origin.txt")
    local origin = vim.api.nvim_get_current_win()
    local target = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(target, "target.txt")
    vim.cmd("vsplit")
    local other = vim.api.nvim_get_current_win()
    local original = vim.api.nvim_get_current_buf()
    require("bufferlines.commands").dispatch({ kind = "click", id = target }, {
      win = origin,
      tab = vim.api.nvim_get_current_tabpage(),
      button = "l",
    })
    assert.same(target, vim.api.nvim_win_get_buf(origin))
    assert.same(original, vim.api.nvim_win_get_buf(other))
    assert.same(origin, vim.api.nvim_get_current_win())
    vim.cmd("only")
  end)

  it("preserves configured function and string callback semantics", function()
    local commands = require("bufferlines.commands")
    local config = require("bufferlines.config")
    local target = vim.api.nvim_get_current_buf()
    local context = { win = vim.api.nvim_get_current_win(), tab = vim.api.nvim_get_current_tabpage(), button = "m" }
    local received
    config.options.middle_mouse_command = function(id) received = id end
    commands.dispatch({ kind = "click", id = target }, context)
    assert.same(target, received)
    config.options.right_mouse_command = "let g:multiline_dispatch_id = %d"
    context.button = "r"
    commands.dispatch({ kind = "click", id = target }, context)
    assert.same(target, vim.g.multiline_dispatch_id)
  end)

  it("does not dispatch into a closed editing context", function()
    local target = vim.api.nvim_get_current_buf()
    assert.is_false(require("bufferlines.commands").dispatch({ kind = "click", id = target }, {
      win = -1,
      tab = vim.api.nvim_get_current_tabpage(),
      button = "l",
    }))
  end)
end)
