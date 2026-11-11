#!/usr/bin/env bash
# Mirror SOURCE_DIR/*.md onto the wiki's master by normal commit. Token via GIT_ASKPASS only, masked.
set -euo pipefail
[[ $# -eq 3 ]] || { echo "usage: $0 SOURCE_DIR WIKI_REMOTE SOURCE_SHA" >&2; exit 2; }
src="$1"; remote="$2"; sha="$3"
: "${WIKI_TOKEN:?WIKI_TOKEN is required}"; echo "::add-mask::${WIKI_TOKEN}"
[[ -d "$src" && ! -L "$src" ]] || { echo "wiki source must be a real directory" >&2; exit 1; }
shopt -s nullglob; pages=("$src"/*.md); (( ${#pages[@]} )) || { echo "no wiki pages" >&2; exit 1; }
for p in "${pages[@]}"; do [[ -f "$p" && ! -L "$p" ]] || { echo "refusing non-regular page: $p" >&2; exit 1; }; done
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
cat > "$work/askpass" <<'ASK'
#!/bin/sh
case "$1" in *Username*) printf '%s\n' "${WIKI_GIT_USER:-x-access-token}" ;; *) printf '%s\n' "$WIKI_TOKEN" ;; esac
ASK
chmod 700 "$work/askpass"; export GIT_ASKPASS="$work/askpass" GIT_TERMINAL_PROMPT=0 WIKI_TOKEN
git clone --quiet "$remote" "$work/wiki"
[[ "$(git -C "$work/wiki" rev-parse --abbrev-ref HEAD)" == master ]] || { echo "wiki must be on master" >&2; exit 1; }
for p in "$work/wiki"/*.md; do [[ ! -L "$p" ]] || { echo "refusing to replace wiki symlink $p" >&2; exit 1; }; done
find "$work/wiki" -maxdepth 1 -type f -name '*.md' -delete
cp -- "${pages[@]}" "$work/wiki/"
git -C "$work/wiki" add --all
if git -C "$work/wiki" diff --cached --quiet; then echo "wiki already matches ${sha}"; exit 0; fi
git -C "$work/wiki" -c user.name='github-actions[bot]' -c user.email='41898282+github-actions[bot]@users.noreply.github.com' \
  commit --quiet -m "Publish wiki from ${sha:0:7}"
git -C "$work/wiki" push --quiet origin HEAD:master; echo "published wiki from ${sha}"
