$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'simplecov'
require 'codecov'

# SimpleCov.minimum_coverage 95
SimpleCov.start

code_coverage_token = ENV['CODECOV_TOKEN'] || false

# If the environment variable is present, format for Codecov
SimpleCov.formatter = SimpleCov::Formatter::Codecov if code_coverage_token

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/wpmreleasetoolkit' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)

RSpec.configure do |config|
  config.filter_run_when_matching :focus
end

def set_circle_env(define_ci)
  is_ci = ENV.key?('CIRCLECI')
  orig_circle_ci = ENV['CIRCLECI']
  if define_ci
    ENV['CIRCLECI'] = 'true'
  else
    ENV.delete 'CIRCLECI'
  end

  yield
ensure
  if is_ci
    ENV['CIRCLECI'] = orig_circle_ci
  else
    ENV.delete 'CIRCLECI'
  end
end

# Allows Action.sh to be executed even when running in a test environment (where Fastlane's code disables it by default)
#
def allow_fastlane_action_sh
  # See https://github.com/fastlane/fastlane/blob/e6bd288f17038a39cd1bfc1b70373cab1fa1e173/fastlane/lib/fastlane/helper/sh_helper.rb#L45-L85
  allow(FastlaneCore::Helper).to receive(:sh_enabled?).and_return(true)
end

# Allows to assert if an `Action.sh` command has been triggered by the action under test.
# Requires `allow_fastlane_action_sh` to have been called so that `Action.sh` actually calls `Open3.popen2e`
#
# @param [String...] *command List of the command and its parameters to run
# @param [Int] exitstatus The exit status to expect. Defaults to 0.
# @param [String] output The output string to expect as a result of running the command. Defaults to "".
# @return [MessageExpectation] self, to support further chaining.
#
def expect_shell_command(*command, exitstatus: 0, output: '')
  mock_input = double(:input)
  mock_output = StringIO.new(output)
  mock_status = double(:status, exitstatus: exitstatus)
  mock_thread = double(:thread, value: mock_status)

  expect(Open3).to receive(:popen2e).with(*command).and_yield(mock_input, mock_output, mock_thread)
end
