#!/usr/bin/env bash
# Offline release tests: fixture repo, stubbed gh. No network.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fails=0; ok() { echo "ok - $1"; }; bad() { echo "FAIL - $1"; fails=$((fails+1)); }
expect() { local d="$1"; shift; if "$@" >"$T/out" 2>&1; then ok "$d"; else bad "$d"; cat "$T/out"; fi; }
reject() { local d="$1"; shift; if "$@" >"$T/out" 2>&1; then bad "$d (accepted)"; else ok "$d"; fi; }
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid
export GITHUB_REPOSITORY=D0n9X1n/bufferlines.nvim MAIN_REF=main
git init -q -b main "$T/repo"; cd "$T/repo"; mkdir -p lua/bufferlines
echo 'return "1.0.0"' > lua/bufferlines/version.lua; git add .; git commit -qm "feat: initial bufferlines release"
SHA="$(git rev-parse HEAD)"; git tag v1.0.0-rc.1
git checkout -qb side; git commit -q --allow-empty -m side; git tag v1.0.0-side; git checkout -q main
mkdir "$T/bin"; printf '#!/bin/sh\ncat "%s/runs.json"\n' "$T" > "$T/bin/gh"; chmod +x "$T/bin/gh"; export PATH="$T/bin:$PATH"
G="$HERE/release-gate.sh"
expect "gate is executable" test -x "$G"
expect "rc is prerelease" bash -c "[ \"\$($G version v1.0.0-rc.1)\" = prerelease=true ]"
expect "stable is not prerelease" bash -c "[ \"\$($G version v1.0.0)\" = prerelease=false ]"
reject "version mismatch rejected" "$G" version v1.0.1
reject "malformed tag rejected" "$G" version 1.0.0
expect "tag on main accepted" "$G" on-main v1.0.0-rc.1
reject "tag not on main rejected" "$G" on-main v1.0.0-side
run() { printf '{"workflow_runs":[{"event":"%s","head_branch":"%s","conclusion":"%s","head_sha":"%s"}]}' "$@" > "$T/runs.json"; }
echo '{"workflow_runs":[]}' > "$T/runs.json"; reject "missing CI rejected" "$G" ci "$SHA"
run push main failure "$SHA"; reject "failed CI rejected" "$G" ci "$SHA"
run pull_request main success "$SHA"; reject "PR-only CI rejected" "$G" ci "$SHA"
run push main success 0000000000000000000000000000000000000000; reject "wrong SHA rejected" "$G" ci "$SHA"
run push feature success "$SHA"; reject "other-branch push rejected" "$G" ci "$SHA"
run push main success "$SHA"; expect "exact green main push accepted" "$G" ci "$SHA"
N="$HERE/release-notes.sh"
expect "notes script is executable" test -x "$N"
expect "root is parentless" bash -c '[ "$(git rev-list --parents -n1 HEAD | wc -w)" -eq 1 ]'
"$N" v1.0.0-rc.1 > "$T/rc.md"
expect "rc.1 is initial release" grep -q '^## Initial release' "$T/rc.md"
reject "rc.1 has no predecessor section" grep -q '^## Changes since' "$T/rc.md"
git tag v1.0.0; "$N" v1.0.0 > "$T/stable.md"
expect "v1.0.0 predecessor is rc.1" grep -q '^## Changes since v1.0.0-rc.1' "$T/stable.md"
expect "v1.0.0 lists no changes" grep -q '^- None\.$' "$T/stable.md"
expect "v1.0.0 keeps initial summary" grep -q '^## Initial release' "$T/stable.md"
reject "no HEAD^ or override in production" grep -qE 'HEAD\^|\^"\)|PREVIOUS_TAG|RELEASE_FIRST' "$N"
echo "$fails failure(s)"; [ "$fails" -eq 0 ]
