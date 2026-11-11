# Documentation Pipeline

[简体中文](Documentation-Pipeline-zh-CN)

The wiki is the **only authored documentation source** for this fork. Nothing in
`doc/` is hand-written.

## Layout

| Path | Role |
| --- | --- |
| `wiki/*.md` | Authored English guides (published as wiki pages) |
| `wiki/*-zh-CN.md` | Authored Chinese guides (published as wiki pages) |
| `wiki/_Sidebar.md` | Bilingual wiki sidebar |
| `wiki/help/*.txt` | Authored Vim help fragments — the reference source |
| `doc/bufferlines.txt` | **Generated** artifact, committed to Git |
| `scripts/gen_help.py` | Generator (stdlib only) |
| `scripts/test_docs.py` | Documentation tests (stdlib only) |
| `scripts/check_wiki.py` | Wiki structure check (stdlib only) |
| `scripts/publish-wiki.sh` | Wiki mirror publisher (tested by `scripts/test_wiki_sync.py`) |

`doc/bufferlines.txt` stays committed so `:help bufferlines.nvim` works for users who
install the plugin without the wiki.

## Generating

```sh
python3 scripts/gen_help.py          # rewrite doc/bufferlines.txt
python3 scripts/gen_help.py --check  # fail if it is out of sync
```

The generator concatenates `wiki/help/*.txt` in filename order, joined by a single
newline. It is deterministic: identical sources always produce identical bytes, with no
timestamps or machine-specific values. Section order is the numeric filename prefix, so
reordering sections means renaming files.

## Editing the reference

Edit the fragment in `wiki/help/`, then regenerate:

```sh
$EDITOR wiki/help/05-multiline-buffer-tabs.txt
python3 scripts/gen_help.py
python3 scripts/test_docs.py
```

Never edit `doc/bufferlines.txt` directly — the next generator run overwrites it, and
`--check` fails in the meantime.

Keep help tags (`*bufferlines-...*`) intact when editing; the contents section at
`wiki/help/01-contents.txt` lists them and the tests check that every tag referenced
there exists.

## Tests

`scripts/test_docs.py` checks:

- **Generator drift** — `doc/bufferlines.txt` matches the sources byte for byte.
- **Determinism** — generating twice produces identical output.
- **Tag integrity** — every help tag listed in the contents section is defined, and the
  fork-specific tags are preserved.
- **Bilingual parity** — every English wiki page has a `-zh-CN` counterpart, and both
  carry the same set of image URLs.
- **Link parity** — README and its Chinese translation link to the same wiki pages, and
  every internal wiki link resolves to an existing page.
- **Contract accuracy** — documentation does not reintroduce the retired claim that the
  header defines a `q` mapping.

Run it with `python3 scripts/test_docs.py`. It needs only the Python standard library.

## Publishing

`.github/workflows/publish-wiki.yml` publishes `wiki/` to the GitHub wiki on every push
to `main`, and on manual dispatch. A read-only job first runs `scripts/check_wiki.py`
(every page has a `-zh-CN` counterpart, line 3 links to it, internal links resolve, and
`_Sidebar.md` and both Home pages list every page) and the offline publisher tests.
The publish job then runs `scripts/publish-wiki.sh`.

The wiki is a **mirror** of `wiki/*.md`: pages that exist in the GitHub wiki but not in
`wiki/` are deleted on the next publish, and pages renamed in Git are renamed in the
wiki. Author every page in this repository — edits made in the wiki web UI are
overwritten or deleted. Each publish is a normal commit on the wiki's `master`; nothing
is force-pushed, and an unchanged source makes no commit.

Requirements before the workflow can succeed:

1. **The wiki must exist and be initialized.** GitHub does not create the
   `<repo>.wiki.git` repository until the first page is saved through the web UI. Open
   the repository's **Wiki** tab and create any page once. Until then, the clone step
   fails.
2. **The built-in `GITHUB_TOKEN` with `contents: write` on the publishing job.**
   No separate secret or personal token is needed for this repository's wiki.
   Validation keeps read-only permissions. Authentication or publishing failures fail
   the workflow rather than silently skipping publication.

The token reaches git only through `GIT_ASKPASS` and is masked first; it never appears
in a URL or in git arguments. Symlinked source pages, a symlinked source directory and
symlinked wiki pages are rejected.
The English Vim reference is maintained separately from the bilingual prose guides;
`--check` verifies generated help bytes, not semantic translation parity.
