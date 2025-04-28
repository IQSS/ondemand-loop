#!/bin/bash

bundle config path --local vendor/bundle
bundle install
bundle exec rake test
