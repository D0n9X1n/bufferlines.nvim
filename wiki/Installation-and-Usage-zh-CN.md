# 安装与使用

[English](Installation-and-Usage)

## 环境要求

- 默认的原生单行渲染器需要 Neovim 0.8+。
- 可选启用的[多行渲染器](Multiline-Buffer-Tabs-zh-CN)需要 Neovim 0.12+。
- 一款补丁字体（参见 [nerd fonts](https://github.com/ryanoasis/nerd-fonts)）。
- 一款配色方案。本插件会从 `Normal`、`String`、`TabLineSel`（回退为 `WildMenu`）和
  `Comment` 中取色。

## 安装

版本以 `vX.Y.Z` 打标签；`version = "*"` 跟随最新稳定版。多行渲染器包含在每个版本中（可选启用，
需要 Neovim 0.12+），参见[多行 buffer 标签](Multiline-Buffer-Tabs-zh-CN)。请勿与
`akinsho/bufferline.nvim` 同时安装，二者都会接管 tabline。请替换原有声明，并参阅
[从 bufferline.nvim 迁移](https://github.com/D0n9X1n/bufferlines.nvim/blob/main/README.zh-CN.md#从-bufferlinenvim-迁移)。

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

## 使用

本插件需要 `termguicolors` 才能按预期工作，因为它会读取各高亮组的 `gui` 十六进制色值。

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

可以点击关闭图标来关闭 buffer，也可以在标签的任意位置_右键点击_。

完整使用参考：`:help bufferlines-usage`。
