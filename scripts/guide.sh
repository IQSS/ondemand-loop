#!/bin/bash

# Build or serve the user guide with MkDocs
set -e

# Install MkDocs each run so the container can remain lightweight
pip install --quiet -r docs/guide/requirements.txt

# Use an absolute path for the output directory so MkDocs does not
# treat it as a subdirectory of the documentation folder.
SITE_DIR="$(pwd)/site"
MKDOCS_CONFIG="docs/guide/mkdocs.yml"

if [[ "$DEV" == "true" ]]; then
  echo "Running mkdocs in development mode..."
  mkdocs serve --livereload --watch docs/guide/overrides -f "$MKDOCS_CONFIG" -a 0.0.0.0:8000
else
  echo "Building mkdocs site..."
  mkdocs build -f "$MKDOCS_CONFIG" --site-dir "$SITE_DIR"
fi
