# UNICODE MASTER LIBRARY

**Explore • Combine • Design • Create**

An offline-first Android app (Flutter) for exploring the Unicode character database, experimenting with combining marks, and designing decorated Unicode text and names.

> **Status:** Phase 1 of 10 (architecture and scaffold). No user-facing features are implemented yet. See [docs/PLAN.md](docs/PLAN.md) for progress.

## Planned features

- Unicode database built from official UCD data (see [SOURCES.md](SOURCES.md))
- Unicode Explorer with search by character, name, code point, block, script, category
- Combining Marks Laboratory
- Name Studio (themed design generator)
- Decorative Composer
- Emoji library, favorites, history, export

## Getting started

This repository contains `lib/`, `pubspec.yaml` and CI config but not the generated Android platform folder. Generate it once:

```bash
flutter create --platforms=android --project-name unicode_master_library .
flutter pub get
flutter test
flutter run
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Development plan](docs/PLAN.md)
- [Data sources](SOURCES.md)
