local utils = require("tests.utils")

local Buffer = utils.MockBuffer

--- NOTE: The pinned group is group 1 and so all groups must appear after this
--- all group are moved down by one because of this
describe("Group tests - ", function()
  local groups ---@module "bufferlines.groups"
  local state ---@module "bufferlines.state"
  local config ---@module "bufferlines.config"
  local bufferlines ---@module "bufferlines"

  before_each(function()
    package.loaded["bufferlines"] = nil
    package.loaded["bufferlines.groups"] = nil
    package.loaded["bufferlines.state"] = nil
    package.loaded["bufferlines.config"] = nil
    groups = require("bufferlines.groups")
    bufferlines = require("bufferlines")
    state = require("bufferlines.state")
    config = require("bufferlines.config")
  end)

  local function set_buf_group(buffer)
    buffer.group = groups.set_id(buffer)
    return buffer
  end

  it("should add user groups on setup", function()
    groups.setup({
      options = {
        groups = {
          items = {
            {
              name = "test-group",
              matcher = function(buf) return buf.name:match("dummy") end,
            },
          },
        },
      },
    })
    -- One for the pinned group, another for the ungrouped and the last for the new group
    assert.is_equal(vim.tbl_count(groups.state.user_groups), 3)
  end)

  it("should sanitise invalid names", function()
    groups.setup({
      options = {
        groups = {
          items = {
            {
              name = "test group",
              matcher = function(buf) return buf.name:match("dummy") end,
            },
          },
        },
      },
    })
    assert.is_truthy(groups.state.user_groups["test_group"])
  end)

  it("should set highlights on setup", function()
    local c = {
      highlights = {
        buffer_selected = {
          fg = "black",
          bg = "white",
        },
        buffer_visible = {
          fg = "black",
          bg = "white",
        },
        buffer = {
          fg = "black",
          bg = "white",
        },
        fill = {
          fg = "Red",
          bg = "Green",
        },
      },
      options = {
        groups = {
          items = {
            {
              name = "test-group",
              highlight = { fg = "red" },
              matcher = function(buf) return buf.name:match("dummy") end,
            },
          },
        },
      },
    }
    groups.setup(c)
    config.setup(c)
    local conf = config.apply()
    local hls = conf.highlights
    assert.truthy(hls.test_group_selected)
    assert.truthy(hls.test_group_visible)
    assert.truthy(hls.test_group)

    assert.equal(hls.test_group.fg, "red")
  end)

  it("should sort components by groups", function()
    groups.setup({
      options = {
        groups = {
          items = {
            {
              name = "test-group",
              matcher = function(buf) return buf.name:match("dummy") end,
            },
          },
        },
      },
    })
    local components = vim.tbl_map(set_buf_group, {
      Buffer:new({ name = "dummy-1.txt" }),
      Buffer:new({ name = "dummy-2.txt" }),
      Buffer:new({ name = "file-2.txt" }),
    })
    local sorted, components_by_group = groups.sort_by_groups(components)
    assert.is_equal(#sorted, 3)
    assert.equal(sorted[1]:as_element().name, "dummy-1.txt")
    assert.equal(sorted[#sorted]:as_element().name, "file-2.txt")

    assert.is_equal(vim.tbl_count(components_by_group), 3)
  end)

  it("should add group markers", function()
    local conf = {
      highlights = {},
      options = {
        groups = {
          items = {
            {
              name = "test-group",
              matcher = function(buf) return buf.name:match("dummy") end,
            },
          },
        },
      },
    }
    bufferlines.setup(conf)
    local components = {
      Buffer:new({ name = "dummy-1.txt" }),
      Buffer:new({ name = "dummy-2.txt" }),
      Buffer:new({ name = "file-2.txt" }),
    }
    components = vim.tbl_map(set_buf_group, components)
    components = groups.render(components, function(t) return t end)
    assert.equal(5, #components)
    local g_start = components[1]
    local g_end = components[4]
    assert.is_equal(g_start.type, "group_start")
    assert.is_equal(g_end.type, "group_end")
    local component = g_start.component()
    assert.is_true(utils.find_text(component, "test-group"))
  end)

  it("should sort each group individually", function()
    local conf = {
      highlights = {},
      options = {
        groups = {
          items = {
            {
              name = "A",
              matcher = function(buf) return buf.name:match("%.txt") end,
            },
            {
              name = "B",
              matcher = function(buf) return buf.name:match("%.js") end,
            },
            {
              name = "C",
              matcher = function(buf) return buf.name:match("%.dart") end,
            },
          },
        },
      },
    }
    bufferlines.setup(conf)
    local components = {
      Buffer:new({ name = "a.txt" }),
      Buffer:new({ name = "b.txt" }),
      Buffer:new({ name = "d.dart" }),
      Buffer:new({ name = "c.dart" }),
      Buffer:new({ name = "h.js" }),
      Buffer:new({ name = "g.js" }),
    }
    components = vim.tbl_map(set_buf_group, components)
    components = groups.render(components, function(t)
      table.sort(t, function(a, b) return a:as_element().name > b:as_element().name end)
      return t
    end)
    assert.is_equal(components[2]:as_element().name, "b.txt")
    assert.is_equal(components[3]:as_element().name, "a.txt")
    assert.is_equal(components[6]:as_element().name, "h.js")
    assert.is_equal(components[7]:as_element().name, "g.js")
    assert.is_equal(components[10]:as_element().name, "d.dart")
    assert.is_equal(components[11]:as_element().name, "c.dart")
  end)

  it("should pin a buffer", function()
    bufferlines.setup()
    vim.cmd("edit dummy-1.txt")
    nvim_bufferlines()
    vim.cmd("BufferLinesTogglePin")
    nvim_bufferlines()
    local buf = utils.find_buffer("dummy-1.txt", state)
    local group = buf and groups.get_manual_group(buf)
    assert.is_truthy(group and group:match("pinned"))
  end)

  it("should unpin a pinned buffer", function()
    bufferlines.setup()
    vim.cmd("edit dummy-1.txt")
    nvim_bufferlines()
    vim.cmd("BufferLinesTogglePin")
    nvim_bufferlines()
    local buf = utils.find_buffer("dummy-1.txt", state)
    local group = buf and groups.get_manual_group(buf)
    assert.is_truthy(group and group:match("pinned"))
    vim.cmd("BufferLinesTogglePin")
    nvim_bufferlines()
    group = buf and groups.get_manual_group(buf)
    assert.is_falsy(group)
  end)

  it("recomputes unique group priorities after setup changes", function()
    bufferlines.setup()
    bufferlines.setup({ options = { groups = { items = { { name = "Later", matcher = function() return true end } } } } })
    local all = groups.get_all()
    assert.is_not.equal(all.ungrouped.priority, all.Later.priority)
    assert.is_not.equal(all.pinned.priority, all.Later.priority)
    groups.toggle_hidden(all.Later.priority)
    assert.is_true(all.Later.hidden)
    assert.is_falsy(all.ungrouped.hidden)
  end)

  it("forgets stale pinned IDs before session restoration", function()
    vim.g.BufferlinesPinnedBuffers = ""
    bufferlines.setup()
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(buf, "expired-pin.txt")
    vim.api.nvim_set_current_buf(buf)
    nvim_bufferlines()
    groups.toggle_pin()
    vim.api.nvim_buf_delete(buf, { force = true })
    bufferlines.setup()
    assert.has_no.errors(function() vim.api.nvim_exec_autocmds("SessionLoadPost", {}) end)
    assert.same("", vim.g.BufferlinesPinnedBuffers)
  end)

  it("pinning should override other groups", function()
    bufferlines.setup({
      options = {
        groups = {
          items = {
            {
              name = "A",
              matcher = function(buf) return buf.name:match("%.txt") end,
            },
          },
        },
      },
    })
    vim.cmd("edit dummy-1.txt")
    nvim_bufferlines()
    vim.cmd("BufferLinesTogglePin")
    nvim_bufferlines()
    local buf = utils.find_buffer("dummy-1.txt", state)
    local group = buf and groups.get_manual_group(buf)
    assert.is_truthy(group and group:match("pinned"))
  end)
end)
