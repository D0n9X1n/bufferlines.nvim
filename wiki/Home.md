# bufferlines.nvim

[简体中文](Home-zh-CN)

A _snazzy_ 💅 buffer line (with tabpage integration) for Neovim built using **lua**.

This wiki is the **only authored documentation source** for this fork. The Vim help
file `doc/bufferlines.txt` is generated from [`wiki/help/`](Documentation-Pipeline) and
committed to Git so `:help bufferlines.nvim` works for every install.

## Guides

| Page | What it covers |
| --- | --- |
| [Installation and Usage](Installation-and-Usage) | Requirements, plugin managers, first setup |
| [Configuration](Configuration) | `setup()` semantics, where options live |
| [Multiline Buffer Tabs](Multiline-Buffer-Tabs) | The opt-in multi-row renderer and its full contract |
| [Features](Features) | Styling, diagnostics, groups, picking, pinning, offsets |
| [FAQ and Caveats](FAQ-and-Caveats) | Common breakage and known limits |
| [Testing and Development](Testing-and-Development) | Offline test runs, agent guide |
| [Documentation Pipeline](Documentation-Pipeline) | How the wiki generates and publishes the help file |

## Reference

The complete option, highlight, command and mapping reference lives in the generated
Vim help file. Read it in Neovim:

```vim
:help bufferlines.nvim
:help bufferlines-configuration
:help bufferlines-multiline
```

The authored source for that reference is [`wiki/help/`](Documentation-Pipeline) in the
repository. Edit the fragments there, never `doc/bufferlines.txt`.

## Upstream

This is the `D0n9X1n/bufferlines.nvim` fork of
[`akinsho/bufferline.nvim`](https://github.com/akinsho/bufferline.nvim). Upstream
attribution and the license are retained.
