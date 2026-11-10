# Architecture and Product Decisions

Short dated record of decisions that affect implementation. Add a new entry instead of silently reversing an earlier decision.

## 2026-11-10

- **Flutter-native glass UI:** Use Flutter rendering such as BackdropFilter and reusable glass widgets. Do not add Jetpack Compose Haze to this Flutter app; Haze is not a Flutter widget library.
- **Unicode source of truth:** Official Unicode Character Database files define assigned characters, names, properties, ranges and emoji data. Curated style lists are an additional presentation layer, not a replacement for UCD data.
- **Exact text output:** Preserve the exact code-point sequence unless the user explicitly invokes a normalization/conversion operation. Use grapheme-aware editing for cursor and deletion behavior.
- **AI agent workflow:** AGENTS.md and docs/MASTER_PROMPT.md define the mandatory audit-first workflow. docs/PROGRESS.md records verified implementation status.
- **License selection:** No repository-wide LICENSE is added until the owner chooses a project license. Third-party data, code and fonts must retain their own attribution and license notices.
