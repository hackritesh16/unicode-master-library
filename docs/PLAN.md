# Development Plan and Status

| Phase | Scope | Status |
|---|---|---|
| 1 | Repository inspection and architecture | Committed |
| 2 | Design system and navigation | Committed |
| 3 | Unicode database pipeline | Committed; full-device import pending |
| 4 | Unicode Explorer | Implemented; CI passing; device verification pending |
| 5 | Combining Marks Laboratory | Implemented; CI verification pending |
| 6 | Name Designer | Implemented; CI verification pending |
| 7 | Decorative Composer | Not started |
| 8 | Emoji and symbol libraries | Not started |
| 9 | Favorites, history, persistence | Not started |
| 10 | Testing, optimization, release | Not started |

## Phase 6 — Name Designer

- Live text input with a 40-character limit and instant preview.
- Five styles: mathematical bold, monospace, fullwidth, circled, and small caps.
- Search/filter the style collection and copy individual results.
- Characters without a mapping are preserved.
- Compatibility note explains that glyph support depends on device fonts and apps.
- Unit tests cover mappings and unsupported-character preservation; widget test covers editing and preview.

## Verification and known limitations

- CI runs flutter analyze and flutter test; physical Android verification is still pending.
- Phase 5 mark inventory remains curated and should later be backed by the installed UCD database.
- The first full UCD download/import and performance check must be done on an Android device or emulator.
- Unicode presentation glyph appearance and availability vary by font/platform.
- No license file has been added; repository owner must choose the license.
