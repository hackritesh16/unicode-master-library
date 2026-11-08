# UNICODE MASTER LIBRARY

**Explore • Combine • Design • Create**

An offline-first Android app (Flutter) for exploring Unicode characters, experimenting with combining marks, and designing decorated Unicode text and names.

> **Status:** Phases 1–9 implemented; CI verification in progress. Physical Android verification and the first full Unicode database import remain outstanding. See [docs/PLAN.md](docs/PLAN.md) for progress.

## Features

- Unicode database pipeline based on official UCD data (see [SOURCES.md](SOURCES.md))
- Unicode Explorer with search by character, name, code point, block, script and category
- Combining Marks Laboratory with live preview and curated marks
- Name Studio with five Unicode styles, search and one-tap copy
- Decorative Composer with six frames, custom prefix/suffix and live preview
- Emoji & Symbol Library with category filters, search and one-tap copy
- Home dashboard with quick access to app tools
- Local favorites and recent history with removal and copy actions
- Final glass UI polish, performance checks and release verification remain

## Getting started

The generated Android platform folder is not committed. Generate it once with the Flutter create command, then run flutter pub get, flutter test and flutter run.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Development plan](docs/PLAN.md)
- [Data sources](SOURCES.md)
