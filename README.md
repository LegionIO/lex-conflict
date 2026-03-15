# lex-conflict

Conflict resolution with severity levels and postures for brain-modeled agentic AI. Tracks disagreements between the agent and human partners, recommends engagement postures, and manages resolution outcomes.

## Overview

`lex-conflict` implements the agent's mechanism for handling disagreements. When the agent and a human partner have different views on a decision, a conflict is registered with a severity level. The system recommends a posture (how persistently to advocate the agent's position) and tracks the conflict through resolution.

## Severity Levels

| Level | Description |
|-------|-------------|
| `:low` | Minor difference in approach or preference |
| `:medium` | Meaningful disagreement on method or priority |
| `:high` | Significant disagreement with outcome implications |
| `:critical` | Fundamental conflict requiring immediate resolution |

## Engagement Postures

| Posture | Triggered At | Behavior |
|---------|-------------|----------|
| `:speak_once` | low, medium | State position once, then defer |
| `:persistent_engagement` | high | Continue raising the concern |
| `:stubborn_presence` | critical | Refuse to proceed without resolution |

## Installation

Add to your Gemfile:

```ruby
gem 'lex-conflict'
```

## Usage

### Registering a Conflict

```ruby
require 'legion/extensions/conflict'

result = Legion::Extensions::Conflict::Runners::Conflict.register_conflict(
  parties: ["agent", "user-alice"],
  severity: :high,
  description: "Agent recommends rollback; user wants to proceed with deployment"
)
# => { conflict_id: "uuid", severity: :high, posture: :persistent_engagement }
```

### Adding Exchanges

```ruby
# Log the discussion
Legion::Extensions::Conflict::Runners::Conflict.add_exchange(
  conflict_id: "uuid",
  speaker: "agent",
  message: "Error rate is 12%, above the 5% safe threshold"
)
```

### Resolving

```ruby
Legion::Extensions::Conflict::Runners::Conflict.resolve_conflict(
  conflict_id: "uuid",
  outcome: :agent_deferred,
  resolution_notes: "User acknowledged risk and chose to proceed"
)
# => { resolved: true, outcome: :agent_deferred }
```

### Querying

```ruby
# All active conflicts
Legion::Extensions::Conflict::Runners::Conflict.active_conflicts
# => { conflicts: [...], count: 1 }

# Get a specific conflict
Legion::Extensions::Conflict::Runners::Conflict.get_conflict(conflict_id: "uuid")

# Get recommended posture for a severity level
Legion::Extensions::Conflict::Runners::Conflict.recommended_posture(severity: :critical)
# => { severity: :critical, posture: :stubborn_presence }
```

## Actors

| Actor | Interval | Description |
|-------|----------|-------------|
| `StaleCheck` | Every 3600s | Scans all active conflicts and flags any that have been open longer than STALE_CONFLICT_TIMEOUT (86400s) by appending a system exchange. When LLM enhancement is available, the exchange includes an LLM-generated analysis and recommendation instead of the generic stale notice. |

## LLM Enhancement

`Helpers::LlmEnhancer` provides optional LLM-powered conflict analysis when `legion-llm` is loaded and `Legion::LLM.started?` returns true. All methods rescue `StandardError` and return `nil` — callers always fall back to mechanical processing.

| Method | Description |
|--------|-------------|
| `suggest_resolution(description:, severity:, exchanges:)` | Suggests resolution notes and a recommended outcome (`:resolved`, `:deferred`, or `:escalated`) for an active conflict based on its history |
| `analyze_stale_conflict(description:, severity:, age_hours:, exchange_count:)` | Analyzes a stale conflict and returns a recommendation (`:escalate`, `:retry`, or `:close`) with explanatory analysis text |

Mechanical fallback: `suggest_resolution` returns `nil` (caller passes `nil` resolution_notes through to the log). `analyze_stale_conflict` returns `nil` and the stale exchange uses the generic `"conflict marked stale — no resolution after 24h"` message.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
