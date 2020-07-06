# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/bitrise_automation/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-bitrise_automation'
  spec.version       = Fastlane::BitriseAutomation::VERSION
  spec.author        = 'Mario Cecchi'
  spec.email         = 'macecchi@gmail.com'

  spec.summary       = 'sei la'
  # spec.homepage      = "https://github.com/<GITHUB_USERNAME>/fastlane-plugin-bitrise_automation"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.150.3')
end
