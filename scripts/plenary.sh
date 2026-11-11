#!/usr/bin/env bash
# scripts/plenary.sh: run a Plenary directory/file target; fail on failures, errors or Lua tracebacks.
set -uo pipefail
target="${1:-tests/}"; nvim_bin="${NVIM:-nvim}"
out="$("$nvim_bin" --headless -i NONE -n -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory $target {minimal_init='tests/minimal_init.lua', sequential=true}" 2>&1)"; status=$?
printf '%s\n' "$out"
clean="$(printf '%s' "$out" | sed $'s/\x1b\\[[0-9;]*m//g')"
if grep -qE '^(Failed|Errors)[[:space:]]*:[[:space:]]*[1-9]' <<<"$clean" || grep -q 'stack traceback' <<<"$clean"; then exit 1; fi
grep -qE '^Success[[:space:]]*:[[:space:]]*[0-9]+' <<<"$clean" || exit 1
exit "$status"
