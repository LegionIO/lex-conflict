# frozen_string_literal: true

module Legion
  module Extensions
    module Conflict
      module Runners
        module Conflict
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def register_conflict(parties:, severity:, description:, **)
            return { error: :invalid_severity, valid: Helpers::Severity::LEVELS } unless Helpers::Severity.valid_level?(severity)

            id = conflict_log.record(parties: parties, severity: severity, description: description)
            conflict = conflict_log.get(id)
            { conflict_id: id, severity: severity, posture: conflict[:posture] }
          end

          def add_exchange(conflict_id:, speaker:, message:, **)
            result = conflict_log.add_exchange(conflict_id, speaker: speaker, message: message)
            result ? { recorded: true } : { error: :not_found }
          end

          def resolve_conflict(conflict_id:, outcome:, resolution_notes: nil, **)
            result = conflict_log.resolve(conflict_id, outcome: outcome, resolution_notes: resolution_notes)
            result ? { resolved: true, outcome: outcome } : { error: :not_found }
          end

          def get_conflict(conflict_id:, **)
            conflict = conflict_log.get(conflict_id)
            conflict ? { found: true, conflict: conflict } : { found: false }
          end

          def active_conflicts(**)
            conflicts = conflict_log.active_conflicts
            { conflicts: conflicts, count: conflicts.size }
          end

          def recommended_posture(severity:, **)
            { severity: severity, posture: Helpers::Severity.recommended_posture(severity) }
          end

          private

          def conflict_log
            @conflict_log ||= Helpers::ConflictLog.new
          end
        end
      end
    end
  end
end
