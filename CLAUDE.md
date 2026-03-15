# lex-conflict

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Conflict resolution subsystem for the LegionIO cognitive architecture. Registers disagreements between the agent and human partners, recommends engagement postures based on severity, tracks exchanges, and manages resolution outcomes.

## Gem Info

- **Gem name**: `lex-conflict`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::Conflict`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/conflict/
  version.rb
  helpers/
    severity.rb      # LEVELS, POSTURES, LEVEL_ORDER, STALE_CONFLICT_TIMEOUT, valid_level?,
                     # recommended_posture, severity_gte?
    conflict_log.rb  # ConflictLog class - UUID-keyed conflict records
    llm_enhancer.rb  # LlmEnhancer module - suggest_resolution, analyze_stale_conflict
  runners/
    conflict.rb      # register_conflict, add_exchange, resolve_conflict, get_conflict,
                     # active_conflicts, check_stale_conflicts, recommended_posture
  actors/
    stale_check.rb   # StaleCheck - Every 3600s, calls check_stale_conflicts
spec/
  legion/extensions/conflict/
    runners/
      conflict_spec.rb
    client_spec.rb
```

## Key Constants (Helpers::Severity)

```ruby
LEVELS    = %i[low medium high critical]
POSTURES  = %i[speak_once persistent_engagement stubborn_presence]
LEVEL_ORDER            = { low: 0, medium: 1, high: 2, critical: 3 }
STALE_CONFLICT_TIMEOUT = 86_400  # 24 hours — conflicts active longer than this are flagged stale
```

Posture selection:
- `:critical` -> `:stubborn_presence`
- `:high` -> `:persistent_engagement`
- `:low` / `:medium` -> `:speak_once`

`severity_gte?(left, right)` compares severity levels numerically via `LEVEL_ORDER`.

## ConflictLog Class

`Helpers::ConflictLog` stores conflicts in a Hash keyed by UUID. Each conflict:
```ruby
{
  conflict_id: "uuid",
  parties:     [...],
  severity:    :high,
  posture:     :persistent_engagement,   # auto-assigned via recommended_posture
  description: "...",
  status:      :active,
  outcome:     nil,
  created_at:  Time,
  resolved_at: nil,
  exchanges:   []
}
```

`add_exchange(conflict_id, speaker:, message:)` appends to `exchanges` array.

`resolve(conflict_id, outcome:, resolution_notes:)` sets status to `:resolved`, records resolved_at.

`active_conflicts` filters by `status == :active`.

## Actor

| Actor | Schedule | Runner Method |
|---|---|---|
| `StaleCheck` | Every 3600s | `check_stale_conflicts` |

`StaleCheck` runs hourly. It scans all active conflicts and flags any that have been open longer than `STALE_CONFLICT_TIMEOUT` (24h) by appending a system exchange. When `legion-llm` is available, the exchange message includes an LLM-generated analysis and recommendation instead of the generic stale notice.

## LLM Enhancement

`Helpers::LlmEnhancer` provides optional LLM-powered conflict analysis via `legion-llm`. It is used when `Legion::LLM.started?` returns true; all calls degrade gracefully to nil on error or when LLM is unavailable.

| Method | Called From | Returns |
|---|---|---|
| `suggest_resolution(description:, severity:, exchanges:)` | `resolve_conflict` (when `resolution_notes` not provided) | `{ resolution_notes:, suggested_outcome: }` |
| `analyze_stale_conflict(description:, severity:, age_hours:, exchange_count:)` | `check_stale_conflicts` (when LLM available) | `{ analysis:, recommendation: }` |

`suggest_resolution` returns an outcome (`:resolved`, `:deferred`, or `:escalated`) and 2-3 sentence resolution notes describing the approach and next steps. `analyze_stale_conflict` returns a recommendation (`:escalate`, `:retry`, or `:close`) and an analysis explaining the rationale.

**Fallback**: `suggest_resolution` returns nil (caller passes `nil` resolution_notes through to the log). `analyze_stale_conflict` returns nil (stale exchange uses the generic `"conflict marked stale — no resolution after 24h"` message).

## Integration Points

- **lex-consent**: critical unresolved conflicts may block consent tier promotion
- **lex-governance**: conflicts that cannot be resolved bilaterally may be escalated to governance proposals
- **lex-tick**: `action_selection` phase checks for active `:critical` severity conflicts before proceeding
- **legion-llm**: optional dependency for LLM-enhanced resolution suggestions and stale conflict analysis

## Development Notes

- `register_conflict` validates severity before creating the record; invalid severity returns `{ error: :invalid_severity, valid: LEVELS }`
- The `posture` field can be overridden by passing `posture:` to `ConflictLog#record`, but the runner always uses `recommended_posture`
- Exchanges are stored in-memory without a size cap; long-running conflicts accumulate unbounded exchange history
- `check_stale_conflicts` does not change conflict `status`; it only appends a system exchange to signal staleness
