# 配置

[English](Configuration)

## `setup()` 接收一份完整配置

`require("bufferlines").setup(config)` **不是**增量式的选项更新。每次调用都会接收一份完整
配置。请保留你原始的配置表，以便之后恢复设置而不丢失自定义选项或高亮：

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

这一点在切换[多行渲染器](Multiline-Buffer-Tabs-zh-CN)时尤为重要：有些仅限原生模式的选项
必须从多行配置副本中移除，之后再恢复。

## 参考手册所在位置

完整的选项表、默认值、类型与校验规则位于生成的帮助文件中，其撰写源文件在
[`wiki/help/`](Documentation-Pipeline-zh-CN)：

```vim
:help bufferlines-configuration
```

按主题查阅：

| 主题 | 帮助标签 |
| --- | --- |
| 悬停事件 | `:help bufferlines-hover-events` |
| 样式与预设 | `:help bufferlines-styling`、`:help bufferlines-style-presets` |
| 标签页 | `:help bufferlines-tabpages` |
| 编号 | `:help bufferlines-numbers` |
| LSP 诊断 | `:help bufferlines-diagnostics` |
| 分组 | `:help bufferlines-groups` |
| 排序与过滤 | `:help bufferlines-sorting`、`:help bufferlines-filtering` |
| 命令 | `:help bufferlines-commands` |
| 自定义函数 | `:help bufferlines-functions` |
| 拾取 | `:help bufferlines-pick` |
| 映射 | `:help bufferlines-mappings` |
| 高亮 | `:help bufferlines-highlights` |
| 鼠标操作 | `:help bufferlines-mouse-actions` |
| 自定义区域 | `:help bufferlines-custom-areas` |
| 侧边栏偏移 | `:help bufferlines-sidebar-offset` |

## 贡献者与 AI 编码 agent

请阅读
[AGENTS.md](https://github.com/D0n9X1n/bufferlines.nvim/blob/HEAD/AGENTS.md)，
其中说明了架构、离线测试、兼容性边界与安全的开发流程。`CLAUDE.md` 为 Claude Code 引入了
这份共享指南。
