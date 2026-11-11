## Summary

<!-- What changes and why. Link the issue it fixes. -->

## Type

- [ ] feat
- [ ] fix
- [ ] refactor
- [ ] docs
- [ ] ci

## Test plan

- [ ] `scripts/plenary.sh` (full suite, Neovim 0.12)
- [ ] `NVIM=<0.8 build> scripts/native-specs.sh` for native-renderer changes
- [ ] `python3 scripts/test_docs.py` and `python3 scripts/check_wiki.py` for docs or wiki changes
- [ ] `scripts/test_release.sh` for release tooling changes
- [ ] Isolated interactive check (buffers, splits, sidebar, resize, mouse) for rendering or input changes

## Notes for reviewers
