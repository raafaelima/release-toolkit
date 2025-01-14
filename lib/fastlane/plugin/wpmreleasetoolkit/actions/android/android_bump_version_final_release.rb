module Fastlane
  module Actions
    class AndroidBumpVersionFinalReleaseAction < Action
      def self.run(params)
        UI.message 'Bumping app release version...'

        require_relative '../../helper/android/android_git_helper'
        require_relative '../../helper/android/android_version_helper'

        Fastlane::Helper::GitHelper.ensure_on_branch!('release')

        current_version = Fastlane::Helper::Android::VersionHelper.get_release_version
        current_version_alpha = Fastlane::Helper::Android::VersionHelper.get_alpha_version
        final_version = Fastlane::Helper::Android::VersionHelper.calc_final_release_version(current_version, current_version_alpha)

        vname = Fastlane::Helper::Android::VersionHelper::VERSION_NAME
        vcode = Fastlane::Helper::Android::VersionHelper::VERSION_CODE
        UI.message("Current version: #{current_version[vname]}(#{current_version[vcode]})")
        UI.message("Current alpha version: #{current_version_alpha[vname]}(#{current_version_alpha[vcode]})") unless current_version_alpha.nil?
        UI.message("New release version: #{final_version[vname]}(#{final_version[vcode]})")

        UI.message 'Updating app version...'
        Fastlane::Helper::Android::VersionHelper.update_versions(final_version, current_version_alpha)
        UI.message 'Done!'

        Fastlane::Helper::Android::GitHelper.commit_version_bump()
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Bumps the version of the app for a new beta.'
      end

      def self.details
        'Bumps the version of the app for a new beta.'
      end

      def self.available_options
        # Define all options your action supports.
      end

      def self.authors
        ['Automattic']
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
