#!/usr/bin/env python3
"""Documentation tests for the wiki-as-source pipeline.

Standard library only. No network access, no third-party packages, no Neovim.

    python3 scripts/test_docs.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
# Import the generator without leaving a __pycache__ directory behind, so a test
# run never adds untracked files to the checkout.
sys.dont_write_bytecode = True

import gen_help  # noqa: E402  (path set above)

ROOT = Path(__file__).resolve().parent.parent
WIKI = ROOT / "wiki"
HELP_SOURCES = WIKI / "help"
GENERATED = ROOT / "doc" / "bufferlines.txt"
README_EN = ROOT / "README.md"
README_ZH = ROOT / "README.zh-CN.md"
WORKFLOW = ROOT / ".github" / "workflows" / "publish-wiki.yml"
PUBLISHER = ROOT / "scripts" / "publish-wiki.sh"

ZH_SUFFIX = "-zh-CN"

MD_IMAGE = re.compile(r"!\[[^\]]*\]\(((?:https://|wiki/assets/)[^)\s]+)\)")
HTML_IMAGE = re.compile(r"<img[^>]*\ssrc=\"((?:https://|wiki/assets/)[^\"]+)\"")
MD_LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
HELP_TAG_DEF = re.compile(r"\*(bufferlines[A-Za-z0-9._-]*)\*")
HELP_TAG_REF = re.compile(r"\|(bufferlines[A-Za-z0-9._-]*)\|")
WIKI_URL = re.compile(r"https://github\.com/D0n9X1n/bufferlines\.nvim/wiki/([A-Za-z0-9._-]+)")
CODE_BLOCK = re.compile(r"```(?:lua|vim|sh)?\n(.*?)```", re.DOTALL)

# Nerd Font glyphs live in the Unicode Private Use Area, so an editor, a
# terminal or a copy-paste step can silently drop them and leave a plausible
# looking empty string behind. Written here as escapes, never as literals, and
# pinned to the values in the pre-wiki README.
PUA_START, PUA_END = 0xE000, 0xF8FF
GLYPH_ERROR = ""
GLYPH_WARNING = ""
GLYPH_INFO = ""
GLYPH_HINT = ""
GLYPH_CHEVRON_LEFT = ""
GLYPH_CHEVRON_RIGHT = ""

# page -> every glyph that page must still contain.
REQUIRED_PAGE_GLYPHS = {
    "Features.md": [GLYPH_ERROR, GLYPH_WARNING, GLYPH_INFO, GLYPH_HINT],
    "Multiline-Buffer-Tabs.md": [GLYPH_CHEVRON_LEFT, GLYPH_CHEVRON_RIGHT],
}

# Pages whose fenced code blocks must be byte-identical in both languages:
# only the surrounding prose is translated.
CODE_PARITY_PAGES = ["Features.md", "Multiline-Buffer-Tabs.md"]

# README images: our own captures only. The multiline hero leads.
README_HERO = "wiki/assets/multiline-sidebar.png"
REQUIRED_README_IMAGES = [
    "https://github.com/D0n9X1n/bufferlines.nvim/actions/workflows/ci.yml/badge.svg",
    README_HERO,
    "wiki/assets/multiline-overflow.png",
    "wiki/assets/multiline-navigate.png",
    "wiki/assets/default.png",
    "wiki/assets/slope.png",
    "wiki/assets/diagnostics.png",
    "wiki/assets/groups.png",
    "wiki/assets/pick.png",
    "wiki/assets/hover.png",
]
README_MAX_LINES = 120

# Headings the README must keep.
REQUIRED_README_EN_HEADINGS = [
    "Multiline buffer tabs",
    "Installation",
    "Features",
    "Migrating from bufferline.nvim",
    "Documentation",
    "Acknowledgements",
    "License",
]

# Every Features section shows exactly this fresh capture (one image per feature).
FEATURE_ASSETS = {
    "Slanted tabs": "slant.png",
    "Sloped tabs": "slope.png",
    "Hover events": "hover.png",
    "Underline indicator": "underline.png",
    "Tabpages": "tabpages.png",
    "LSP indicators": "diagnostics.png",
    "Groups": "groups.png",
    "Sidebar offsets": "offsets.png",
    "Numbers": "numbers.png",
    "Unique names": "duplicates.png",
    "Close icons": "close-icons.png",
    "Re-ordering": "reorder.png",
    "Picking": "pick.png",
    "Pinning": "pinning.png",
    "Custom areas": "custom-areas.png",
}
UPSTREAM_IMAGE_HOSTS = ("user-images.githubusercontent.com", "akinsho/bufferline.nvim/actions")
# The wiki publisher mirrors only *.md, so wiki pages load captures from the main branch.
WIKI_ASSET_URL = "https://raw.githubusercontent.com/D0n9X1n/bufferlines.nvim/main/wiki/assets/"

# Fork-specific help tags that must never be dropped by a docs refactor.
REQUIRED_HELP_TAGS = [
    "bufferlines",
    "bufferlines-contents",
    "bufferlines-introduction",
    "bufferlines-usage",
    "bufferlines-configuration",
    "bufferlines-multiline",
    "bufferlines-hover-events",
    "bufferlines-styling",
    "bufferlines-style-presets",
    "bufferlines-tabpages",
    "bufferlines-numbers",
    "bufferlines-diagnostics",
    "bufferlines-groups",
    "bufferlines-sorting",
    "bufferlines-filtering",
    "bufferlines-commands",
    "bufferlines-functions",
    "bufferlines-pick",
    "bufferlines-mappings",
    "bufferlines-highlights",
    "bufferlines-mouse-actions",
    "bufferlines-custom-areas",
    "bufferlines-working-with-elements",
    "bufferlines-issues",
]

# Retired claims. The header never defined a `q` mapping; documentation must not
# reintroduce it.
FORBIDDEN_PHRASES = [
    "Same as <Esc>: return to the editor",
    "`q` does the same",
    "and `q` does the same",
    "`q` and <Esc> return to the editor",
    "`q` and `Esc`",
    "never starts a macro recording",
]

failures: list[str] = []
checks = 0


def check(condition: bool, message: str) -> None:
    global checks
    checks += 1
    if not condition:
        failures.append(message)


def images(text: str) -> set[str]:
    return set(MD_IMAGE.findall(text)) | set(HTML_IMAGE.findall(text))


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def english_pages() -> list[Path]:
    return sorted(p for p in WIKI.glob("*.md") if not p.stem.endswith(ZH_SUFFIX) and p.stem != "_Sidebar")


def chinese_pages() -> list[Path]:
    return sorted(WIKI.glob(f"*{ZH_SUFFIX}.md"))


def test_generator_has_no_drift() -> None:
    check(GENERATED.exists(), "doc/bufferlines.txt is missing")
    if not GENERATED.exists():
        return
    check(
        read(GENERATED) == gen_help.render(),
        "doc/bufferlines.txt is out of sync with wiki/help/ (run scripts/gen_help.py)",
    )


def test_generator_is_deterministic() -> None:
    check(gen_help.render() == gen_help.render(), "generator output is not deterministic")


def test_generator_reads_only_the_wiki() -> None:
    """The help file must be assembled from wiki/help/ and nothing else."""
    sources = gen_help.source_files()
    check(bool(sources), "no help sources found")
    for path in sources:
        check(
            path.parent == HELP_SOURCES,
            f"help source outside wiki/help/: {path}",
        )
    generator_src = read(ROOT / "scripts" / "gen_help.py")
    for forbidden in ("urllib", "requests", "subprocess", "socket"):
        check(
            forbidden not in generator_src,
            f"generator must not depend on {forbidden}",
        )


def test_help_tags_are_preserved() -> None:
    if not GENERATED.exists():
        return
    text = read(GENERATED)
    defined = set(HELP_TAG_DEF.findall(text))
    for tag in REQUIRED_HELP_TAGS:
        check(tag in defined, f"help tag lost: *{tag}*")
    for tag in sorted(set(HELP_TAG_REF.findall(text))):
        check(tag in defined, f"help references undefined tag: |{tag}|")


def test_bilingual_page_parity() -> None:
    english = {p.stem for p in english_pages()}
    chinese = {p.stem[: -len(ZH_SUFFIX)] for p in chinese_pages()}
    for name in sorted(english - chinese):
        failures.append(f"English wiki page has no Chinese counterpart: {name}")
    for name in sorted(chinese - english):
        failures.append(f"Chinese wiki page has no English counterpart: {name}")
    global checks
    checks += 1

    for page in english_pages():
        counterpart = WIKI / page.name.replace(".md", f"{ZH_SUFFIX}.md")
        if not counterpart.exists():
            continue
        en_images = images(read(page))
        zh_images = images(read(counterpart))
        check(
            en_images == zh_images,
            f"image parity mismatch between {page.name} and {counterpart.name}: "
            f"only EN {sorted(en_images - zh_images)}, only ZH {sorted(zh_images - en_images)}",
        )


def test_bilingual_pages_are_substantive() -> None:
    """A translation must not be a stub or an untranslated copy."""
    for page in english_pages():
        counterpart = WIKI / page.name.replace(".md", f"{ZH_SUFFIX}.md")
        if not counterpart.exists():
            continue
        zh_text = read(counterpart)
        check(len(zh_text) > 400, f"Chinese page looks like a stub: {counterpart.name}")
        han = sum(1 for ch in zh_text if "一" <= ch <= "鿿")
        check(
            han >= 150,
            f"Chinese page has too little Chinese prose ({han} han chars): {counterpart.name}",
        )


def test_internal_wiki_links_resolve() -> None:
    pages = {p.stem for p in WIKI.glob("*.md")}
    for page in sorted(WIKI.glob("*.md")):
        for target in MD_LINK.findall(read(page)):
            if target.startswith(("http://", "https://", "#", "mailto:")):
                continue
            slug = target.split("#", 1)[0].strip()
            if not slug:
                continue
            check(slug in pages, f"{page.name} links to missing wiki page: {slug}")


def test_readme_links_resolve_and_match() -> None:
    pages = {p.stem for p in WIKI.glob("*.md")}
    en_targets = set(WIKI_URL.findall(read(README_EN)))
    zh_targets = set(WIKI_URL.findall(read(README_ZH)))

    for slug in sorted(en_targets | zh_targets):
        check(slug in pages, f"README links to missing wiki page: {slug}")

    en_normalised = {s for s in en_targets if not s.endswith(ZH_SUFFIX)}
    zh_normalised = {s[: -len(ZH_SUFFIX)] for s in zh_targets if s.endswith(ZH_SUFFIX)}
    check(
        en_normalised == zh_normalised,
        "README wiki links differ between languages: "
        f"only EN {sorted(en_normalised - zh_normalised)}, "
        f"only ZH {sorted(zh_normalised - en_normalised)}",
    )
    check(
        all(s.endswith(ZH_SUFFIX) for s in zh_targets),
        "Chinese README must link to Chinese wiki pages",
    )


def test_readme_images_and_headings_are_preserved() -> None:
    en_images = images(read(README_EN))
    zh_images = images(read(README_ZH))
    for url in REQUIRED_README_IMAGES:
        check(url in en_images, f"README.md dropped an image: {url}")
    check(
        en_images == zh_images,
        "README image parity mismatch: "
        f"only EN {sorted(en_images - zh_images)}, only ZH {sorted(zh_images - en_images)}",
    )

    headings = {
        line.lstrip("#").strip()
        for line in read(README_EN).splitlines()
        if line.startswith("#")
    }
    for heading in REQUIRED_README_EN_HEADINGS:
        check(heading in headings, f"README.md dropped heading: {heading}")
    lines = read(README_EN).splitlines()
    check(len(lines) <= README_MAX_LINES, f"README.md is {len(lines)} lines; keep it under {README_MAX_LINES}")
    first = next((m.group(1) for m in re.finditer(r"!\[[^\]]*\]\(([^)\s]+)\)", read(README_EN))), None)
    check(first == README_HERO, f"README.md must lead with the multiline hero, found {first}")


def test_multiline_preview_and_wiki_quickstart() -> None:
    previews = []
    examples = []
    for path in (README_EN, README_ZH):
        text = read(path)
        local_images = {
            target for target in re.findall(r"!\[[^\]]*\]\(([^)\s]+)\)", text)
            if not target.startswith(("https://", "http://"))
        }
        previews.append(local_images)
        check(
            "wiki/assets/multiline-sidebar.png" in local_images,
            f"{path.name} is missing the multiline preview",
        )
        for target in local_images:
            check((ROOT / target).is_file(), f"{path.name} references missing image: {target}")
        blocks = CODE_BLOCK.findall(text)
        check(len(blocks) == 1 and 'version = "*"' in blocks[0], f"{path.name} needs exactly one install snippet")
        guide = WIKI / ("Multiline-Buffer-Tabs-zh-CN.md" if path == README_ZH else "Multiline-Buffer-Tabs.md")
        snippets = [
            block for block in CODE_BLOCK.findall(read(guide))
            if '"D0n9X1n/bufferlines.nvim"' in block
        ]
        check(len(snippets) == 1, f"{guide.name} needs one fork quickstart")
        examples.append(snippets)
        if len(snippets) == 1:
            for setting in (
                'version = "*"', 'vim.opt.termguicolors = true',
                'opts = {', 'mode = "buffers"', 'enabled = true', 'max_rows = 3',
            ):
                check(setting in snippets[0], f"{guide.name} quickstart is missing {setting}")
            check("multiline_config" not in snippets[0], f"{guide.name} uses an undefined configuration")
    check(previews[0] == previews[1], "README local image references differ between languages")
    check(examples[0] == examples[1], "Wiki fork quickstarts differ between languages")

    sources = [README_EN, README_ZH, HELP_SOURCES / "05-multiline-buffer-tabs.txt"]
    sources += list(WIKI.glob("*Multiline-Buffer-Tabs.md"))
    for path in sources:
        check(
            "feat/multiline-buffer-tabs" not in read(path),
            f"{path.relative_to(ROOT)} still recommends the old feature branch",
        )


def test_no_retired_q_mapping_claim() -> None:
    targets = list(WIKI.glob("*.md")) + list(HELP_SOURCES.glob("*.txt"))
    targets += [README_EN, README_ZH]
    if GENERATED.exists():
        targets.append(GENERATED)
    for path in targets:
        text = read(path)
        for phrase in FORBIDDEN_PHRASES:
            check(
                phrase not in text,
                f"{path.relative_to(ROOT)} reintroduces the retired q-mapping claim: {phrase!r}",
            )

    # A `q` row in a keymap table is the other way the claim creeps back in.
    for path in list(WIKI.glob("*Multiline*.md")) + [HELP_SOURCES / "05-multiline-buffer-tabs.txt"]:
        if not path.exists():
            continue
        for line in read(path).splitlines():
            stripped = line.strip()
            check(
                not stripped.startswith("| `q` |") and not re.match(r"^q\s{2,}\S", stripped),
                f"{path.relative_to(ROOT)} documents a `q` header mapping: {stripped!r}",
            )


def test_multiline_contract_statements_present() -> None:
    """The corrected contract must be stated, not merely un-contradicted."""
    required = {
        WIKI / "Multiline-Buffer-Tabs.md": [
            "There is no `q` mapping",
            "only** renderer selector",
            "no native single-row fallback",
            "Recovery is event-driven",
            "cannot pick while the multiline header is unavailable",
        ],
        WIKI / "Multiline-Buffer-Tabs-zh-CN.md": [
            "不存在 `q` 映射",
            "唯一**的渲染器选择开关",
            "不存在回退到原生单行的机制",
            "恢复由事件驱动",
            "cannot pick while the multiline header is unavailable",
        ],
        HELP_SOURCES / "05-multiline-buffer-tabs.txt": [
            "There is no `q` mapping in the header",
            "is the only renderer selector",
            "Recovery is event-driven",
            "cannot pick while the multiline header is unavailable",
        ],
    }
    for path, phrases in required.items():
        check(path.exists(), f"missing documentation source: {path}")
        if not path.exists():
            continue
        text = read(path)
        for phrase in phrases:
            check(phrase in text, f"{path.relative_to(ROOT)} is missing: {phrase!r}")


def test_nerd_font_glyphs_are_preserved() -> None:
    """Private Use Area glyphs must survive any docs migration, in both languages.

    A lost glyph degrades into an innocuous-looking empty string, so this check
    pins the exact codepoints rather than merely asserting "something is there".
    """
    for page, glyphs in REQUIRED_PAGE_GLYPHS.items():
        for name in (page, page.replace(".md", f"{ZH_SUFFIX}.md")):
            path = WIKI / name
            check(path.exists(), f"missing wiki page: {name}")
            if not path.exists():
                continue
            text = read(path)
            for glyph in glyphs:
                check(
                    glyph in text,
                    f"{name} lost the Nerd Font glyph U+{ord(glyph):04X}",
                )

    # An empty inline-code span is what a dropped glyph leaves behind.
    for page in REQUIRED_PAGE_GLYPHS:
        for name in (page, page.replace(".md", f"{ZH_SUFFIX}.md")):
            path = WIKI / name
            if not path.exists():
                continue
            for number, line in enumerate(read(path).splitlines(), 1):
                check(
                    "``" not in line.replace("```", ""),
                    f"{name}:{number} has an empty inline-code span, "
                    f"which is what a dropped glyph looks like: {line.strip()!r}",
                )


def test_code_blocks_match_across_languages() -> None:
    """Translated pages translate prose, never the code itself."""
    for page in CODE_PARITY_PAGES:
        en_path = WIKI / page
        zh_path = WIKI / page.replace(".md", f"{ZH_SUFFIX}.md")
        check(en_path.exists() and zh_path.exists(), f"missing a language pair for {page}")
        if not (en_path.exists() and zh_path.exists()):
            continue
        en_blocks = [b.strip() for b in CODE_BLOCK.findall(read(en_path))]
        zh_blocks = [b.strip() for b in CODE_BLOCK.findall(read(zh_path))]
        check(
            len(en_blocks) == len(zh_blocks),
            f"{page}: {len(en_blocks)} code blocks in EN but {len(zh_blocks)} in ZH",
        )
        for index, (en_block, zh_block) in enumerate(zip(en_blocks, zh_blocks)):
            check(
                en_block == zh_block,
                f"{page}: code block {index} differs between languages "
                f"(EN {en_block[:60]!r} vs ZH {zh_block[:60]!r})",
            )


def test_diagnostics_examples_are_functional() -> None:
    """The diagnostics snippets must still demonstrate working indicators.

    Blanked-out glyphs turn every example into one that renders nothing, and the
    conditional example into one that disables diagnostics for *all* buffers
    rather than only the current one.
    """
    for name in ("Features.md", f"Features{ZH_SUFFIX}.md"):
        path = WIKI / name
        check(path.exists(), f"missing wiki page: {name}")
        if not path.exists():
            continue
        snippets = [
            block for block in CODE_BLOCK.findall(read(path))
            if "diagnostics_indicator" in block
        ]
        check(len(snippets) == 3, f"{name}: expected 3 diagnostics examples, got {len(snippets)}")

        for index, snippet in enumerate(snippets):
            # Scan the snippet directly: pairing quotes is unreliable here,
            # because an apostrophe in the prose comments ("Don't get too
            # fancy") desynchronises any quote-matching heuristic.
            has_glyph = any(PUA_START <= ord(ch) <= PUA_END for ch in snippet)
            check(
                has_glyph,
                f"{name}: diagnostics example {index} has no glyph left, "
                "so it would render nothing",
            )

        # The conditional example must return empty for the *current* buffer and
        # something visible otherwise. Two empty returns disable it everywhere.
        conditional = next((s for s in snippets if "context.buffer:current()" in s), None)
        check(conditional is not None, f"{name}: the conditional example is missing")
        if conditional is None:
            continue
        returns = re.findall(r"return\s+'([^']*)'", conditional)
        check(
            len(returns) == 2,
            f"{name}: conditional example should have 2 return values, got {len(returns)}",
        )
        if len(returns) == 2:
            check(
                returns[0] == "",
                f"{name}: the current-buffer branch should return an empty string, "
                f"got {returns[0]!r}",
            )
            check(
                returns[1] != "",
                f"{name}: the other-buffers branch returns an empty string, which "
                "disables diagnostics for every buffer instead of just the current one",
            )


def test_generated_file_is_marked_generated() -> None:
    if not GENERATED.exists():
        return
    head = read(GENERATED)[:1500]
    check("GENERATED FILE" in head, "doc/bufferlines.txt lacks a generated-file notice")
    check("wiki/help/" in head, "doc/bufferlines.txt does not name its source directory")


def test_workflow_safety() -> None:
    check(WORKFLOW.exists(), "missing .github/workflows/publish-wiki.yml")
    check(PUBLISHER.exists(), "missing scripts/publish-wiki.sh")
    if not WORKFLOW.exists() or not PUBLISHER.exists():
        return
    text, script = read(WORKFLOW), read(PUBLISHER)
    check("branches: [main]" in text, "wiki must publish on pushes to main")
    check("workflow_dispatch:" in text, "workflow must support manual dispatch")
    check("scripts/publish-wiki.sh" in text, "workflow must call the tested publisher")
    check("WIKI_TOKEN: ${{ secrets.GITHUB_TOKEN }}" in text, "wiki must use the built-in token")
    check("secrets.WIKI_TOKEN" not in text, "a separate wiki secret must not be required")
    check("contents: write" in text.split("  publish:", 1)[1], "publish job needs wiki write permission")
    for name, body in (("workflow", text), ("publisher", script)):
        check("--force" not in body, f"{name} must never force-push")
        check("x-access-token:" not in body, f"{name} must not embed the token in a URL")
    check("GIT_ASKPASS" in script, "publisher must supply the token via GIT_ASKPASS")
    check("::add-mask::" in script, "publisher must mask the token")

def test_readme_release_contract() -> None:
    for path in (README_EN, README_ZH):
        text = read(path)
        check(
            "akinsho/bufferline.nvim" in text and ("## Acknowledgements" in text or "## 致谢" in text),
            f"{path.name}: acknowledgements",
        )
        check('"D0n9X1n/bufferlines.nvim"' in text and 'version = "*"' in text, f"{path.name}: install snippet")
        check("Installation-and-Usage" in text and ("migrat" in text.lower() or "迁移" in text),
              f"{path.name}: links the migration guide")
    for name in ("Installation-and-Usage.md", f"Installation-and-Usage{ZH_SUFFIX}.md"):
        text = read(WIKI / name)
        for old, new in (
            ('require("bufferline")', 'require("bufferlines")'),
            (":BufferLinePick", ":BufferLinesPick"),
            ("BufferLineFill", "BufferLinesFill"),
            ("vim.g.BufferlinePositions", "vim.g.BufferlinesPositions"),
        ):
            check(old in text and new in text, f"{name}: migration row {old}")
    log = read(ROOT / "CHANGELOG.md")
    head = log.split("## 1.0.0")[0]
    check(log.startswith("# Changelog") and "## 1.0.0" in log and "## [4." not in log and "4.10" not in head,
          "CHANGELOG restarts at 1.0.0")
    stale = "".join(read(p) for p in [README_EN, README_ZH, *WIKI.glob("*.md")])
    check("MOSconfig/bufferline" not in stale, "stale MOSconfig URL")


def test_publishing_docs_match_publisher() -> None:
    """The wiki mirror deletes pages absent from wiki/; the guides must say so and name the real workflow."""
    for name in ("Documentation-Pipeline.md", "Documentation-Pipeline-zh-CN.md"):
        text = read(WIKI / name)
        check("publish-wiki.yml" in text and "scripts/publish-wiki.sh" in text, f"{name}: names the publisher")
        check("wiki-release.yml" not in text, f"{name}: stale wiki-release.yml")
        check("zh-CN-" not in text.replace("-zh-CN", ""), f"{name}: stale zh-CN- prefix")
        check("scripts/check_wiki.py" in text and "_Sidebar.md" in text, f"{name}: structure check and sidebar")
        for claim in ("left untouched", "survive", "不会被改动", "得以保留"):
            check(claim not in text, f"{name}: false preservation claim '{claim}'")
    check("deleted" in read(WIKI / "Documentation-Pipeline.md"), "Documentation-Pipeline.md: documents mirror deletion")
    check("删除" in read(WIKI / "Documentation-Pipeline-zh-CN.md"), "Documentation-Pipeline-zh-CN.md: documents mirror deletion")


def test_only_fresh_screenshots() -> None:
    """README and wiki use this project's own captures; every referenced asset exists."""
    for path in [README_EN, README_ZH, *WIKI.glob("*.md")]:
        text = read(path)
        for host in UPSTREAM_IMAGE_HOSTS:
            check(host not in text, f"{path.name}: still uses an upstream image ({host})")
        for asset in re.findall(r"(?:wiki/assets/|" + re.escape(WIKI_ASSET_URL) + r")([^)\s\"]+)", text):
            check((WIKI / "assets" / asset).is_file(), f"{path.name}: missing asset {asset}")
        if path.parent == WIKI:
            check("](assets/" not in text, f"{path.name}: relative asset paths break on the published wiki")


def test_every_feature_has_a_capture() -> None:
    for name in ("Features.md", f"Features{ZH_SUFFIX}.md"):
        sections = re.split(r"^#{2,3} ", read(WIKI / name), flags=re.M)
        found = []
        for section in sections[1:]:
            found += re.findall(r"!\[[^\]]*\]\(" + re.escape(WIKI_ASSET_URL) + r"([^)\s]+)\)", section)
        for heading, asset in FEATURE_ASSETS.items():
            check(asset in found, f"{name}: feature {heading!r} needs assets/{asset}")
            check((WIKI / "assets" / asset).is_file(), f"missing capture wiki/assets/{asset}")
    english = read(WIKI / "Features.md")
    for heading, asset in FEATURE_ASSETS.items():
        part = re.split(r"^#{2,3} ", english, flags=re.M)
        body = next((p for p in part if p.startswith(heading + "\n")), "")
        check(f"({WIKI_ASSET_URL}{asset})" in body, f"Features.md section {heading!r} must show {asset}")


def main() -> int:
    tests = [value for name, value in sorted(globals().items()) if name.startswith("test_")]
    for test in tests:
        test()

    if failures:
        print(f"FAILED {len(failures)} of {checks} checks\n", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1
    print(f"ok - {checks} checks passed across {len(tests)} tests")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
