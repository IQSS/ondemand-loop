ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require_relative 'helpers/file_fixture_helper'
require_relative 'helpers/model_helper'

require_relative 'utils/download_files_provider_mock'
require_relative 'utils/http_mock'
require_relative 'utils/logging_common_mock'

require 'rails/test_help'
require 'mocha/minitest'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Add more helper methods to be used by all tests here...
    include FileFixtureHelper
    include ModelHelper

    setup do
      # TODO: Review. This is a fix for the random errors in CI:
      # ArgumentError: `secret_key_base` for test environment must be a type of String`
      Rails.application.secret_key_base ||= "a_secure_dummy_key_for_tests"
    end
  end
end
