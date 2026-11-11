<h1 align="center">bufferlines.nvim</h1>

<p align="center">
  A <i>snazzy</i> 💅 buffer line for Neovim, written in Lua — with tabpage integration and
  opt-in <b>multiline</b> buffer tabs.
</p>

<p align="center">
  <a href="https://github.com/D0n9X1n/bufferlines.nvim/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/D0n9X1n/bufferlines.nvim/actions/workflows/ci.yml/badge.svg"></a>
  <a href="https://github.com/D0n9X1n/bufferlines.nvim/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/D0n9X1n/bufferlines.nvim?sort=semver"></a>
  <img alt="Neovim 0.8+" src="https://img.shields.io/badge/Neovim-0.8%2B-57A143?logo=neovim&amp;logoColor=white">
  <a href="LICENSE"><img alt="GPL-3.0" src="https://img.shields.io/badge/license-GPL--3.0-blue"></a>
</p>

<p align="center">
  <a href="https://github.com/D0n9X1n/bufferlines.nvim/wiki/Home">Wiki</a> ·
  <a href="README.zh-CN.md">中文说明</a> ·
  <a href="#migrating-from-bufferlinenvim">Migrating from bufferline.nvim</a> ·
  <a href="AGENTS.md">AI agent guide</a>
</p>

![Default bufferlines: file icons, a diagnostics badge on ui.lua and the selected-buffer indicator](wiki/assets/default.png)

**Multiline buffer tabs** — wrap every open buffer into rows above the editor, beside a
full-height file explorer:

![Multiline buffer tabs: three wrapped rows of tabs to the right of a file-explorer sidebar](wiki/assets/multiline-sidebar.png)

| Sloped separators | Buffer picking | Groups and pins |
| --- | --- | --- |
| ![Sloped separator style](wiki/assets/slope.png) | ![Pick mode: one letter per buffer](wiki/assets/pick.png) | ![Lua and Docs group labels with a pinned buffer](wiki/assets/groups.png) |

bufferlines.nvim continues [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim)
under a new name. The default look is unchanged; the native single-row renderer is still
the default and supports Neovim 0.8+.

<!--toc:start-->

- [Installation](#installation)
- [Requirements](#requirements)
- [Usage](#usage)
- [Configuration](#configuration)
- [Migrating from bufferline.nvim](#migrating-from-bufferlinenvim)
- [Features](#features)
- [How do I see only buffers per tab?](#how-do-i-see-only-buffers-per-tab)
- [Caveats](#caveats)
- [FAQ](#faq)
- [Tests](#tests)
- [Acknowledgements](#acknowledgements)
- [License](#license)
<!--toc:end-->

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "D0n9X1n/bufferlines.nvim",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    vim.opt.termguicolors = true
    require("bufferlines").setup({})
  end,
}
```

`version = "*"` follows the latest stable release. Other plugin managers:
[Installation and Usage](https://github.com/D0n9X1n/bufferlines.nvim/wiki/Installation-and-Usage).

## Requirements

- Neovim 0.8+ (0.12+ for [multiline buffer tabs](#multiline-buffer-tabs))
- `termguicolors`, a patched font (see [nerd fonts](https://github.com/ryanoasis/nerd-fonts))
  and optionally [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
- A colorscheme (either your custom highlight or a maintained one somewhere)

## Usage

Setup examples and mouse controls are in
[Installation and Usage](https://github.com/D0n9X1n/bufferlines.nvim/wiki/Installation-and-Usage).
For the complete offline reference, use `:help bufferlines.nvim`.

## Configuration

`setup()` takes a **complete** configuration, not an incremental options update. See
`:h bufferlines-configuration` and
[Configuration](https://github.com/D0n9X1n/bufferlines.nvim/wiki/Configuration).

Contributors and AI coding agents: read [AGENTS.md](AGENTS.md) for architecture, offline
tests, compatibility boundaries, and safe development workflows. [CLAUDE.md](CLAUDE.md)
imports that shared guide for Claude Code.

## Migrating from bufferline.nvim

Every public name gains an `s`; casing is unchanged. Colours and layout are identical.

| Before (bufferline.nvim) | After (bufferlines.nvim) |
| --- | --- |
| `require("bufferline")` | `require("bufferlines")` |
| `:BufferLinePick` and all 18 `:BufferLine*` commands | `:BufferLinesPick`, `:BufferLines*` |
| `BufferLineFill` and every `BufferLine*` highlight group | `BufferLinesFill`, `BufferLines*` |
| filetype `bufferline` (multiline header) | filetype `bufferlines` |
| `vim.g.BufferlinePositions`, `vim.g.BufferlinePinnedBuffers` | `vim.g.BufferlinesPositions`, `vim.g.BufferlinesPinnedBuffers` (old values are read once automatically) |
| `:h bufferline` | `:h bufferlines` |
| `show_buffer_default_icon`, `pick_buffer`, `go_to_buffer`, `sort_buffers_by`, `close_buffer_with_pick` | removed (deprecated since v4.0.0) |

There is no `require("bufferline")` shim, so both plugins cannot be installed at once —
replace the old plugin spec.

## Features

- Colours derived from colorscheme where possible.
- Sort buffers by `extension`, `directory` or pass in a custom compare function.
- Configuration via lua functions for greater customization.

Details and screenshots for every feature below:
[Features](https://github.com/D0n9X1n/bufferlines.nvim/wiki/Features).

#### Multiline buffer tabs

Keep more open buffers in view instead of squeezing them into one row. The opt-in multiline
header wraps tabs to the available editor width while full-height
sidebars stay outside the header, as shown in the preview at the top.

- **Adaptive rows:** the header grows up to a configurable row limit; overflow controls
  and the mouse wheel reveal hidden rows. Switching buffers reveals the active row.
- **Keyboard and mouse navigation:** move through candidates without switching the
  editor buffer until you confirm, or click a tab to select it.
- **Familiar styling:** icons, diagnostics, groups, pins and per-buffer close actions
  work across rows, including slanted styling like the screenshot.

Available in every release; requires **Neovim 0.12+** in buffer mode.
Native single-row mode remains the default with Neovim 0.8+ support.

The header uses real split height. Custom areas, hover reveal and native tabpage controls
are single-row-only; multiline must be disabled before saving a built-in session.
There is no native single-row fallback while multiline is enabled.

Installation, settings, keyboard controls and lifecycle limitations:
[Multiline Buffer Tabs](https://github.com/D0n9X1n/bufferlines.nvim/wiki/Multiline-Buffer-Tabs)
or `:help bufferlines-multiline`.

---

#### Alternate styling

##### Slanted tabs

![slanted tabs](https://user-images.githubusercontent.com/22454918/111992989-fec39b80-8b0d-11eb-851b-010641196a04.png)

##### Sloped tabs

![sloped tabs](https://user-images.githubusercontent.com/22454918/220115787-0ba2264f-1cf5-4f18-a322-7c7cfa3d8f42.png)

see: `:h bufferlines-styling`

---

#### Hover events

**NOTE**: this is _only_ available for >= neovim 0.8+

![hover-event-preview](https://user-images.githubusercontent.com/22454918/189106657-163b0550-897c-42c8-a571-d899bdd69998.gif)

see `:help bufferlines-hover-events` for more information on configuration

---

#### Underline indicator

<img width="1355" alt="Screen Shot 2022-08-22 at 09 14 24" src="https://user-images.githubusercontent.com/22454918/185873089-2ae20db0-f292-4d96-afe4-ef0683a60709.png">

---

#### Tabpages

<img width="800" alt="Screen Shot 2022-03-08 at 17 39 57" src="https://user-images.githubusercontent.com/22454918/157337891-1848da24-69d6-4970-96ee-cf65b2a25c46.png">

Set `mode = "tabs"` to show only tabpages. Sorting and grouping do not work in this mode.

---

#### LSP indicators

![LSP Indicator](https://user-images.githubusercontent.com/22454918/113215394-b1180300-9272-11eb-9632-8a9f9aae99fa.png)

Set `diagnostics = "nvim_lsp" | "coc"` to get an indicator for buffers with errors.

![diagnostics_indicator](https://user-images.githubusercontent.com/4028913/112573484-9ee92100-8da9-11eb-9ffd-da9cb9cae3a6.png)

Indicators can also be reported conditionally, based on buffer context.

![current](https://user-images.githubusercontent.com/58056722/119390133-e5d19500-bccc-11eb-915d-f5d11f8e652c.jpeg)
![visible](https://user-images.githubusercontent.com/58056722/119390136-e66a2b80-bccc-11eb-9a87-e622e3e20563.jpeg)

Snippets and the `diagnostics_indicator` signature:
[Features](https://github.com/D0n9X1n/bufferlines.nvim/wiki/Features#lsp-indicators).

---

#### Groups

![bufferline_group_toggle](https://user-images.githubusercontent.com/22454918/132410772-0a4c0b95-63bb-4281-8a4e-a652458c3f0f.gif)

see `:help bufferlines-groups` for more information on how to set these up

---

#### Sidebar offsets

![explorer header](https://user-images.githubusercontent.com/22454918/117363338-5fd3e280-aeb4-11eb-99f2-5ec33dff6f31.png)

---

#### Numbers

![bufferlines with numbers](https://user-images.githubusercontent.com/22454918/119562833-b5f2c200-bd9e-11eb-81d3-06876024bf30.png)

![numbers](https://user-images.githubusercontent.com/22454918/130784872-936d4c55-b9dd-413b-871d-7bc66caf8f17.png)

see `:help bufferlines-numbers` for more details

---

#### Unique names

![duplicate names](https://user-images.githubusercontent.com/22454918/111993343-6da0f480-8b0e-11eb-8d93-44019458d2c9.png)

---

#### Close icons

![close button](https://user-images.githubusercontent.com/22454918/111993390-7a254d00-8b0e-11eb-9951-43b4350f6a29.gif)

---

#### Re-ordering

![re-order buffers](https://user-images.githubusercontent.com/22454918/111993463-91643a80-8b0e-11eb-87f0-26acfe92c021.gif)

This order can be persisted between sessions (enabled by default).

---

#### Picking

![bufferlines pick](https://user-images.githubusercontent.com/22454918/111993296-5bbf5180-8b0e-11eb-9ad9-fcf9619436fd.gif)

---

#### Pinning

<img width="899" alt="Screen Shot 2022-03-31 at 18 13 50" src="https://user-images.githubusercontent.com/22454918/161112867-ba48fdf6-42ee-4cd3-9e1a-7118c4a2738b.png">

---

#### Custom areas

![custom area](https://user-images.githubusercontent.com/22454918/118527523-4d219f00-b739-11eb-889f-60fb06fd71bc.png)

see `:help bufferlines-custom-areas`

## How do I see only buffers per tab?

This behaviour is _not native in neovim_. You can get it using
[scope.nvim](https://github.com/tiagovla/scope.nvim) with this plugin — see
[FAQ and Caveats](https://github.com/D0n9X1n/bufferlines.nvim/wiki/FAQ-and-Caveats).

## Caveats

This plugin is opinionated about how the tabline looks, relies on basic highlights being
set by your colour scheme (`Normal`, `String`, `TabLineSel`, `Comment`), and depends on
darkening, so low-contrast schemes suffer. Full list:
[FAQ and Caveats](https://github.com/D0n9X1n/bufferlines.nvim/wiki/FAQ-and-Caveats#caveats).

## FAQ

- **Why isn't the buffer line appearing?** Usually a clash with another tabline plugin
  (`airline`, `lightline`, `GuiTabline`).
- **Doesn't this plugin go against the "vim way"?** Short answer: no.

Both answered in full in
[FAQ and Caveats](https://github.com/D0n9X1n/bufferlines.nvim/wiki/FAQ-and-Caveats).

## Tests

Test commands, offline dependencies and contributor guidance:
[Testing and Development](https://github.com/D0n9X1n/bufferlines.nvim/wiki/Testing-and-Development)
and [Documentation Pipeline](https://github.com/D0n9X1n/bufferlines.nvim/wiki/Documentation-Pipeline).

## Acknowledgements

bufferlines.nvim is a fork of [akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim)
by Akin Sowemimo and contributors. Thank you for years of work on the original plugin — its
design, docs and most of the screenshots in the feature list below are theirs. The
plugin's look was inspired by DOOM Emacs and
[centaur tabs](https://github.com/ema2159/centaur-tabs).

![Original bufferline.nvim demo](https://user-images.githubusercontent.com/22454918/111992693-9c6a9b00-8b0d-11eb-8c39-19db58583061.gif)

## License

[GPL-3.0](LICENSE), unchanged from the upstream project.
