#!/usr/bin/env bash
# scripts/native-specs.sh: each native (non-multiline, non-golden) spec in its own process on $NVIM.
set -uo pipefail
cd "$(dirname "$0")/.."; rc=0; log="$(mktemp)"; trap 'rm -f "$log"' EXIT
for spec in tests/*_spec.lua; do
  case "$(basename "$spec")" in multiline_*|golden_spec.lua) continue ;; esac
  scripts/plenary.sh "$spec" >"$log" 2>&1 && echo "ok $spec" || { echo "FAIL $spec"; cat "$log"; rc=1; }
done
exit "$rc"
