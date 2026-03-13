# frozen_string_literal: true

module Legion
  module Extensions
    module Conflict
      module Helpers
        module Severity
          LEVELS = %i[low medium high critical].freeze
          POSTURES = %i[speak_once persistent_engagement stubborn_presence].freeze

          # Posture selection thresholds
          PERSISTENT_THRESHOLD = :high
          STUBBORN_THRESHOLD   = :critical

          LEVEL_ORDER = { low: 0, medium: 1, high: 2, critical: 3 }.freeze

          module_function

          def valid_level?(level)
            LEVELS.include?(level)
          end

          def valid_posture?(posture)
            POSTURES.include?(posture)
          end

          def recommended_posture(severity)
            case severity
            when :critical then :stubborn_presence
            when :high     then :persistent_engagement
            else :speak_once
            end
          end

          def severity_gte?(a, b)
            LEVEL_ORDER.fetch(a, 0) >= LEVEL_ORDER.fetch(b, 0)
          end
        end
      end
    end
  end
end
