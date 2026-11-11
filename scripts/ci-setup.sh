#!/usr/bin/env bash
# Install Neovim VERSION (release asset ASSET) and the pinned test deps; exports PATH and NVIM_TEST_DEPS for later steps.
set -euo pipefail
version="$1"; asset="$2"; dir="$RUNNER_TEMP/nvim"; deps="$RUNNER_TEMP/deps"
mkdir -p "$dir" "$deps"
gh release download "$version" --repo neovim/neovim --pattern "$asset" --dir "$dir"
tar -xzf "$dir/$asset" -C "$dir"
echo "$dir/${asset%.tar.gz}/bin" >> "$GITHUB_PATH"
echo "NVIM_TEST_DEPS=$deps" >> "$GITHUB_ENV"
clone() {
  git init -q "$deps/$2"
  git -C "$deps/$2" fetch -q --depth 1 "https://github.com/$1.git" "$3"
  git -C "$deps/$2" checkout -q FETCH_HEAD
}
clone nvim-lua/plenary.nvim plenary.nvim "$PLENARY_SHA"
clone nvim-tree/nvim-web-devicons nvim-web-devicons "$DEVICONS_SHA"
