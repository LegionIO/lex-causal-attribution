# frozen_string_literal: true

require_relative 'lib/legion/extensions/causal_attribution/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-causal-attribution'
  spec.version       = Legion::Extensions::CausalAttribution::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Causal Attribution'
  spec.description   = "Weiner's attribution theory for brain-modeled agentic AI — locus, stability, controllability"
  spec.homepage      = 'https://github.com/LegionIO/lex-causal-attribution'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-causal-attribution'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-causal-attribution'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-causal-attribution'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-causal-attribution/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-causal-attribution.gemspec Gemfile]
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
