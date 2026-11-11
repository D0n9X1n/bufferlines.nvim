#!/usr/bin/env python3
"""Offline tests for scripts/publish-wiki.sh against local bare repositories and a logging git shim."""
from __future__ import annotations
import os, shutil, subprocess, sys, tempfile
from pathlib import Path
ROOT = Path(__file__).resolve().parent.parent; SCRIPT = ROOT / "scripts" / "publish-wiki.sh"
TOKEN = "ghs_FAKE_TOKEN_123"; REAL_GIT = shutil.which("git"); failures: list[str] = []
ENV = {**os.environ, "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@e.invalid", "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@e.invalid"}
def check(c: bool, m: str) -> None: (None if c else failures.append(m))
def git(*a: str, cwd: Path) -> str: return subprocess.run([REAL_GIT, *a], cwd=cwd, env=ENV, capture_output=True, text=True, check=True).stdout.strip()
def setup(tmp: Path) -> Path:
    remote = tmp / "wiki.git"; git("init", "-q", "--bare", "-b", "master", str(remote), cwd=tmp)
    seed = tmp / "seed"; git("clone", "-q", str(remote), str(seed), cwd=tmp); git("checkout", "-q", "-b", "master", cwd=seed)
    (seed / "Home.md").write_text("default\n"); (seed / "Old-Page.md").write_text("stale\n"); (seed / "zh-CN-Home.md").write_text("old\n")
    git("add", ".", cwd=seed); git("commit", "-qm", "seed", cwd=seed); git("push", "-q", "origin", "master", cwd=seed)
    shim = tmp / "bin"; shim.mkdir()
    (shim / "git").write_text(f'#!/bin/sh\nprintf "%s\\n" "$*" >> "{tmp}/argv.log"\n'
        f'if [ -n "$GIT_ASKPASS" ]; then "$GIT_ASKPASS" "Username for x" >> "{tmp}/askpass.log"; "$GIT_ASKPASS" "Password for x" >> "{tmp}/askpass.log"; fi\n'
        f'exec "{REAL_GIT}" "$@"\n'); (shim / "git").chmod(0o755)
    return remote
def run(tmp: Path, src: Path, remote: Path, token: str | None = TOKEN) -> subprocess.CompletedProcess[str]:
    env = {**ENV, "PATH": f"{tmp / 'bin'}:{os.environ['PATH']}"}
    if token: env["WIKI_TOKEN"] = token
    return subprocess.run([str(SCRIPT), str(src), str(remote), "abc1234def"], env=env, capture_output=True, text=True)
def pages(tmp: Path, remote: Path) -> dict[str, str]:
    out = tmp / f"view{len(list(tmp.glob('view*')))}"; git("clone", "-q", str(remote), str(out), cwd=tmp)
    return {p.name: p.read_text() for p in out.glob("*.md")}
def source(tmp: Path) -> Path:
    src = tmp / "src"; src.mkdir()
    for name, text in {"Home.md": "# H\n\n[简体中文](Home-zh-CN)\n", "Home-zh-CN.md": "# 首页\n\n[English](Home)\n", "_Sidebar.md": "- [Home](Home)\n"}.items():
        (src / name).write_text(text)
    return src
def main() -> int:
    check(os.access(SCRIPT, os.X_OK), "publish-wiki.sh is not executable")
    with tempfile.TemporaryDirectory() as d:
        tmp = Path(d); remote = setup(tmp); src = source(tmp); before = git("rev-parse", "master", cwd=remote)
        r = run(tmp, src, remote); check(r.returncode == 0, f"publish failed: {r.stderr}")
        got = pages(tmp, remote); want = {p.name: p.read_text() for p in src.glob("*.md")}
        check(got == want, f"mirror mismatch: {sorted(got)} vs {sorted(want)}")
        check("Old-Page.md" not in got and "zh-CN-Home.md" not in got, "stale pages survived")
        check("_Sidebar.md" in got and "Home-zh-CN.md" in got, "sidebar or -zh-CN page missing")
        after = git("rev-parse", "master", cwd=remote)
        check(subprocess.run([REAL_GIT, "merge-base", "--is-ancestor", before, after], cwd=remote).returncode == 0, "master was not advanced by a normal commit")
        r2 = run(tmp, src, remote); check(r2.returncode == 0 and "already matches" in r2.stdout, "unchanged input was not a no-op")
        check(git("rev-parse", "master", cwd=remote) == after, "no-op created a commit")
        logs = (r.stdout + r.stderr + r2.stdout + r2.stderr)
        check(f"::add-mask::{TOKEN}" in r.stdout, "token not masked")
        check(TOKEN not in logs.replace(f"::add-mask::{TOKEN}", ""), "token leaked to output")
        check(TOKEN not in (tmp / "argv.log").read_text(), "token in git argv")
        check(TOKEN in (tmp / "askpass.log").read_text(), "askpass did not supply the token")
        for f in (SCRIPT, ROOT / ".github/workflows/publish-wiki.yml", tmp / "argv.log"):
            if f.exists(): check("x-access-token:" not in f.read_text(), f"x-access-token: found in {f.name}")
        (src / "Link.md").symlink_to(src / "Home.md"); check(run(tmp, src, remote).returncode != 0, "symlinked page accepted"); (src / "Link.md").unlink()
        (tmp / "srclink").symlink_to(src); check(run(tmp, tmp / "srclink", remote).returncode != 0, "symlinked source dir accepted")
        check(run(tmp, src, remote, token=None).returncode != 0, "missing token accepted")
    print("\n".join(f"FAIL - {f}" for f in failures) or "ok - wiki publish checks passed")
    return 1 if failures else 0
if __name__ == "__main__": raise SystemExit(main())
