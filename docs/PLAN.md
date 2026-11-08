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
| 8 | Emoji and symbol libraries | Implemented; CI verification pending |
| 9 | Favorites, history, persistence | Implemented; CI verification pending |
| 10 | UI polish, glass design system, testing, optimization and release | Implemented; CI/device verification pending |

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

## Phase 8 — Emoji and Symbol Library

- Curated Unicode emoji and symbol collection across faces, nature, hearts, stars, arrows, shapes and music.
- Category filters, text/glyph search and one-tap copy.
- Home quick-access dashboard links to all current tools.
- Widget test covers category and search filtering.

## Phase 9 — Favorites and History

- SharedPreferences-backed local favorites and recent history.
- Duplicate favorites are ignored; repeated history items move to the top.
- History is capped at 60 items and can be cleared; favorites/history can be removed individually.
- Library screen separates Favorites and History; symbol long-press toggles a saved favorite.
- Unit tests cover duplicate favorites and history ordering/clearing.

## Phase 10 — Glass UI polish

- Reusable `GlassSurface`, `GlassAppBar` and `GlassButton` components.
- Glass app bars across the main screens and translucent glass bottom navigation.
- Composer actions use glass buttons; blur can be disabled on individual surfaces for performance fallback.
- Final Android visual/performance verification remains pending.

## UI design requirement — premium dark glass

The final app-wide visual treatment must use a consistent glass UI:
- Glass-style buttons and interactive controls.
- Glass app bars, bottom navigation and tab bars.
- Translucent/blurred cards, dialogs, sheets and floating controls.
- Subtle tint, thin highlights, depth and restrained glow.
- Readable contrast, accessible touch targets and reduced-transparency fallbacks.
- Consistent components/tokens; avoid stacking excessive blur layers.

This phase now uses reusable Flutter-native glass components: translucent surfaces, blurred app bars, a glass bottom navigation container and glass action buttons. A no-blur fallback is available on glass surfaces for lower-power devices. Haze itself targets Jetpack Compose and is not imported into this Flutter project.

## Verification and known limitations

- CI runs flutter analyze and flutter test; physical Android verification is still pending.
- Phase 5 mark inventory remains curated and should later be backed by the installed UCD database.
- The first full UCD download/import and performance check must be done on an Android device or emulator.
- Unicode presentation glyph appearance and availability vary by font/platform.
- No license file has been added; repository owner must choose the license.
