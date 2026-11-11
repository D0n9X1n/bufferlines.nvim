#!/usr/bin/env python3
"""Workflow policy: pinned actions, read-only defaults, one write job per publisher, tested scripts executable."""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
G = ROOT / ".github"
fails: list[str] = []


def need(cond: object, msg: str) -> None:
    if not cond:
        fails.append(msg)


wf = {p.name: p.read_text(encoding="utf-8") for p in (G / "workflows").glob("*.y*ml")}
need(sorted(wf) == ["ci.yml", "publish-wiki.yml", "release.yml"], f"workflow set {sorted(wf)}")
for name, text in wf.items():
    for use in re.findall(r"uses:\s*(\S+)", text):
        need(re.search(r"@[0-9a-f]{40}$", use), f"{name}: unpinned {use}")
    need(re.search(r"^permissions:\n  contents: read$", text, re.M), f"{name}: default must be contents: read")
    need("x-access-token:" not in text and "--force" not in text, f"{name}: token URL or force push")

release = wf.get("release.yml", "")
need(release.count("contents: write") == 1 and "needs: validate" in release, "release: only publish writes")
need("tags:" in release and "v*.*.*" in release, "release trigger")
wiki = wf.get("publish-wiki.yml", "")
need("branches: [main]" in wiki and "scripts/publish-wiki.sh" in wiki, "wiki trigger/script")
need(wiki.count("contents: write") == 1, "wiki: only publish writes")
ci = wf.get("ci.yml", "")
for s in ("v2.5.2", "actionlint", "test_release.sh", "check_wiki.py", "v0.8.3", "v0.9.5", "v0.10.4", "v0.11.7",
          "v0.12.6", "74b06c6c75e4eeb3108ec01852001636d85a932b", "ec309a0eaff6ea967e58c275996155ab5c16938d"):
    need(s in ci, f"ci missing {s}")

dependabot = G / "dependabot.yml"
need(dependabot.exists() and "github-actions" in dependabot.read_text(encoding="utf-8"), "dependabot")
for s in ("plenary.sh", "native-specs.sh", "release-gate.sh", "release-notes.sh", "test_release.sh",
          "publish-wiki.sh", "ci-setup.sh"):
    mode = subprocess.run(["git", "ls-files", "-s", f"scripts/{s}"], capture_output=True, text=True, cwd=ROOT).stdout
    need(mode.startswith("100755"), f"scripts/{s} not committed executable")
need(not (G / "FUNDING.yml").exists() and not (G / "release.yaml").exists(), "FUNDING/release.yaml must be gone")

print("\n".join("FAIL - " + f for f in fails) or "ok - workflow policy")
sys.exit(1 if fails else 0)
