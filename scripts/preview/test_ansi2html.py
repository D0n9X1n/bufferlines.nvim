#!/usr/bin/env python3
"""Unit tests for scripts/preview/ansi2html.py."""
import importlib.util
import sys
from pathlib import Path

spec = importlib.util.spec_from_file_location("ansi2html", Path(__file__).with_name("ansi2html.py"))
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
convert = mod.convert

fails = 0


def check(cond: bool, name: str) -> None:
    global fails
    print(("ok - " if cond else "FAIL - ") + name)
    fails += not cond


check("color:#010203" in convert("\x1b[38;2;1;2;3mA\x1b[0m") and ">A<" in convert("\x1b[38;2;1;2;3mA\x1b[0m"), "truecolor fg")
check("background:#ff0000" in convert("\x1b[48;5;196mB"), "256-colour bg")
bold = convert("\x1b[1;3mC")
check("font-weight:bold" in bold and "font-style:italic" in bold, "bold and italic")
rev = convert("\x1b[38;2;1;1;1;48;2;2;2;2;7mD")
check("color:#020202" in rev and "background:#010101" in rev, "reverse swaps fg/bg")
check("&lt;&amp;&gt;" in convert("<&>"), "html escaped")
check("日" in convert("日本"), "wide characters pass through")
check("text-decoration:underline" in convert("\x1b[4mU"), "underline")
reset = convert("\x1b[1mX\x1b[22mY")
check(reset.count("font-weight:bold") == 1, "22 clears bold")
check('font-family:"ComicShannsMono Nerd Font Mono"' in convert("x").replace("font:16px/1.25 ", "font-family:"), "nerd font")
sys.exit(1 if fails else 0)
