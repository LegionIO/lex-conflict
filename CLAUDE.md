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
    severity.rb      # LEVELS, POSTURES, LEVEL_ORDER, valid_level?, recommended_posture, severity_gte?
    conflict_log.rb  # ConflictLog class - UUID-keyed conflict records
  runners/
    conflict.rb      # register_conflict, add_exchange, resolve_conflict, get_conflict,
                     # active_conflicts, recommended_posture
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
LEVEL_ORDER = { low: 0, medium: 1, high: 2, critical: 3 }
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

## Integration Points

- **lex-consent**: critical unresolved conflicts may block consent tier promotion
- **lex-governance**: conflicts that cannot be resolved bilaterally may be escalated to governance proposals
- **lex-tick**: `action_selection` phase checks for active `:critical` severity conflicts before proceeding

## Development Notes

- `register_conflict` validates severity before creating the record; invalid severity returns `{ error: :invalid_severity, valid: LEVELS }`
- The `posture` field can be overridden by passing `posture:` to `ConflictLog#record`, but the runner always uses `recommended_posture`
- Exchanges are stored in-memory without a size cap; long-running conflicts accumulate unbounded exchange history
