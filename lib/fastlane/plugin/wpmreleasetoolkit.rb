require 'fastlane/plugin/wpmreleasetoolkit/version'

module Fastlane
  module Wpmreleasetoolkit
    # Return all .rb files inside the "actions", "helper" and "models" directories
    def self.all_classes
      Dir[File.expand_path('**/{actions,helper,models}/**/*.rb', File.dirname(__FILE__))]
    end
  end
end

# By default we want to import all available actions and helpers
# A plugin can contain any number of actions and plugins
Fastlane::Wpmreleasetoolkit.all_classes.each do |current|
  require current
end
