# Configuration

[简体中文](Configuration-zh-CN)

## `setup()` takes a complete configuration

`require("bufferlines").setup(config)` is **not** an incremental options update. Each
call receives a complete configuration. Keep your original table around so you can
restore settings later without losing custom options or highlights:

```lua
local bufferlines = require("bufferlines")
local original_config = {
  options = {
    -- Keep all your existing options here.
  },
  -- Keep other setup fields, such as highlights, here too.
}
bufferlines.setup(original_config)
```

This matters most when toggling the [multiline renderer](Multiline-Buffer-Tabs), which
has native-only options you must remove from the multiline copy and restore afterwards.

## Where the reference lives

The full option table, defaults, types and validation rules are in the generated help
file, which is authored in [`wiki/help/`](Documentation-Pipeline):

```vim
:help bufferlines-configuration
```

Topic-specific reference pages:

| Topic | Help tag |
| --- | --- |
| Hover events | `:help bufferlines-hover-events` |
| Styling and presets | `:help bufferlines-styling`, `:help bufferlines-style-presets` |
| Tabpages | `:help bufferlines-tabpages` |
| Numbers | `:help bufferlines-numbers` |
| LSP diagnostics | `:help bufferlines-diagnostics` |
| Groups | `:help bufferlines-groups` |
| Sorting and filtering | `:help bufferlines-sorting`, `:help bufferlines-filtering` |
| Commands | `:help bufferlines-commands` |
| Custom functions | `:help bufferlines-functions` |
| Pick | `:help bufferlines-pick` |
| Mappings | `:help bufferlines-mappings` |
| Highlights | `:help bufferlines-highlights` |
| Mouse actions | `:help bufferlines-mouse-actions` |
| Custom areas | `:help bufferlines-custom-areas` |
| Sidebar offsets | `:help bufferlines-sidebar-offset` |

## Contributors and AI coding agents

Read [AGENTS.md](https://github.com/D0n9X1n/bufferlines.nvim/blob/HEAD/AGENTS.md) for
architecture, offline tests, compatibility boundaries and safe development workflows.
`CLAUDE.md` imports that shared guide for Claude Code.
