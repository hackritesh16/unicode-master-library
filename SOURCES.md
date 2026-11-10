# Data Sources and Attribution

## Project license

This project is released under the MIT License (see `LICENSE`). Chosen by the owner on 2026-11-10 (any license was acceptable); recorded in `docs/DECISIONS.md`.

## Unicode Character Database (UCD)

- Source: https://www.unicode.org/Public/UCD/latest/
- Publisher: Unicode, Inc.
- Files to be imported (Phase 3): UnicodeData.txt, Blocks.txt, Scripts.txt, DerivedAge.txt, PropList.txt, DerivedCoreProperties.txt, EastAsianWidth.txt, NameAliases.txt.
- Emoji data: emoji-data.txt and emoji-test.txt, from the matching release (location to be confirmed when the pipeline is written).
- Unicode data files are distributed under the Unicode License (see https://www.unicode.org/license.txt). The license text and copyright header of each imported file will be preserved in `data/unicode/` and shown in the app's About screen.
- The Unicode version is detected at build time by `tools/` scripts, not hardcoded.

## UnicodePad (reference only)

- Project: https://github.com/Ryosuke839/UnicodePad, licensed under Apache-2.0.
- Classic Pad is a from-scratch Flutter reimplementation of its behavior. No UnicodePad source code is copied. If any code is ever copied, the Apache-2.0 notices must be kept and modified files marked.

## Fonts

- No fonts are bundled yet. Any bundled font (for example Noto) must be listed here with its license (SIL OFL 1.1 for Noto) before release, and shown in the About screen.

## Curated data

Hand-curated lists (decoration sets, themes, emoji groupings) live in `data/curated/` and are original to this project.
