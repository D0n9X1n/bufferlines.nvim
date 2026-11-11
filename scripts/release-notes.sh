#!/usr/bin/env bash
# Release notes for TAG. Predecessor = newest version tag older than TAG reachable from TAG (same-SHA rc counts).
set -euo pipefail
tag="${1:?usage: release-notes.sh TAG}"
[[ "$(git rev-parse --is-shallow-repository)" == false ]] || { echo "full history required" >&2; exit 2; }
git rev-parse --verify "${tag}^{commit}" >/dev/null
read -r prev stable_before < <(git tag --merged "$tag" --list 'v*' | python3 -c '
import re, sys
def key(t):
    m = re.fullmatch(r"v(\d+)\.(\d+)\.(\d+)(?:-rc\.(\d+))?", t)
    return None if not m else (int(m[1]), int(m[2]), int(m[3]), 1 if m[4] is None else 0, int(m[4] or 0))
cur = key(sys.argv[1]); older = sorted((key(t), t) for t in sys.stdin.read().split() if key(t) and key(t) < cur)
stable = any(k[3] == 1 for k, _ in older)
print(older[-1][1] if older else "-", int(stable))' "$tag")
echo "# bufferlines.nvim ${tag}"; echo
if [[ "$prev" != "-" ]]; then
  echo "## Changes since ${prev}"; echo
  log="$(git log --no-merges --pretty=format:'- %s (%h)' "${prev}..${tag}")"; echo "${log:-- None.}"; echo
fi
if [[ "$stable_before" == 0 ]]; then
  echo "## Initial release"; echo
  echo "- First release of bufferlines.nvim, a renamed fork of akinsho/bufferline.nvim v4.10.3 (GPL-3.0)."
  echo "- Module \`bufferlines\`, commands \`:BufferLines*\`, highlights \`BufferLines*\`; no \`require(\"bufferline\")\` shim."
  echo "- Native single-row renderer for Neovim 0.8+; opt-in multiline renderer for Neovim 0.12+."
  echo "- Persisted sort order and pins are read once from the old \`vim.g.Bufferline*\` keys."; echo
fi
echo "## Verification"; echo
echo "- Tag is on main, CI passed on the exact commit, and the tag matches lua/bufferlines/version.lua."
