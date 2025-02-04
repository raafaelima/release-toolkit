module Fastlane
  module Actions
    class IosGetBuildVersionAction < Action
      def self.run(params)
        require_relative '../../helper/ios/ios_version_helper'

        UI.user_error!('You need to set at least the PUBLIC_CONFIG_FILE env var to the path to the public xcconfig file') unless ENV['PUBLIC_CONFIG_FILE']

        if params[:internal]
          UI.user_error!('You need to set the INTERNAL_CONFIG_FILE env var to the path to the internal xcconfig file') unless ENV['INTERNAL_CONFIG_FILE']
          Fastlane::Helper::Ios::VersionHelper.get_internal_version
        else
          Fastlane::Helper::Ios::VersionHelper.get_build_version
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Gets the build version of the app'
      end

      def self.details
        'Gets the build version (`VERSION_LONG`) of the app from the xcconfig file'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :internal,
            env_name: 'FL_IOS_BUILD_VERSION_INTERNAL',
            description: 'If true, returns the internal build version, otherwise returns the public one',
            is_string: false, # Boolean
            default_value: false
          ),
        ]
      end

      def self.output
        # Define the shared values you are going to provide
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
        'Return the public or internal build version of the app'
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ['Automattic']
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
