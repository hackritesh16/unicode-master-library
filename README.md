# UNICODE MASTER LIBRARY

**Explore · Combine · Design · Create**

An offline-first Flutter Android app for exploring Unicode, inserting characters, applying decorative marks and creating stylish text and names.

## Product areas

- **Unicode Explorer:** search characters by glyph, name, code point and Unicode properties.
- **Style Palette:** discover dots, accents, combining marks, underlines, arrows, ornaments and other decorative characters.
- **Style Studio:** apply marks and decorations to individual letters and full names.
- **Name Generator:** create themed Unicode name designs.
- **Classic Pad:** UnicodePad-inspired character editor with recent characters, Unicode lists, search, emoji, favorites, details and editing tools.
- **Library:** favorites, saved designs and recent history.
- **Premium dark glass UI:** reusable translucent surfaces, app bars, buttons and navigation.

Feature status is tracked in [docs/PROGRESS.md](docs/PROGRESS.md). Planned behavior and the mandatory AI-agent workflow are in [docs/MASTER_PROMPT.md](docs/MASTER_PROMPT.md). The architecture is documented in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Development

Requirements: Flutter stable and Dart version compatible with `pubspec.yaml`.

```bash
flutter pub get
flutter analyze
flutter test
```

To create the Android platform folder if it is absent:

```bash
flutter create --platforms=android .
flutter pub get
```

Run on a connected Android device or emulator:

```bash
flutter run
```

The repository CI workflow runs analysis and tests. The APK workflow is manual-only; open **GitHub → Actions → Build APK → Run workflow** to build an APK. A successful CI or APK workflow does not mean the app has been physically tested on a phone.

## Working with AI coding agents

Start by reading [AGENTS.md](AGENTS.md), [docs/MASTER_PROMPT.md](docs/MASTER_PROMPT.md) and [docs/PROGRESS.md](docs/PROGRESS.md). Every agent must inspect the current code, open PRs and latest CI before changing files. The progress tracker is not proof: each feature must be verified in the implementation and tests.

## Data and attribution

Unicode data is sourced from the Unicode Character Database. UnicodePad is a functional reference, not code to copy blindly. See [SOURCES.md](SOURCES.md) for source and license details.

## Current status

This project is under active development. Some planned capabilities are partial or missing. Check [docs/PROGRESS.md](docs/PROGRESS.md) for the current audited status. Real-device rendering, font compatibility and large-dataset performance must be verified separately from CI.
