module Fastlane
  module Actions
    class AndroidCompletecodefreezePrechecksAction < Action
      def self.run(params)
        UI.message "Skip confirm: #{params[:skip_confirm]}"

        require_relative '../../helper/android/android_version_helper.rb'
        require_relative '../../helper/android/android_git_helper.rb'

        UI.user_error!('This is not a release branch. Abort.') unless other_action.git_branch.start_with?('release/')

        app = ENV['APP'].nil? ? params[:app] : ENV['APP']

        version = Fastlane::Helper::Android::VersionHelper.get_public_version(app)
        message = "Completing code freeze for: [#{app}]#{version}\n"
        unless params[:skip_confirm]
          UI.user_error!('Aborted by user request') unless UI.confirm("#{message}Do you want to continue?")
        else
          UI.message(message)
        end

        # Check local repo status
        other_action.ensure_git_status_clean()

        version
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Runs some prechecks before finalizing a code freeze'
      end

      def self.details
        'Runs some prechecks before finalizing a code freeze'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :skip_confirm,
                                       env_name: 'FL_ANDROID_COMPLETECODEFREEZE_PRECHECKS_SKIPCONFIRM',
                                       description: 'Skips confirmation',
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: false), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :app,
                                       env_name: 'APP',
                                       description: 'The app to get the release version for',
                                       is_string: true, # true: verifies the input is a string, false: every kind of value
                                       default_value: 'wordpress'), # the default value if the user didn't provide one
        ]
      end

      def self.output
      end

      def self.return_type
        :string
      end

      def self.return_value
        'The version number that has been prechecked.'
      end

      def self.authors
        ['loremattei']
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
