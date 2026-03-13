# frozen_string_literal: true

require 'legion/extensions/conflict/helpers/severity'
require 'legion/extensions/conflict/helpers/conflict_log'
require 'legion/extensions/conflict/runners/conflict'

module Legion
  module Extensions
    module Conflict
      class Client
        include Runners::Conflict

        def initialize(**)
          @conflict_log = Helpers::ConflictLog.new
        end

        private

        attr_reader :conflict_log
      end
    end
  end
end
