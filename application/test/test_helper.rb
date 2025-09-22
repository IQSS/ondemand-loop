ENV['RAILS_ENV'] ||= 'test'
ENV['SECRET_KEY_BASE'] ||= 'test_secret_key_base_please_change'

# TEST COVERAGE SETUP
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.coverage_dir('tmp/coverage')

  SimpleCov.start 'rails' do
    enable_coverage :branch
    add_filter '/test/'

    add_group 'Controllers', 'app/controllers'
    add_group 'Models', 'app/models'
    add_group 'Services', 'app/services'
    add_group 'Connectors', 'app/connectors'
    add_group 'Helpers', 'app/helpers'
    add_group 'Libraries', 'app/lib'
    add_group 'Validators', 'app/validators'
    add_group 'Process', 'app/process'

    # Remove default Rails groups we don't use
    groups.delete('Channels')
    groups.delete('Jobs')
    groups.delete('Mailers')

    SimpleCov.formatters = [
      SimpleCov::Formatter::HTMLFormatter,
    ]
  end
end

require_relative '../config/environment'
require_relative 'utils/file_fixture_helper'
require_relative 'utils/model_helper'
require_relative 'utils/zenodo_helper'
require_relative 'utils/dataverse_helper'

require_relative 'utils/download_files_provider_mock'
require_relative 'utils/http_mock'
require_relative 'utils/logging_common_mock'

require 'rails/test_help'
require 'mocha/minitest'

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors) unless ENV['COVERAGE']

    # Add more helper methods to be used by all tests here...
    include FileFixtureHelper
    include ModelHelper
    include ZenodoHelper
    include DataverseHelper

  end
end
