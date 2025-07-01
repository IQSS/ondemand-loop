ENV['RAILS_ENV'] ||= 'test'

# THIS IS FOR DEBUGGING CI RANDOM ERRORS:
# ArgumentError: `secret_key_base` for test environment must be a type of String`
at_exit do
  if $!
    puts "\n=== Uncaught Exception at Exit ==="
    puts $!.class
    puts $!.message
    puts $!.backtrace.join("\n")
    puts "=== END Uncaught Exception ===\n\n"
  end
end

# TEST COVERAGE SETUP
require 'simplecov'

SimpleCov.coverage_dir('tmp/coverage') # 👈 Set custom output path

SimpleCov.start 'rails' do
  enable_coverage :branch
  add_filter '/test/'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
  ]
end

require_relative '../config/environment'
require_relative 'helpers/file_fixture_helper'
require_relative 'helpers/model_helper'
require_relative 'helpers/zenodo_helper'
require_relative 'helpers/dataverse_helper'

require_relative 'utils/download_files_provider_mock'
require_relative 'utils/http_mock'
require_relative 'utils/logging_common_mock'

require 'rails/test_help'
require 'mocha/minitest'

module ActiveSupport
  class TestCase
    # Run tests sequentially to preserve accurate coverage metrics

    # Add more helper methods to be used by all tests here...
    include FileFixtureHelper
    include ModelHelper
    include ZenodoHelper
    include DataverseHelper

    setup do
      begin
        Rails.application.secret_key_base ||= 'a_secure_dummy_key_for_tests'
        # THIS IS FOR DEBUGGING CI RANDOM ERRORS:
        # ArgumentError: `secret_key_base` for test environment must be a type of String`
      rescue ArgumentError => e
        puts "\n=== secret_key_base ArgumentError caught ==="
        puts e.message
        puts e.backtrace.join("\n")
        puts "=== END secret_key_base trace ===\n\n"
        raise e
      end
    end
  end
end
