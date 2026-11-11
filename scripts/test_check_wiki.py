#!/usr/bin/env python3
"""Unit tests for scripts/check_wiki.py: each rule rejects its own fixture and the good fixture passes."""
import importlib.util
import sys
import tempfile
from pathlib import Path

spec = importlib.util.spec_from_file_location("check_wiki", Path(__file__).with_name("check_wiki.py"))
cw = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cw)

GOOD = {
    "Home.md": "# H\n\n[简体中文](Home-zh-CN)\n\n[Usage](Usage)\n",
    "Home-zh-CN.md": "# 首页\n\n[English](Home)\n\n[用法](Usage-zh-CN)\n",
    "Usage.md": "# U\n\n[简体中文](Usage-zh-CN)\n\n```lua\nx[1](y)\n```\n",
    "Usage-zh-CN.md": "# 用法\n\n[English](Usage)\n",
    "_Sidebar.md": "- [Home](Home)\n- [Usage](Usage)\n- [首页](Home-zh-CN)\n- [用法](Usage-zh-CN)\n",
}
CASES = {
    "good": ({}, None),
    "missing counterpart": ({"Usage-zh-CN.md": None}, "counterpart"),
    "no switch on line 3": ({"Usage.md": "# U\n\nno switch\n"}, "line 3"),
    "broken link": ({"Usage.md": GOOD["Usage.md"] + "[x](Nope)\n"}, "broken link"),
    "sidebar gap": ({"_Sidebar.md": "- [Home](Home)\n"}, "sidebar"),
    "home gap": ({"Home.md": "# H\n\n[简体中文](Home-zh-CN)\n"}, "Home"),
}

fails = 0
for name, (edit, needle) in CASES.items():
    with tempfile.TemporaryDirectory() as d:
        files = {**GOOD, **edit}
        for f, text in files.items():
            if text is not None:
                (Path(d) / f).write_text(text, encoding="utf-8")
        errs = cw.check(Path(d))
        good = (not errs) if needle is None else any(needle in e for e in errs)
        print(("ok - " if good else "FAIL - ") + name, "" if good else errs)
        fails += not good
sys.exit(1 if fails else 0)
