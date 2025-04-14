#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
"$SCRIPT_DIR/loop_build.sh"
bundle exec rake test
