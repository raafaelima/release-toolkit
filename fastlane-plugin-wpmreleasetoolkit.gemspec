lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/wpmreleasetoolkit/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-wpmreleasetoolkit'
  spec.version       = Fastlane::Wpmreleasetoolkit::VERSION
  spec.author        = 'Automattic'
  spec.email         = 'mobile@automattic.com'

  spec.summary       = 'GitHub helper functions'
  spec.homepage      = 'https://github.com/wordpress-mobile/release-toolkit'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7'

  spec.files         = Dir['lib/**/*'] + %w[README.md LICENSE]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  # Bring in any generated executables
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'
  spec.add_dependency 'activesupport', '~> 5'
  spec.add_dependency 'buildkit', '~> 1.5'
  spec.add_dependency 'chroma', '0.2.0'
  spec.add_dependency 'diffy', '~> 3.3'
  spec.add_dependency 'git', '~> 1.3'
  spec.add_dependency 'jsonlint', '~> 0.3'
  spec.add_dependency 'nokogiri', '~> 1.11' # Needed for AndroidLocalizeHelper
  spec.add_dependency 'octokit', '~> 4.18'
  spec.add_dependency 'parallel', '~> 1.14'
  spec.add_dependency 'plist', '~> 3.1'
  spec.add_dependency 'progress_bar', '~> 1.3'
  spec.add_dependency 'rake', '>= 12.3', '< 14.0'
  spec.add_dependency 'rake-compiler', '~> 1.0'

  # `google-cloud-storage` is required by fastlane, but we pin it in case it's not in the future
  spec.add_dependency 'google-cloud-storage', '~> 1.31'

  # Some of the upstream code uses `BigDecimal.new` which version 2.0 of the
  # `bigdecimal` gem removed. Until we'll find the time to identify the
  # dependencies and see if we can move them to something compatible with
  # modern `bigdecimal`, let's constrain the gem to a version still supporting
  # `.new` but which warns about it deprecation.
  spec.add_dependency 'bigdecimal', '~> 1.4'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'cocoapods', '~> 1.10'
  # Use at least Fastlene 2.210.0 to ensure compatibility with the Xcode 14 toolchain
  # See https://github.com/fastlane/fastlane/releases/tag/2.210.0
  spec.add_development_dependency 'fastlane', '~> 2.210'
  spec.add_development_dependency 'pry', '~> 0.12.2'
  spec.add_development_dependency 'rmagick', '~> 4.1'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4.1'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-require_tools', '~> 0.1.2'
  spec.add_development_dependency 'rubocop-rspec', '2.3.0'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
end
