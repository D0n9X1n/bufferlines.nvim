#!/usr/bin/env bash
# Release preconditions. version TAG | on-main TAG | ci SHA. Exit non-zero on any violation.
set -euo pipefail
cmd="${1:?usage: release-gate.sh version|on-main|ci ARG}"; arg="${2:?missing argument}"
case "$cmd" in
  version)
    [[ "$arg" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)(-rc\.[0-9]+)?$ ]] || { echo "invalid release tag: $arg" >&2; exit 1; }
    base="${BASH_REMATCH[1]}"; pre="${BASH_REMATCH[2]}"
    have="$(sed -nE 's/^return "([^"]+)"$/\1/p' lua/bufferlines/version.lua)"
    [[ "$base" == "$have" ]] || { echo "tag $arg does not match version.lua $have" >&2; exit 1; }
    [[ -n "$pre" ]] && echo prerelease=true || echo prerelease=false ;;
  on-main)
    sha="$(git rev-parse --verify "${arg}^{commit}")"
    git merge-base --is-ancestor "$sha" "${MAIN_REF:-refs/remotes/origin/main}" || { echo "$arg is not on main" >&2; exit 1; } ;;
  ci)
    gh api "repos/${GITHUB_REPOSITORY:?}/actions/workflows/ci.yml/runs?head_sha=${arg}&per_page=100" | python3 -c '
import json, sys
sha = sys.argv[1]
ok = [r for r in json.load(sys.stdin).get("workflow_runs", [])
      if r.get("event") == "push" and r.get("head_branch") == "main" and r.get("conclusion") == "success" and r.get("head_sha") == sha]
sys.exit(0 if ok else f"no successful main push CI run for {sha}")' "$arg" ;;
  *) echo "unknown command: $cmd" >&2; exit 2 ;;
esac
