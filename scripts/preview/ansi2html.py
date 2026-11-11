#!/usr/bin/env python3
"""Convert a tmux `capture-pane -e` ANSI dump to a standalone HTML page for README screenshots."""
from __future__ import annotations

import html
import re
import sys
from pathlib import Path

SGR = re.compile(r"\x1b\[([0-9;]*)m")
OTHER_ESC = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")
BASE16 = [
    "#1b1f27", "#e06c75", "#98c379", "#e5c07b", "#61afef", "#c678dd", "#56b6c2", "#abb2bf",
    "#5c6370", "#ef8a92", "#b0d99a", "#f0d197", "#82c0f5", "#d79ae8", "#7fcfd9", "#ffffff",
]
DEFAULT_FG, DEFAULT_BG = "#c0c5ce", "#1b1f27"
PAGE = (
    "<!doctype html><html><head><meta charset=\"utf-8\"><style>"
    "body{margin:0;background:%s} "
    "pre{font:16px/1.25 \"ComicShannsMono Nerd Font Mono\",monospace;margin:0;padding:12px;color:%s;display:inline-block}"
    "</style></head><body><pre>%s</pre></body></html>\n"
)


def xterm256(n: int) -> str:
    if n < 16:
        return BASE16[n]
    if n < 232:
        n -= 16
        steps = [0, 95, 135, 175, 215, 255]
        return "#%02x%02x%02x" % (steps[n // 36], steps[(n // 6) % 6], steps[n % 6])
    g = 8 + (n - 232) * 10
    return "#%02x%02x%02x" % (g, g, g)


class Style:
    def __init__(self) -> None:
        self.reset()

    def reset(self) -> None:
        self.fg = self.bg = None
        self.bold = self.italic = self.underline = self.reverse = False

    def apply(self, params: str) -> None:
        codes = [int(c) if c else 0 for c in params.split(";")] if params else [0]
        i = 0
        while i < len(codes):
            c = codes[i]
            if c == 0:
                self.reset()
            elif c == 1:
                self.bold = True
            elif c == 3:
                self.italic = True
            elif c == 4:
                self.underline = True
            elif c == 7:
                self.reverse = True
            elif c == 22:
                self.bold = False
            elif c == 23:
                self.italic = False
            elif c == 24:
                self.underline = False
            elif c == 27:
                self.reverse = False
            elif 30 <= c <= 37:
                self.fg = BASE16[c - 30]
            elif 90 <= c <= 97:
                self.fg = BASE16[c - 90 + 8]
            elif 40 <= c <= 47:
                self.bg = BASE16[c - 40]
            elif 100 <= c <= 107:
                self.bg = BASE16[c - 100 + 8]
            elif c == 39:
                self.fg = None
            elif c == 49:
                self.bg = None
            elif c in (38, 48) and i + 1 < len(codes):
                if codes[i + 1] == 5 and i + 2 < len(codes):
                    colour, i = xterm256(codes[i + 2]), i + 2
                elif codes[i + 1] == 2 and i + 4 < len(codes):
                    colour, i = "#%02x%02x%02x" % tuple(codes[i + 2 : i + 5]), i + 4
                else:
                    colour = None
                if c == 38:
                    self.fg = colour
                else:
                    self.bg = colour
            i += 1

    def css(self) -> str:
        fg, bg = self.fg, self.bg
        if self.reverse:
            fg, bg = (bg or DEFAULT_BG), (fg or DEFAULT_FG)
        parts = []
        if fg:
            parts.append(f"color:{fg}")
        if bg:
            parts.append(f"background:{bg}")
        if self.bold:
            parts.append("font-weight:bold")
        if self.italic:
            parts.append("font-style:italic")
        if self.underline:
            parts.append("text-decoration:underline")
        return ";".join(parts)


def convert(text: str) -> str:
    style = Style()
    out: list[str] = []
    for line in text.rstrip("\n").split("\n"):
        line = OTHER_ESC.sub(lambda m: m.group(0) if m.group(0).endswith("m") else "", line)
        pos = 0
        for m in SGR.finditer(line):
            chunk = line[pos : m.start()]
            if chunk:
                css = style.css()
                body = html.escape(chunk, quote=False)
                out.append(f'<span style="{css}">{body}</span>' if css else body)
            style.apply(m.group(1))
            pos = m.end()
        chunk = line[pos:]
        if chunk:
            css = style.css()
            body = html.escape(chunk, quote=False)
            out.append(f'<span style="{css}">{body}</span>' if css else body)
        out.append("\n")
    return PAGE % (DEFAULT_BG, DEFAULT_FG, "".join(out).rstrip("\n"))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("usage: ansi2html.py IN OUT")
    Path(sys.argv[2]).write_text(convert(Path(sys.argv[1]).read_text(encoding="utf-8")), encoding="utf-8")
