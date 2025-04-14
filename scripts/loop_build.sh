#!/bin/bash

LOOP_ROOT_URL=${ROOT_URL:-/pun/sys/loop}

bundle config path --local vendor/bundle
npm install
bundle install
echo "Building with PATH=($LOOP_ROOT_URL)"
env RAILS_RELATIVE_URL_ROOT="$LOOP_ROOT_URL" bundle exec rails assets:precompile

