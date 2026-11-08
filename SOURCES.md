# Data Sources and Attribution

## Unicode Character Database (UCD)

- Source: https://www.unicode.org/Public/UCD/latest/
- Publisher: Unicode, Inc.
- Files to be imported (Phase 3): UnicodeData.txt, Blocks.txt, Scripts.txt, DerivedAge.txt, PropList.txt, DerivedCoreProperties.txt, EastAsianWidth.txt, NameAliases.txt.
- Emoji data: emoji-data.txt and emoji-test.txt, from the matching release (location to be confirmed when the pipeline is written).
- Unicode data files are distributed under the Unicode License (see https://www.unicode.org/license.txt). The license text and copyright header of each imported file will be preserved in `data/unicode/` and shown in the app's About screen.
- The Unicode version is detected at build time by `tools/` scripts, not hardcoded.

## Curated data

Hand-curated lists (decoration sets, themes, emoji groupings) live in `data/curated/` and are original to this project.
