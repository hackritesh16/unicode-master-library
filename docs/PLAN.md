# Development Plan and Status

| Phase | Scope | Status |
|---|---|---|
| 1 | Repository inspection and architecture | Committed |
| 2 | Design system and navigation | Committed; glass-system upgrade scheduled for UI polish |
| 3 | Unicode database pipeline | Committed; full-device import pending |
| 4 | Unicode Explorer | Implemented; CI/device verification pending |
| 5 | Combining Marks Laboratory | Implemented; CI/device verification pending |
| 6 | Name Designer | Implemented; CI verification pending |
| 7 | Decorative Composer | Implemented; CI verification pending |
| 8 | Emoji and symbol libraries | Not started |
| 9 | Favorites, history, persistence | Not started |
| 10 | UI polish, glass design system, testing, optimization and release | Not started |

## Phase 6 — Name Designer

- Live text input with a 40-character limit and instant preview.
- Five styles: mathematical bold, monospace, fullwidth, circled, and small caps.
- Search/filter the style collection and copy individual results.
- Characters without a mapping are preserved.
- Compatibility note explains that glyph support depends on device fonts and apps.
- Unit tests cover mappings and unsupported-character preservation; widget test covers editing and preview.

## Phase 7 — Decorative Composer

- Live text editor with a curated collection of six Unicode decoration frames.
- Custom prefix and suffix fields override each frame independently.
- Instant preview, reset action and one-tap copy.
- Unit tests cover preset formatting, custom overrides and empty input; widget test covers live editing and frame selection.

## UI design requirement — premium dark glass

The final app-wide visual treatment must use a consistent glass UI:
- Glass-style buttons and interactive controls.
- Glass app bars, bottom navigation and tab bars.
- Translucent/blurred cards, dialogs, sheets and floating controls.
- Subtle tint, thin highlights, depth and restrained glow.
- Readable contrast, accessible touch targets and reduced-transparency fallbacks.
- Consistent components/tokens; avoid stacking excessive blur layers.

This is a scheduled UI design-system/polish task, not a reason to interrupt the current feature phase. Implement it when the UI polish phase is reached, then apply it consistently across all screens. The project is Flutter; Haze itself targets Jetpack Compose, so use Flutter-native glass rendering or a compatible Flutter library after checking maintenance, performance and Android support.

## Verification and known limitations

- CI runs flutter analyze and flutter test; physical Android verification is still pending.
- Phase 5 mark inventory remains curated and should later be backed by the installed UCD database.
- The first full UCD download/import and performance check must be done on an Android device or emulator.
- Unicode presentation glyph appearance and availability vary by font/platform.
- No license file has been added; repository owner must choose the license.
