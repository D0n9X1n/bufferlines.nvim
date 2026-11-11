# Changelog

All notable changes to bufferlines.nvim are recorded here. Release notes on GitHub are
generated from the commits between tags.

## 1.0.0 - 2026-11-11

First release of bufferlines.nvim, a renamed and refactored fork of
[akinsho/bufferline.nvim](https://github.com/akinsho/bufferline.nvim). The default
rendering — colours, separators, indicators and layout — is byte-identical to the
original.

### Breaking

- Every public name gains an `s`, keeping its casing: module `require("bufferlines")`,
  18 commands `:BufferLines*`, highlight groups `BufferLines*`, filetype `bufferlines`,
  globals `nvim_bufferlines` / `___bufferlines_private`, augroups and `User` events,
  help tags `*bufferlines*`. There is no `require("bufferline")` shim.
- Removed long-deprecated surface: the `show_buffer_default_icon` option, the
  `pick_buffer`, `go_to_buffer`, `sort_buffers_by` and `close_buffer_with_pick`
  aliases, the deprecated group-matcher proxy and the unused window click handler.

### Added

- Opt-in multiline buffer tabs for Neovim 0.12+ (`options.multiline`), carried over
  from the MOSconfig fork.
- `require("bufferlines.version")`.
- Session order and pins saved under `vim.g.BufferlinePositions` /
  `vim.g.BufferlinePinnedBuffers` are read once into the new `Bufferlines*` keys; the
  old keys are never modified.

### Fixed

- A scrolled multiline header no longer snaps back to the current row when an unrelated
  window resizes (for example when quitting another tab).
- No `vim.tbl_flatten` deprecation notice on Neovim 0.10.
- Every module can be required on its own.
- Truncated names keep combining marks with their base character.

### Changed

- Internal refactors with rendering locked by golden tests: version checks live in one
  compat module, default highlights come from a declarative palette, buffer filtering
  and cell clipping each have one implementation, and all messages go through one
  notifier.
- CI tests the native renderer on Neovim 0.8.3, 0.9.5, 0.10.4 and 0.11.7 and the full
  suite on 0.12.6; releases are gated on green CI for the tagged commit.

History before 1.0.0: see the
[akinsho/bufferline.nvim changelog](https://github.com/akinsho/bufferline.nvim/blob/main/CHANGELOG.md)
(up to v4.9.1) and the MOSconfig fork releases (v4.10.0–v4.10.3).
