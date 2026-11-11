# bufferlines.nvim

[English](Home)

一个为 Neovim 打造的 _时髦_ 💅 buffer 行（含标签页集成），使用 **lua** 编写。

本 wiki 是该分支**唯一的文档撰写来源**。Vim 帮助文件 `doc/bufferlines.txt` 由
[`wiki/help/`](Documentation-Pipeline-zh-CN) 生成并提交到 Git，因此任何安装都可以使用
`:help bufferlines.nvim`。

## 指南

| 页面 | 内容 |
| --- | --- |
| [安装与使用](Installation-and-Usage-zh-CN) | 环境要求、插件管理器、初次配置 |
| [配置](Configuration-zh-CN) | `setup()` 语义、各选项所在位置 |
| [多行 buffer 标签](Multiline-Buffer-Tabs-zh-CN) | 可选启用的多行渲染器及其完整契约 |
| [功能](Features-zh-CN) | 样式、诊断、分组、拾取、固定、侧边栏偏移 |
| [常见问题与注意事项](FAQ-and-Caveats-zh-CN) | 常见故障与已知限制 |
| [测试与开发](Testing-and-Development-zh-CN) | 离线测试运行、agent 指南 |
| [文档流水线](Documentation-Pipeline-zh-CN) | wiki 如何生成并发布帮助文件 |

## 参考手册

完整的选项、高亮、命令与映射参考位于生成的 Vim 帮助文件中。在 Neovim 内阅读：

```vim
:help bufferlines.nvim
:help bufferlines-configuration
:help bufferlines-multiline
```

该参考手册的撰写源文件是仓库中的 [`wiki/help/`](Documentation-Pipeline-zh-CN)。请只编辑
其中的片段，不要编辑 `doc/bufferlines.txt`。

**语言说明**：Vim 帮助文件（`:help`）的正文目前仅提供英文，这是 Neovim 帮助格式的现状。
本 wiki 的中文页面以散文形式覆盖了相同的内容，包括多行渲染器的完整契约。

## 上游

本仓库是 [`akinsho/bufferline.nvim`](https://github.com/akinsho/bufferline.nvim) 的
`D0n9X1n/bufferlines.nvim` 分支，保留上游署名与许可证。
