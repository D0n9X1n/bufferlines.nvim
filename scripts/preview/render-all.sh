#!/usr/bin/env bash
# Capture every preview scene to OUT_DIR/<scene>.html; screenshot each page's #shot at 2x.
# Usage: NVIM_TEST_DEPS=... scripts/preview/render-all.sh OUT_DIR [SCENE...]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"; out="$1"; shift
mkdir -p "$out"
# scene|rows|window title
SCENES='
multiline-sidebar|14|multiline: 12 buffers beside a file explorer
multiline-overflow|12|multiline: max_rows = 2 with an overflow counter
multiline-navigate|12|multiline: keyboard navigation in the header
default|8|default
slant|8|separator_style = "slant"
slope|8|separator_style = "slope"
hover|8|hover reveals the close icon
underline|8|indicator = { style = "underline" }
tabpages|8|mode = "tabs"
diagnostics|8|diagnostics = "nvim_lsp"
groups|8|groups
offsets|8|offsets: File Explorer
numbers|8|numbers = "both"
duplicates|8|unique names
close-icons|8|close icons and a modified buffer
reorder|8|:BufferLinesMoveNext
pick|8|:BufferLinesPick
pinning|8|:BufferLinesTogglePin
custom-areas|8|custom_areas
'
while IFS='|' read -r scene rows title; do
  [ -n "$scene" ] || continue
  if [ $# -gt 0 ] && [[ " $* " != *" $scene "* ]]; then continue; fi
  bash "$here/capture.sh" "$scene" "$out/$scene.html" "$rows" "$title"
  echo "$scene"
done <<< "$SCENES"
