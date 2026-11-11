# Installation and Usage

[简体中文](Installation-and-Usage-zh-CN)

## Requirements

- Neovim 0.8+ for the default native single-row renderer.
- Neovim 0.12+ for the opt-in [multiline renderer](Multiline-Buffer-Tabs).
- A patched font (see [nerd fonts](https://github.com/ryanoasis/nerd-fonts)).
- A colorscheme. The plugin derives colours from `Normal`, `String`, `TabLineSel`
  (`WildMenu` as fallback) and `Comment`.

## Install

Releases are tagged `vX.Y.Z`; `version = "*"` tracks the latest stable release. The
multiline renderer ships in every release (opt-in, Neovim 0.12+) — see
[Multiline Buffer Tabs](Multiline-Buffer-Tabs). Do not install bufferlines.nvim alongside
`akinsho/bufferline.nvim`; both own the tabline. Replace that entry and follow
[Migrating from bufferline.nvim](https://github.com/D0n9X1n/bufferlines.nvim#migrating-from-bufferlinenvim).

**Lua**

```lua
-- using lazy.nvim
{ "D0n9X1n/bufferlines.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" }

-- using packer.nvim
use { "D0n9X1n/bufferlines.nvim", tag = "*", requires = "nvim-tree/nvim-web-devicons" }
```

**Vimscript**

```vim
Plug 'nvim-tree/nvim-web-devicons' " Recommended (for coloured icons)
Plug 'D0n9X1n/bufferlines.nvim', { 'tag': '*' }
```

## Usage

You need `termguicolors` for this plugin to work as intended, as it reads the hex `gui`
colour values of various highlight groups.

**Lua**

```lua
vim.opt.termguicolors = true
require("bufferlines").setup{}
```

**Vimscript**

```vim
" In your init.lua or init.vim
set termguicolors
lua << EOF
require("bufferlines").setup{}
EOF
```

You can close buffers by clicking the close icon or by _right clicking_ the tab anywhere.

Full usage reference: `:help bufferlines-usage`.
