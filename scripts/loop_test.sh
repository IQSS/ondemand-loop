#!/bin/bash

bundle config path --local vendor/bundle
bundle config set build.nokogiri --use-system-libraries
bundle config set force_ruby_platform true
bundle install
bundle exec rake test
