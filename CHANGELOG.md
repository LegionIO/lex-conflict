# Changelog

## [0.1.1] - 2026-03-14

### Added
- StaleCheck periodic actor (Every 3600s) — scans all active conflicts and flags any exceeding STALE_CONFLICT_TIMEOUT (86400s) as stale by appending a system exchange
- Optional LLM enhancement via Helpers::LlmEnhancer — `suggest_resolution(description:, severity:, exchanges:)` suggests resolution notes and outcome for active conflicts; `analyze_stale_conflict(description:, severity:, age_hours:, exchange_count:)` analyzes stale conflicts and adds the analysis as a system exchange

## [0.1.0] - 2026-03-13

### Added
- Initial release
