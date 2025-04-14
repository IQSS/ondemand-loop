#!/bin/bash
# Create the folder if it doesn't exist
mkdir -p app/javascript/fontawesome

# Download ESM versions from JSPM.io

curl -o app/javascript/fontawesome/fontawesome-svg-core.js \
  https://ga.jspm.io/npm:@fortawesome/fontawesome-svg-core@6.5.0/index.mjs

curl -o app/javascript/fontawesome/free-solid-svg-icons.js \
  https://ga.jspm.io/npm:@fortawesome/free-solid-svg-icons@6.5.0/index.mjs

curl -o app/javascript/fontawesome/free-regular-svg-icons.js \
  https://ga.jspm.io/npm:@fortawesome/free-regular-svg-icons@6.5.0/index.mjs

curl -o app/javascript/fontawesome/free-brands-svg-icons.js \
  https://ga.jspm.io/npm:@fortawesome/free-brands-svg-icons@6.5.0/index.mjs
