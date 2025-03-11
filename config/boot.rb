ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# load dotenv files before "before_configuration" callback
require File.expand_path('configuration_singleton', __dir__)

# global instance to access and use
Configuration = ConfigurationSingleton.new