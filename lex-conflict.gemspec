# frozen_string_literal: true

require_relative 'lib/legion/extensions/conflict/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-conflict'
  spec.version       = Legion::Extensions::Conflict::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Conflict'
  spec.description   = 'Conflict resolution with severity levels and postures for brain-modeled agentic AI'
  spec.homepage      = 'https://github.com/LegionIO/lex-conflict'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/LegionIO/lex-conflict'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-conflict'
  spec.metadata['changelog_uri'] = 'https://github.com/LegionIO/lex-conflict'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/LegionIO/lex-conflict/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-conflict.gemspec Gemfile]
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
