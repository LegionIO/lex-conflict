# frozen_string_literal: true

require 'legion/extensions/conflict/version'
require 'legion/extensions/conflict/helpers/severity'
require 'legion/extensions/conflict/helpers/conflict_log'
require 'legion/extensions/conflict/runners/conflict'

module Legion
  module Extensions
    module Conflict
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
