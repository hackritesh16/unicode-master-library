# Progress Tracker

Source of truth for how much of `docs/MASTER_PROMPT.md` is done.
**Do not trust this file blindly.** Every agent must re-audit against the real repository and CI (see Part A of the master prompt) and then correct this file.

Legend: `DONE` works, tested, CI green. `PARTIAL` exists but incomplete or untested. `MISSING` not started. `BROKEN` exists but fails.

Last audit: 2026-11-10 (Claude via GitHub connector; repository tree, PR list, CI runs and workflow logs inspected; no device testing, no local Flutter run).
Estimated completion of the whole master prompt: about 30 to 35 percent. This is a rough estimate.

## Phase table

| Phase | Name | Status | Evidence and gaps |
|---|---|---|---|
| 0 | Stabilize and housekeeping | PARTIAL | `main` CI green at `3623e8e` and earlier (runs #152 to #154 success; #155 was still running at write time). README, PLAN, DECISIONS and LICENSE (MIT) exist; SOURCES.md has credits. Open: PR #1 not merged (CI green on its branch, run #144, but based on old main and not fully reviewed); `android/` still generated in CI. |
| 1 | Unicode data foundation | PARTIAL | Real-data check now passes: `data-check.yml` run #2 succeeded (real UCD downloaded, parsed and imported into in-memory SQLite, assertions on counts, version, blocks, U+0307 passed): https://github.com/hackritesh16/unicode-master-library/actions/runs/42780126733. Still open: block listing with counts, Unicode version filter, search suggestions and recents, offline test, import performance on a phone. |
| 2 | Style Palette dataset and categorizer | MISSING | Nothing exists. |
| 3 | Style engine | PARTIAL | Only font-style transforms exist (`lib/core/unicode/name_styles.dart`). Grapheme mark engine exists only in PR #1 (`lib/core/text_design/`). |
| 4 | Style Studio UI | PARTIAL | A basic Combining Lab screen exists. No category palette, per-letter stacks, line spans or presets. |
| 5 | Name Generator | PARTIAL | Basic Name Studio on `main`. Real engine (15 themes, 23 font styles, uniqueness, export, share) is in draft PR #1. |
| 6 | Classic Pad core | MISSING | No character grid, tabs, Detail view, undo and redo, or sessions. |
| 7 | Classic Pad advanced | MISSING | Nothing exists. |
| 8 | Emoji library and Explorer polish | PARTIAL | Explorer and a basic Symbols screen exist. Emoji sequences are imported but there is no Emoji screen. |
| 9 | Library, history, export, share | PARTIAL | Library storage and screen exist. Export, import and share are only in PR #1. |
| 10 | Android integration | MISSING | Nothing exists. |
| 11 | Glass UI completion | PARTIAL | Applied to Home, navigation bar and app bars only. |
| 12 | QA, docs, release | MISSING | Manual APK workflow exists (run #1 success); no release signing, no final docs, no device testing. |

## Checklist details

| Item | Status | Note |
|---|---|---|
| P0.1 PR #1 | PARTIAL | Draft. Branch CI green (run #144 at 18e81d7) but base is old main (7e5c50f). 25 files, +5348/-59. Overlaps main in `ci.yml`, `pubspec.yaml`, `name_studio_screen.dart`, `library_storage_service.dart`. Needs full diff review and rebase or port before merge. |
| P0.2 README | DONE | Rewritten earlier today; CI green. |
| P0.3 PLAN pointer | DONE | Points to this tracker. |
| P0.4 DECISIONS | DONE | `docs/DECISIONS.md` exists and is kept current. |
| P0.5 LICENSE and credits | DONE | MIT `LICENSE` added (owner said any license is fine); SOURCES.md credits Unicode, UnicodePad (Apache-2.0, reference only) and font policy. |
| P0.6 android/ folder | MISSING | Decision not made yet. |
| P1.1 Real-data check | DONE | `data-check.yml` run #2 success (runs `flutter test tool_test/real_ucd_test.dart`). First attempt failed because `dart run` cannot load Flutter packages; fixed. |
| P1.2 Classification model | PARTIAL | Range lookup and unassigned handling exist in the Explorer repository; verify a dedicated model. |
| P1.3 Repository APIs | PARTIAL | Search and details exist; block listing with counts, version filter, combining-class paging unverified. |
| P1.6 Search | PARTIAL | Search exists; suggestions and recents missing. |
| P3.7 Font transforms | PARTIAL | Five styles on `main`; PR #1 has 23. |

## Audit log

- 2026-11-10: first audit and creation of this tracker. APK build workflow succeeded once.
- 2026-11-10 (later): PR #1 branch CI turned green (#144). Real-UCD check added and fixed; passes on real files. MIT license added.

## Next

1. Confirm CI for the latest `main` commit is green.
2. P0.1: review the full PR #1 diff against current `main` and port or rebase it safely. Do not merge while it is a draft or red.
3. Phase 1 gaps: block listing with counts, Unicode version filter, offline test, search suggestions.
4. Then Phase 2 (Style Palette).
