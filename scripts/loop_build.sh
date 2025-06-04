#!/bin/bash

LOOP_ROOT_URL=${APP_ROOT:-/pun/sys/loop}
LOOP_ENV=${APP_ENV:-development}

bundle config path --local vendor/bundle
npm install
bundle install
echo "--------------------------------------------------------"
echo "Building with PATH= $LOOP_ROOT_URL ENV= $LOOP_ENV"
echo "--------------------------------------------------------"
env RAILS_RELATIVE_URL_ROOT="$LOOP_ROOT_URL" RAILS_ENV="$LOOP_ENV" bundle exec rails assets:precompile

