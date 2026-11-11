#!/usr/bin/env bash
# Capture one preview scene as HTML from an isolated Neovim inside a private tmux server.
set -euo pipefail
scene="$1"; out="$2"; root="$(cd "$(dirname "$0")/../.." && pwd)"; tmp="$(mktemp -d)"
sock="$tmp/tmux.sock"
trap '[ -S "$sock" ] && tmux -S "$sock" kill-server 2>/dev/null; rm -rf "$tmp"' EXIT
tmux -S "$sock" -f /dev/null new-session -d -x 140 -y 24 -s prev \
  "cd '$root' && env -i HOME='$HOME' PATH='$PATH' TERM=tmux-256color COLORTERM=truecolor NVIM_TEST_DEPS='$NVIM_TEST_DEPS' PREVIEW_SCENE='$scene' PREVIEW_READY='$tmp/ready' XDG_CONFIG_HOME='$tmp/c' XDG_DATA_HOME='$tmp/d' XDG_STATE_HOME='$tmp/s' nvim -i NONE -n -u scripts/preview/scene.lua"
tmux -S "$sock" set -g default-terminal tmux-256color >/dev/null
tmux -S "$sock" set -ga terminal-overrides ',*:Tc' >/dev/null
for _ in $(seq 100); do [ -f "$tmp/ready" ] && break; sleep 0.1; done
[ -f "$tmp/ready" ] || { echo "scene $scene never became ready" >&2; exit 1; }
sleep 1
tmux -S "$sock" capture-pane -p -e -J -t prev > "$tmp/pane.ansi"
python3 "$root/scripts/preview/ansi2html.py" "$tmp/pane.ansi" "$out"
