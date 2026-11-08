# Architecture

## Repository inspection (Phase 1)

The repository contained only a 24-byte README.md. It was treated as empty, so the default stack applies: Flutter + Dart, Material 3, SQLite (sqflite), shared_preferences, Riverpod for state, go_router for navigation.

## Layers (Clean Architecture, feature-first)

```
lib/
  core/        theme, constants, errors, unicode utilities (pure Dart, no Flutter imports)
  database/    SQLite schema, migrations, DAOs, importer
  models/      immutable domain entities
  services/    clipboard, share, export, normalization, font transformation
  providers/   Riverpod providers wiring services/repositories to UI
  features/    home, explorer, name_studio, composer, combining_lab,
               emoji_library, favorites, settings
  shared/      reusable widgets
  main.dart
```

Rules: UI depends on providers; providers depend on services/repositories; the database layer never imports UI. Pure logic lives in core or feature domain layers so it can be unit-tested without a device.

## Unicode data pipeline (Phase 3)

1. Detect and download the latest Unicode Character Database (UCD) files.
2. Parse them into versioned SQLite tables.
3. Import transactionally on first run; all app data is read offline afterwards.

## UI direction — Glass design system

The app-wide visual direction is a premium dark glass UI, not isolated glass cards.

- Build a reusable Flutter glass design system in a dedicated theme/shared layer; do not add the Kotlin/Compose Haze dependency to this Flutter project.
- Apply glass treatment consistently to primary/secondary buttons, app bars, bottom navigation, tab bars, cards, dialogs, sheets, and floating controls.
- Use translucent layered surfaces, controlled backdrop blur, subtle gradient tint, thin edge highlights, soft depth, and restrained accent glow.
- Keep text and icons high-contrast and readable; never put important labels over a busy blurred background without a legible scrim.
- Keep blur radii and animation work restrained on lower-end Android devices; provide a reduced-transparency or solid-surface fallback.
- Use the same tokens, radii, spacing, elevation, and interaction states throughout all screens.
- Avoid overusing glass on every nested element; group related controls into coherent glass surfaces.

Haze is a Jetpack Compose/Compose Multiplatform library, not a Flutter widget package. Recreate the intended visual language with Flutter-native rendering or a Flutter-compatible package selected and tested during the UI polish phase.

## Key design decisions

- Characters and sequences are separate tables; a code point is never assumed to be a visible glyph.
- Grapheme handling and normalization are explicit operations.
- Rendering compatibility is advisory only; the app warns rather than promises.
