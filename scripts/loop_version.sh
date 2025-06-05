#!/bin/bash

if [ -z "$VERSION_TYPE" ]; then
  echo "VERSION_TYPE is not set. Must be one of: patch, minor, major."
  exit 1
fi

bundle config path --local vendor/bundle
bundle config set build.nokogiri --use-system-libraries
bundle config set force_ruby_platform true
bundle install
bundle exec rake version:$VERSION_TYPE
