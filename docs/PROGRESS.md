# Progress Tracker

Source of truth for how much of `docs/MASTER_PROMPT.md` is done.
**Do not trust this file blindly.** Every agent must re-audit against the real repository and CI (see Part A of the master prompt) and then correct this file.

Legend: `DONE` works, tested, CI green. `PARTIAL` exists but incomplete or untested. `MISSING` not started. `BROKEN` exists but fails.

Last audit: 2026-11-10 (GitHub repository tree, PR diff and CI inspected; main CI #168 passed at `6ad46d9`; real-UCD workflow #2 passed; no device testing, nothing run locally).
Estimated completion of the whole master prompt: about 35 to 40 percent. This is a rough estimate.

## Phase table

| Phase | Name | Status | Evidence and gaps |
|---|---|---|---|
| 0 | Stabilize and housekeeping | PARTIAL | PR #1 merged; `main` CI green at `6ad46d9` (run #168: analyze plus all tests). README, PLAN, DECISIONS and LICENSE (MIT) exist; SOURCES.md has credits. Open: `android/` still generated in CI (P0.6). |
| 1 | Unicode data foundation | PARTIAL | Real-data check passes: `data-check.yml` run #2 succeeded (real UCD downloaded, parsed and imported into in-memory SQLite, assertions on counts, version, blocks, U+0307 passed): https://github.com/hackritesh16/unicode-master-library/actions/runs/42780126733. Still open: block listing with counts, Unicode version filter, search suggestions and recents, offline test, import performance on a phone. |
| 2 | Style Palette dataset and categorizer | PARTIAL | `lib/core/text_design/style_palette.dart` adds a small curated catalog (94 lines) with name/glyph/code-point search and category filtering. `StylePaletteScreen` is registered at `/style-palette` and linked from Emoji & Symbols. Unit and widget tests exist and pass in CI #168. Still missing: UCD-derived categorizer, `style_palette` DB table, curated JSON overlay, real-data category assertions, broader categories. |
| 3 | Style engine | PARTIAL | Grapheme splitting, combining-mark catalog with render-risk flags, sequence-problem checks and 23 font-style transforms are on `main` (from PR #1, in `lib/core/text_design/`). Per-letter mark stacks, line spans, mirror mode and presets (P3.2 to P3.5, P3.9) not verified as complete. |
| 4 | Style Studio UI | PARTIAL | A basic Combining Lab screen exists. No category palette, per-letter stacks, line spans or presets. |
| 5 | Name Generator | PARTIAL | PR #1 merged: 15 themes, 23 font styles, mixed fonts, marks, emoji pairs, frames, uniqueness, rewritten Name Studio screen, with tests (green in CI #168). The UI screen (+640 lines) was not read line by line. Not device-tested. |
| 6 | Classic Pad core | MISSING | No character grid, tabs, Detail view, undo and redo, or sessions. |
| 7 | Classic Pad advanced | MISSING | Nothing exists. |
| 8 | Emoji library and Explorer polish | PARTIAL | Explorer and a basic Emoji & Symbols screen exist. Emoji sequences are imported; full imported emoji browsing remains open. |
| 9 | Library, history, export, share | PARTIAL | Library storage with favorite edit/duplicate/toggle, TXT/JSON export formats and share service are on `main` (from PR #1, tested). No Library UI for export/import with merge yet; not verified end to end. |
| 10 | Android integration | MISSING | Nothing exists. |
| 11 | Glass UI completion | PARTIAL | Applied to Home, navigation bar and app bars only. Style Palette screen is not yet confirmed to use the glass components. |
| 12 | QA, docs, release | MISSING | Manual APK workflow exists (run #1 success); no release signing, no final docs, no device testing. |

## Checklist details

| Item | Status | Note |
|---|---|---|
| P0.1 PR #1 | DONE | Reviewed (no overlap with main: base blobs of the 5 shared files were unchanged), marked ready and merged as `43fc582`. Merge CI #166 was red only because of 2 analyze warnings from the Style Palette work (unused imports); fixed in `ce84069` and `6ad46d9`, CI #168 green. |
| P0.2 README | DONE | Rewritten earlier today; CI green. |
| P0.3 PLAN pointer | DONE | Points to this tracker. |
| P0.4 DECISIONS | DONE | `docs/DECISIONS.md` exists and is kept current. |
| P0.5 LICENSE and credits | DONE | MIT `LICENSE` added (owner said any license is fine); SOURCES.md credits Unicode, UnicodePad (Apache-2.0, reference only) and font policy. |
| P0.6 android/ folder | MISSING | Decision not made yet. |
| P1.1 Real-data check | DONE | `data-check.yml` run #2 success (runs `flutter test tool_test/real_ucd_test.dart`). First attempt failed because `dart run` cannot load Flutter packages; fixed. |
| P1.2 Classification model | PARTIAL | Range lookup and unassigned handling exist in the Explorer repository; verify a dedicated model. |
| P1.3 Repository APIs | PARTIAL | Search and details exist; block listing with counts, version filter, combining-class paging unverified. |
| P1.6 Search | PARTIAL | Search exists; suggestions and recents missing. |
| P2.1 Curated Style Palette | PARTIAL | Catalog, `/style-palette` screen and link added; tests cover combining preview/copy distinction, name/glyph/code search and category filtering. CI #168 green. |
| P3.1 Grapheme segmentation | DONE | `lib/core/text_design/graphemes.dart` (package `characters`) with tests, in CI #168. ZWJ emoji and Devanagari cases are covered by the PR #1 tests; not re-verified individually. |
| P3.7 Font transforms | PARTIAL | 23 styles on `main`; each reports coverage and honest notes. |

## Audit log

- 2026-11-10: first audit and creation of this tracker. APK build workflow succeeded once.
- 2026-11-10 (later): PR #1 branch CI turned green (#144). Real-UCD check added and fixed; passes on real files. MIT license added.
- 2026-11-10 (later still): PR #1 merged. Another agent pushed Style Palette commits at the same time; they left 2 analyze warnings (unused imports, route not registered) that kept main red. Fixed; main green at #168. Note: an earlier tracker line said the route is `/palette`; the actual route is `/style-palette`.

## Next

1. Phase 1 gaps: block listing with counts, Unicode version filter, offline test, search suggestions.
2. Phase 2: UCD-derived categorizer and `style_palette` table, curated JSON overlay, real-data category assertions (extend `tool_test/real_ucd_test.dart`).
3. Phase 3/4: per-letter mark stacks, line spans, mirror mode, then Style Studio UI.
4. P0.6: decide whether to commit `android/`.
