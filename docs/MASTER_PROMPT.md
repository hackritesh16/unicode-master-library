# UNICODE MASTER LIBRARY: MASTER PROMPT (phase by phase)

This file is the single source of truth for what the app must become and how any AI agent must work on it.
Owner: hackritesh16. Repository: hackritesh16/unicode-master-library. Platform: Android, built with Flutter.

---

## PART A. START PROTOCOL (every agent must do this first, every time)

Whenever the owner says anything like "start", "continue", "karo", "kaam shuru karo", or gives you a task:

**Step 0. Audit before you build.** Do not write feature code until you have done this.

1. Read `AGENTS.md`, this file, and `docs/PROGRESS.md` completely.
2. Inspect the real repository, not just the docs:
   - file tree under `lib/`, `test/`, `data/`, `tools/`, `docs/`, `.github/workflows/`
   - `pubspec.yaml` (dependencies), recent commits on `main`, all open branches and pull requests
   - the latest CI run on `main` (analyze and test results) and on any open PR
3. Compare what exists with the phase checklists in Part D. For every checklist item decide, from evidence (file path, test name, CI result):
   `DONE` (works, tested, CI green), `PARTIAL` (exists but incomplete or untested), `MISSING`, or `BROKEN`.
   Do not trust `docs/PROGRESS.md` blindly: verify it. If it is wrong, fix it.
4. Report to the owner in a short, mobile-friendly message (reply in the language the owner writes in; Hinglish is fine):
   - overall completion estimate and why
   - a table: phase, status, one-line evidence
   - what you will do next (the first phase that is not DONE, unless the owner chose another)
5. Update `docs/PROGRESS.md` with the audit result and date, commit it, then start working on the first unfinished phase. Do not wait for permission unless you are blocked; if blocked, ask exactly one clear question.

**Work loop (for every phase):** implement real functionality, write tests, run CI (`flutter analyze`, `flutter test`), fix failures, commit in small commits with clear messages, update `docs/PROGRESS.md`, then report: changed files, what works, what is verified, what is NOT verified (for example not tested on a real device), and the next step.

---

## PART B. PRODUCT

### B1. Vision

UNICODE MASTER LIBRARY (Explore, Combine, Design, Create) is an offline-first Android app that is the best possible version of UnicodePad (open source, Apache-2.0: github.com/Ryosuke839/UnicodePad) for making decorated Unicode text and names. It keeps everything UnicodePad can do and adds what UnicodePad lacks: a **Style Palette** that sorts every dot, underline, overline, arrow, x-mark, small letter, enclosing mark and decorative symbol into clear categories, plus tools that apply them to letters fast.

The owner's reference images show names built like this:

1. Base letters, often in a fancy font (bold, script, fraktur, double-struck, monospace, small caps, fullwidth, circled).
2. Marks above and below letters (dots, diaeresis, x-marks, rings, tildes, hooks, small arrows, wavy marks).
3. Small letters above letters (for example c u t e, M M M, def): either combining Latin small letters (U+0363 to U+036F, U+1DC0 to U+1DFF ranges) or spaced superscript letters. The engine must tell them apart.
4. Long lines above and below the whole name, built by repeating overline or underline marks (examples: U+0305, U+033F, U+0332, U+0333) across all letters or across padding, or by spaced line characters.
5. Arrows and endings at line ends (combining arrows around U+20D0 to U+20FF, U+034D, U+034E, U+0362, and normal arrow characters).
6. Enclosing marks and boxes (U+20DD to U+20E4 range, box-drawing frames).
7. Emojis and symbols before and after the name.
8. Symmetric frames (left and right decorations that mirror each other).

All code points above are examples from memory. **Verify every code point, name and category against the imported UnicodeData.txt before relying on it.**

### B2. Three creation modes (one database, one palette, one library)

- **Classic Pad**: faithful UnicodePad parity (Phase 6 and 7).
- **Style Studio**: manual styling with the Style Palette (Phases 2 to 4).
- **Name Generator**: automatic themed designs (Phase 5).

Navigation: keep the six-tab shell (Home, Explorer, Studio, Pad, Library, Settings). The Composer tab becomes **Pad**: a hub with a segmented switch between Classic Pad and Style Studio. Settings has "Open Pad in" (Classic Pad or Style Studio). Home has a card for each mode.

### B3. UnicodePad parity reference (Classic Pad must contain all of this)

Verify against upstream source (`app/src/main/java/jp/ddo/hotmist/unicodepad/` and `app/src/main/res/values/strings.xml`) before implementing each item. Reimplement in Flutter from scratch; do not copy code unless you keep the Apache-2.0 notices and mark modified files.

Screen (from the owner's screenshot): app bar with title, Undo, a second action (sessions or convert), overflow menu; an edit box with colored underline, visible caret and a backspace button on its right; a button row PASTE, DETAIL, COPY, SHARE (and FINISH when launched to return text); a font selector plus a second selector; a horizontally swipeable tab strip (Recent, List, and more by swiping); an 8-column character grid where tap inserts at the caret and long-press opens details. No ads in our app.

Tabs: Recent, List (every Unicode block with an index such as 0 Basic Latin, 300 Combining Diacritical Marks, 2190 Arrows, 2500 Box Drawing), Find (by name or Unihan reading, with find-in-list), Input (type a hex code point, with invalid-codepoint message), Emoji (groups, skin-tone selector), Favorite, RSIndex (CJK radical-stroke index). Our extra tabs: one per Style Palette category group.

Features: detail view (large glyph on checkerboard, font metrics lines, name, aliases, code point, UTF-8/UTF-16, block, script, category, combining class, age, properties, decomposition, case mappings, HTML entity, Unihan fields), undo/redo, sessions (new, current, previous, delete, copied and shared log), string converter, font manager (add from file, rename, delete, fallback chains, Noto download shortcut), shrink-font-to-fit, missing-glyph handling, pinch to switch grid or single-column list with descriptions, grapheme clustering setting, Unicode version filter (using DerivedAge), export and import of settings, history, favorites and scroll positions as JSON with a merge option, settings parity (text sizes, columns 1 to 64 portrait and landscape, padding, checker opacity, recent size, theme, UI scroll, disable system keyboard, startup behavior, clear button, button row, tab management, tutorial), launch from text-selection menu and return result to the calling app, legal and attribution screens.

---

## PART C. NON-NEGOTIABLE RULES

**Engineering**
- Inspect before changing. Do not rewrite working code. Keep commits small. Read a file's latest version immediately before editing it.
- Clean architecture, feature folders. Pure-Dart logic in `lib/core` or a feature `domain/` folder so it is unit-testable without a device. UI depends on providers, providers on services and repositories, the database layer never imports UI.
- Official Unicode data only (https://www.unicode.org/Public/UCD/latest/). Never hardcode the Unicode version. Keep characters, ranges (First/Last), sequences and palette in separate tables. Never claim every code point is a visible symbol: assigned, unassigned, private-use, control, surrogate and noncharacter code points are different.
- Offline-first after the first data download. Database updates are optional, versioned and transactional (a failed update leaves the old data intact). Lazy loading and pagination everywhere; never load the whole database into memory.
- The output string is exact: never normalize, reorder or drop code points unless the user explicitly uses a Normalize tool. Use grapheme clusters (package `characters`), not code units, for cursor and editing operations.
- No ads, no analytics, no network use except the optional Unicode data download. Android needs the INTERNET permission for that.

**Honesty**
- Never mark an unfinished feature as done. Never replace real functionality with dummy data. Placeholders are allowed only if they state which phase delivers the feature.
- Never claim a design works in every app or game; rendering depends on the target app's font and allowed characters.
- Anything not run on a real phone must be labeled "not device-tested".

**Coordination**
- Other agents and tools may push to this repository at the same time. Before starting, list open branches and PRs and recent commits. Prefer new files over big rewrites of shared files. Never force-push. Never delete other branches. Never merge a PR whose CI is red.
- **`.github/workflows/build.yml` is manual only** (workflow_dispatch). Never add push or pull_request triggers to it. `ci.yml` runs analyze and test on push and pull request.

**Credits and licenses**
- Credit the Unicode data license, UnicodePad (Apache-2.0), and any bundled font with its license in `SOURCES.md` and the in-app About screen. Do not add a LICENSE file without asking the owner which license to use.

**Lessons already learned in this repo (avoid repeating them)**
- `flutter analyze` infos fail CI: use `const` where suggested, use `withValues(alpha:)` instead of `withOpacity`, avoid deprecated APIs.
- Widget tests on screens with long lazy `ListView`s must set a tall viewport (`tester.view.physicalSize`, `devicePixelRatio = 1`, reset in `addTearDown`), otherwise off-screen widgets are not built and finders find nothing.
- Do not assert on icon identity in widget tests; assert on state (for example `NavigationBar.selectedIndex`) or text.
- `find.text` can match both a `TextField` and a result label; use precise finders.
- `ci.yml` removes the generated `test/widget_test.dart` after `flutter create`; the `android/` folder is generated in CI (not committed) unless Phase 0 changes that.
- Glass UI: `BackdropFilter` is costly; keep a `blurEnabled: false` fallback and do not put dozens of blurred surfaces in one scrolling list.
- The Unicode parsers have so far only been tested on small fixtures; Phase 1 requires testing them on the real files.

**Communication with the owner**
- Reply in the owner's language (Hinglish is fine), short and mobile-friendly. Commit messages, code and docs stay in English. Explain limits plainly. Do not ask many questions; decide sensibly and write the decision down in `docs/DECISIONS.md`.

---

## PART D. PHASES

Status codes: `[ ]` not done, `[~]` partial, `[x]` done and verified in CI. Update `docs/PROGRESS.md` when a box changes.
Every item is done only when it has code, tests where logic exists, and green CI.

### PHASE 0. Stabilize and housekeeping
Goal: a trustworthy baseline.
- [ ] P0.1 Review PR #1 (branch `claude/name-designer-engine`, draft, last CI red). Fix its CI failures, review the diff, merge when green, and tell the owner what it contains. If it is unsalvageable, port its useful parts to new commits instead.
- [ ] P0.2 Rewrite `README.md`: honest status, features, how to build (`flutter create --platforms=android`, `flutter pub get`, `flutter test`), how to run the manual APK workflow, links to `AGENTS.md`, this file and `docs/PROGRESS.md`.
- [ ] P0.3 Replace stale `docs/PLAN.md` with a pointer to `docs/PROGRESS.md`; keep `docs/ARCHITECTURE.md` accurate.
- [ ] P0.4 Create `docs/DECISIONS.md` (short dated decision log).
- [ ] P0.5 Ask the owner which LICENSE they want, then add it. Add credits to `SOURCES.md` (Unicode, UnicodePad Apache-2.0, fonts).
- [ ] P0.6 Decide whether to commit the `android/` folder (app label, INTERNET permission, launcher icon, `minSdk`) so it is versioned. If yes, update `ci.yml` and `build.yml` accordingly and keep them idempotent.
Done when: main CI green, no stale docs, PR #1 resolved, `docs/PROGRESS.md` accurate.

### PHASE 1. Unicode data foundation
Goal: real data, real classification, fast queries.
- [ ] P1.1 **Real-data check**: add a manual workflow `data-check.yml` (workflow_dispatch) that downloads the real UCD files, runs the parsers and importer into an in-memory SQLite (sqflite_common_ffi), and asserts: version detected, more than 30,000 explicit characters, expected block/script/age counts, emoji sequences present, no parse exceptions. Fix any parser bug it reveals.
- [ ] P1.2 Character model with classification: assigned, unassigned, private-use, control, surrogate, noncharacter, with a helper that reads `characters` and `char_ranges`.
- [ ] P1.3 Repository APIs: list blocks with counts, page characters by block, by category, by script, by combining class, by age filter (Unicode version filter), detail (aliases, properties, decomposition, case mappings, UTF-8 and UTF-16). All paginated.
- [ ] P1.4 Import performance on a real phone: measure; if it janks, move SQLite writes off the UI isolate or chunk with yields; show progress.
- [ ] P1.5 Offline test: with the downloader disabled, the app opens, searches and shows details from the existing database.
- [ ] P1.6 Search: name, character, hex code point (`U+`, `0x`, bare), block, script, category, combining class; suggestions and recent searches.
Done when: data-check passes on real files, repository tests pass, offline test passes.

### PHASE 2. Style Palette dataset and categorizer
Goal: every stylish mark in a clear category, derived from official data.
- [ ] P2.1 Model: `PaletteEntry` (code point, official name, friendly name, category, subcategory, position: above, below, overlay, through, enclosing, spacing; curated flag; stack-safe flag; warning).
- [ ] P2.2 Categorizer (pure Dart): use general category (Mn, Me, Mc), canonical combining class (230 above, 220 below, 1 overlay, 234 double above, 233 double below, 202 attached below, and others; verify in data), block, and official-name keywords (DOT, DIAERESIS, LINE, OVERLINE, LOW LINE, DOUBLE, ARROW, ARROWHEAD, HARPOON, X, LETTER, TILDE, WAVY, RING, ENCLOSING, and so on).
- [ ] P2.3 Minimum categories: dots above, dots below, lines and underlines (single, double, wavy, dotted), overlines, strikes and overlays, arrows above, arrows below, arrowheads and harpoons, x-marks and crosses, small letters above (combining), small letters (spaced superscript and subscript), rings, tildes and hooks, diaeresis and accents, enclosing marks, box-drawing lines, block and shade characters, dots and bullets, stars and sparkles, brackets and ornaments, hearts, flowers and butterflies, Braille patterns, kaomoji parts, and a catch-all Other combining marks so nothing is lost.
- [ ] P2.4 Curated overlay `data/curated/style_palette.json`: hand-picked ordered best-looking subset per category, friendly names, warnings. A test enforces that every referenced code point exists in the database and is in the category claimed.
- [ ] P2.5 Persist the derived palette in a `style_palette` table at import time (rebuilt whenever Unicode data is imported); repository: categories with counts, entries by category and position, search, favorites.
- [ ] P2.6 Add the data-check assertion that every category is non-empty on real data.
Done when: tests with fixtures and the real-data check pass; categories look right on a spot check of at least 20 known marks.

### PHASE 3. Style engine (pure Dart)
Goal: apply marks to names correctly and safely.
- [ ] P3.1 Grapheme segmentation (add `characters` package) including emoji ZWJ and Devanagari clusters.
- [ ] P3.2 Model: styled name = list of letters; each letter has base, ordered above, below, overlay and enclosing stacks.
- [ ] P3.3 Operations: attach, remove, reorder, replace; apply modes: caret letter, selected letters, every letter, every n-th letter, first, last.
- [ ] P3.4 Line spans: long line over or under the name by repeating overline or underline marks across letters or across padding (thin or no-break spaces) with adjustable length; left and right end decorations.
- [ ] P3.5 Mirror mode for symmetric decorations (reverse order and flip pairs such as arrows and brackets correctly).
- [ ] P3.6 Limits and warnings: safe mode maximum marks per letter per side, labeled heavy mode, warnings for likely bad rendering.
- [ ] P3.7 Font transforms (bold, italic, script, fraktur, double-struck, sans, monospace, fullwidth, circled, small caps, and so on) that never replace unsupported characters with wrong ones; integrate with `lib/core/unicode/name_styles.dart` and PR #1 work.
- [ ] P3.8 Exactness: output equals the intended code point sequence; no normalization; round-trip tests.
- [ ] P3.9 Presets that recreate the reference look from rules and palette entries (not fixed strings).
Tests: English, Hindi (Devanagari), mixed scripts, digits, emoji and ZWJ sequences, text that already has combining marks, empty and very long input.
Done when: all engine tests pass in CI.

### PHASE 4. Style Studio UI
Goal: the feature the owner wants most, usable on a phone.
- [ ] P4.1 Screen: editable name, large live preview, category chips with counts, Above / Below / Overlay position filter, palette grid, search, favorites, recents.
- [ ] P4.2 Interaction: tap a mark with a letter selected attaches it; with no selection it inserts it. Long-press shows details (name, code point, warning). Insert-or-attach toggle.
- [ ] P4.3 Letter selection by tapping letters in a letter strip; per-letter stacks with reorder and remove.
- [ ] P4.4 Line span and end-decoration controls; mirror toggle.
- [ ] P4.5 Preview in at least three fonts (system, bundled Noto, user font), dark and light background, compatibility note.
- [ ] P4.6 Undo, redo, reset, copy, copy code points, save to Library, share.
- [ ] P4.7 Presets: apply, save own, share as JSON.
Done when: widget tests cover select, attach, remove, undo; manual device check recorded.

### PHASE 5. Name Generator
Goal: automatic, varied, balanced designs.
- [ ] P5.1 Merge or port PR #1 engine; ensure it draws marks and decorations from the Style Palette.
- [ ] P5.2 Themes: cute, princess, aesthetic, heavy Unicode, royal, attitude, minimal, butterfly, floral, heart, gaming, luxury, line art, UnicodePad-inspired, experimental.
- [ ] P5.3 Generate 20, 50 or 100 unique designs; uniqueness within a result set; deterministic with a seed; symmetry, balance, readability and mark-limit rules.
- [ ] P5.4 UI: name, theme, fonts, emoji, intensity, count, generate more, per-design copy, favorite, details (code points, compatibility advice), copy all, export TXT and JSON, share.
Done when: tests for uniqueness, determinism, theme data consistency and balance pass.

### PHASE 6. Classic Pad core
Goal: UnicodePad's main loop.
- [ ] P6.1 Editor: edit box with caret and selection, grapheme-aware backspace, optional clear button, multiline option, text size setting.
- [ ] P6.2 Button row: PASTE, DETAIL, COPY, SHARE (and FINISH when launched for a result); clear copy feedback.
- [ ] P6.3 Swipeable tab strip component shared with Style Studio.
- [ ] P6.4 Tabs: Recent, List (with block index and jump-to), Favorite, Find (name search first).
- [ ] P6.5 Character grid: configurable columns, tap inserts, long-press opens Detail, pinch switches grid or description list.
- [ ] P6.6 Detail view (see B3), with missing-glyph handling and checkerboard large view.
- [ ] P6.7 Undo and redo with bounded history.
- [ ] P6.8 Font selector (system default plus bundled fonts).
- [ ] P6.9 Sessions: new, current, previous, delete; copied and shared log.
Done when: widget tests for insert, backspace on clusters, undo and redo, tab switching pass.

### PHASE 7. Classic Pad advanced
- [ ] P7.1 Input tab (hex code point entry, invalid message, accepts U+XXXX, 0xXXXX, bare hex).
- [ ] P7.2 Unihan optional import (downloader, tables, license text), Find by Unihan reading, ideograph details.
- [ ] P7.3 RSIndex tab.
- [ ] P7.4 Font manager: add from file, rename, delete, fallback chains, Noto download shortcut, shrink-to-fit.
- [ ] P7.5 String converter: to and from code points, escaped forms, NFC, NFD, NFKC, NFKD, font-style transforms.
- [ ] P7.6 Unicode version filter (DerivedAge) and emoji fallback options.
- [ ] P7.7 Settings parity (all items in B3), tab management (show, hide, reorder; List cannot be hidden), tutorial.
Done when: each item has tests or a documented manual check.

### PHASE 8. Emoji library and Explorer polish
- [ ] P8.1 Emoji screen from emoji-test groups and subgroups; single code points and multi-code-point sequences kept separate and intact; skin-tone selector; search by name; favorites; recents.
- [ ] P8.2 Explorer: category filters, detail page (B3 detail view), copy, favorite.
- [ ] P8.3 Symbols library: searchable, recent, favorites, category filters.
Done when: emoji sequence tests (ZWJ, flags, skin tones, keycaps) pass.

### PHASE 9. Library, history, export, share
- [ ] P9.1 Library: favorites (characters, emoji, marks, designs), saved designs (rename, duplicate, delete, edit), recent designs, recently copied, search history.
- [ ] P9.2 Export and import JSON (settings, history, favorites, presets, scroll positions) with merge option and clear errors; TXT export for designs.
- [ ] P9.3 Share through the Android share sheet.
Done when: export then import round-trips in tests; invalid files fail safely.

### PHASE 10. Android integration
- [ ] P10.1 Process-text intent (launch from text selection menu) and return result to the calling app (FINISH). Needs native Kotlin and manifest entries; document what was device-tested.
- [ ] P10.2 Proper launcher icon, app label, splash, minSdk and targetSdk decisions, permissions review.
Done when: verified on a real device or clearly labeled not device-tested.

### PHASE 11. Glass UI completion and UX polish
- [ ] P11.1 Apply glass components to every screen (Explorer, Studio, Pad, Library, Settings, Combining Lab, Symbols, Emoji). Keep the blur-free fallback and a Settings toggle.
- [ ] P11.2 Accessibility: 44 dp touch targets, contrast, screen-reader labels, large-text support.
- [ ] P11.3 Small-phone layout check, landscape, empty and error states, loading states.
- [ ] P11.4 Performance: scrolling at 60 fps on a mid-range phone, no jank during import.
Done when: no screen uses the old solid card style and the owner has seen screenshots.

### PHASE 12. QA, docs, release
- [ ] P12.1 Full test pass: all unit, widget and database tests; data-check workflow; offline test.
- [ ] P12.2 Docs: README, ARCHITECTURE, CLASSIC_PAD (behavior decisions), STYLE_PALETTE (categories and rules), SOURCES, CHANGELOG, user guide.
- [ ] P12.3 Release signing guide and a release workflow that stays manual only; versioning.
- [ ] P12.4 Final report listing exactly what is verified, what is only CI-tested, and what is not device-tested.
Done when: the app installs from the built APK, downloads Unicode data once, then works offline; Classic Pad does everything UnicodePad does; Style Studio builds reference-style names; the Name Generator produces themed designs; docs and CI are accurate.

---

## PART E. REPORT FORMAT (after every working session)

1. What changed (files and commits).
2. What now works, and how it was verified (CI run link, test names).
3. What is not verified (device, real data, performance).
4. Updated completion estimate and the updated phase table.
5. Next step and any single question for the owner.
