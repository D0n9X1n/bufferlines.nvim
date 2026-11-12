# Features

[简体中文](Features-zh-CN)

- Colours derived from the colorscheme where possible.
- Sort buffers by `extension`, `directory`, or a custom compare function.
- Configuration via Lua functions for greater customization.

See also: [Multiline Buffer Tabs](Multiline-Buffer-Tabs).

## Alternate styling

### Slanted tabs

![Slanted separators](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/slant.png)

**NOTE**: some terminals require special characters to be padded, so set the style to
`padded_slant` if the appearance isn't right in your terminal emulator. Results vary by
terminal emulator and this style might not work everywhere.

### Sloped tabs

![Sloped separators](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/slope.png)

See `:help bufferlines-styling`.

## Hover events

**NOTE**: only available for Neovim 0.8+. Not supported with
[multiline](Multiline-Buffer-Tabs).

![Hovering README.md reveals its close icon](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/hover.png)

See `:help bufferlines-hover-events`.

## Underline indicator

![Underline indicator under the current buffer](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/underline.png)

Set `indicator = { style = "underline" }`. How the underline looks depends on your
terminal emulator's underline support.

## Tabpages

![Tabs mode: one entry per tabpage](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/tabpages.png)

Set the `mode` option to `tabs` to show only tabpages. This turns the bufferlines into a
tabline with many of the same features and styling, but not all:

- Sorting doesn't work yet, as that needs to be thought through.
- Grouping doesn't work yet, for the same reason.

`mode = "tabs"` is not supported with multiline.

## LSP indicators

![Error and warning counts on ui.lua and config.lua](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/diagnostics.png)

Setting `diagnostics = "nvim_lsp" | "coc"` adds an indicator for any buffer with errors,
so you can tell at a glance which buffers are affected.

Customise the appearance of the count with a function:

```lua
--- count is an integer representing total count of errors
--- level is a string "error" | "warning"
--- diagnostics_dict is a dictionary from error level ("error", "warning" or "info") to number of errors for each level.
--- this should return a string
--- Don't get too fancy as this function will be executed a lot
diagnostics_indicator = function(count, level, diagnostics_dict, context)
  local icon = level:match("error") and " " or " "
  return " " .. icon .. count
end
```

```lua
diagnostics_indicator = function(count, level, diagnostics_dict, context)
  local s = " "
  for e, n in pairs(diagnostics_dict) do
    local sym = e == "error" and " "
      or (e == "warning" and " " or " ")
    s = s .. n .. sym
  end
  return s
end
```

Indicators can be reported conditionally, based on buffer context. For instance, disable
them for the current buffer and show them only for other buffers:

```lua
diagnostics_indicator = function(count, level, diagnostics_dict, context)
  if context.buffer:current() then
    return ''
  end

  return ''
end
```

Change the filename highlighting for error states via `:help bufferlines-highlights`.

## Groups

![Lua and Docs groups with coloured labels](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/groups.png)

Groups visualize related buffers in clusters and let you operate on them together — for
example, clicking the group indicator hides all its buffers. Partly inspired by Chrome's
tabs and centaur-tabs' groups.

See `:help bufferlines-groups`.

## Sidebar offsets

![File Explorer offset above a sidebar](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/offsets.png)

See `:help bufferlines-sidebar-offset`. Offsets apply to the native tabline only;
multiline uses its editor split's actual width.

## Numbers

![Ordinal and buffer numbers before each name](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/numbers.png)

Prefix buffer names with either the `ordinal` or `buffer id` using the `numbers` option,
specified as `buffer_id` | `ordinal` or a function.

See `:help bufferlines-numbers`.

## Unique names

Buffers with the same file name are prefixed with just enough of their path to tell them
apart.

![Three init.lua buffers told apart by their parent directory](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/duplicates.png)

## Close icons

Each buffer has a close icon; a modified buffer shows a dot instead. `show_close_icon` adds
a close button at the right end of the tabline.

![Close icons, a modified-buffer dot and the tabline close button](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/close-icons.png)

## Re-ordering

![ui.lua moved to the end with :BufferLinesMoveNext](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/reorder.png)

Move buffers with `:BufferLinesMoveNext` / `:BufferLinesMovePrev`. This order can be
persisted between sessions (enabled by default).

## Picking

![Pick mode: one letter per buffer](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/pick.png)

See `:help bufferlines-pick`.

## Pinning

`:BufferLinesTogglePin` keeps a buffer at the front with a pin icon. Pins use the built-in
`pinned` group.

![README.md and config.lua pinned to the front](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/pinning.png)

## Custom areas

![Custom areas on both ends of the tabline](https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/custom-areas.png)

See `:help bufferlines-custom-areas`. Custom areas are single-row only and are not
supported with multiline.
