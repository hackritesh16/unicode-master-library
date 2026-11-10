# Instructions for AI coding agents

This project is UNICODE MASTER LIBRARY: an offline-first Android app (Flutter) for exploring Unicode, a UnicodePad-style editor (Classic Pad), a Style Palette for decorated names, and a name generator.

## Do this first, every time

The owner may say only "start", "continue" or "karo". That means:

1. Read `docs/MASTER_PROMPT.md` completely. It is the master prompt with every phase and rule.
2. Read `docs/PROGRESS.md` (status tracker). Do not trust it blindly.
3. Run the **Step 0 audit** from Part A of the master prompt: inspect the real file tree, `pubspec.yaml`, recent commits, open branches and pull requests, and the latest CI runs. Compare with the phase checklists and mark each item DONE, PARTIAL, MISSING or BROKEN from evidence.
4. Tell the owner, briefly and in the language they write in (Hinglish is fine): how much is done, a phase table, and what you will do next.
5. Update `docs/PROGRESS.md`, commit it, then start on the first unfinished phase. Do not wait for permission unless you are blocked; if blocked ask one clear question.

## Short rules (full rules are in the master prompt)

- Inspect before changing. Do not rewrite working code. Small commits. Re-read a file right before editing it.
- Official Unicode data only; never hardcode the Unicode version. Output strings are exact (no silent normalization).
- Never mark unfinished work as done. No dummy data posing as features. Label anything not run on a real phone as not device-tested.
- CI (`.github/workflows/ci.yml`) must be green: `flutter analyze` and `flutter test`. Never merge a PR with red CI.
- `.github/workflows/build.yml` is manual only. Never add push or pull_request triggers to it.
- Other agents may be pushing to this repository. Check open branches and PRs first. Never force-push or delete other branches.
- No ads, no analytics. Credit Unicode, UnicodePad (Apache-2.0) and bundled fonts. Do not add a LICENSE file without asking the owner.
- After every working session, report: what changed, what is verified (with CI link), what is not verified, the updated progress, and the next step.
