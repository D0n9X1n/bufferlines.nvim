#!/usr/bin/env python3
"""Validate wiki/: -zh-CN counterparts, line-3 language switch, internal links, _Sidebar and Home coverage."""
from __future__ import annotations

import re
import sys
from pathlib import Path

SUFFIX = "-zh-CN"
LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)\)")
FENCE = re.compile(r"^\s*(```|~~~).*?^\s*\1", re.M | re.S)


def links(text: str) -> list[str]:
    """Relative link targets outside fenced code, without anchors."""
    return [
        t.split("#")[0]
        for t in LINK.findall(FENCE.sub("", text))
        if not re.match(r"[a-z]+:", t) and not t.startswith("#")
    ]


def check(root: Path) -> list[str]:
    pages = {p.stem: p.read_text(encoding="utf-8") for p in root.glob("*.md")}
    errs: list[str] = []
    stems = {s for s in pages if s != "_Sidebar"}
    en = {s for s in stems if not s.endswith(SUFFIX)}
    zh = stems - en
    for s in sorted(en):
        if s + SUFFIX not in pages:
            errs.append(f"{s}: missing counterpart {s}{SUFFIX}")
    for s in sorted(zh):
        if s[: -len(SUFFIX)] not in pages:
            errs.append(f"{s}: missing counterpart {s[:-len(SUFFIX)]}")
    for s in sorted(stems):
        lines = pages[s].splitlines()
        other = s[: -len(SUFFIX)] if s in zh else s + SUFFIX
        if len(lines) < 3 or f"]({other})" not in lines[2]:
            errs.append(f"{s}: line 3 must link to {other}")
    for s, text in pages.items():
        for t in links(text):
            if t and t not in pages and not (root / t).exists():
                errs.append(f"{s}: broken link {t}")
    side = set(links(pages.get("_Sidebar", "")))
    errs += [f"_Sidebar: sidebar misses {s}" for s in sorted(stems - side)]
    for home, group in (("Home", en), ("Home" + SUFFIX, zh)):
        linked = set(links(pages.get(home, "")))
        errs += [f"{home}: Home misses {s}" for s in sorted(group - linked - {home})]
    return errs


if __name__ == "__main__":
    e = check(Path(__file__).resolve().parent.parent / "wiki")
    print("\n".join(e) or "ok - wiki structure valid")
    sys.exit(1 if e else 0)
