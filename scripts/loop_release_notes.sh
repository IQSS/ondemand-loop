#!/bin/bash
set -e

# Get the current tag (e.g., v1.2.3)
current_tag=$(git describe --tags --abbrev=0)

# Get the previous tag (e.g., v1.2.2)
previous_tag=$(git tag --sort=-creatordate | grep -v "$current_tag" | head -n 1)

echo "Generating release notes from $previous_tag to $current_tag"

# Collect commits
git log "$previous_tag..$current_tag" --pretty=format:"- %s (%h)" > release_notes.md

echo -e "\nRelease Notes:"
cat release_notes.md
