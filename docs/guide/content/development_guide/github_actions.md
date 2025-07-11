# GitHub Actions

This project uses several GitHub Actions workflows to automate testing, releases, and documentation. Below is a summary of each workflow and when it runs.

## Workflow Summaries

- **test.yml** – Runs the full test suite via `make test` on pull requests and pushes to the `main` branch. It also generates SimpleCov coverage badges when changes are pushed to `main`.
- **guide.yml** – Builds this guide using `make guide` and deploys it to GitHub Pages whenever documentation under `docs/guide` changes on `main`.
- **build.yml** – Manually triggered workflow used to create a production build from a given tag and push the result to the `iqss_production` branch (no deployment occurs).
- **build_from_hash.yml** – Reusable workflow called by other workflows to build Loop from a specific commit hash for QA or release candidate deployments.
- **create_release_candidate.yml** – Triggered via a `/create_release_candidate` issue comment. Validates the issue, then uses `build_from_hash.yml` to build a release candidate branch for testing (no deployment).
- **create_release.yml** – Triggered via a `/create_release` issue comment. After verifying the last release candidate succeeded and was approved, it calls `release.yml` to tag and publish the release.
- **release.yml** – Internal workflow used by `create_release.yml` to run tests, bump the version file, create a Git tag, and generate GitHub release notes.
- **label_issues_on_release.yml** – Runs when a GitHub Release is published. It labels closed issues with `released:<tag>` so they can be tracked easily. It can also be run manually with a tag.
- **slash_command_listener.yml** – Listens for issue comments containing `/create_release_candidate` or `/create_release`. Only authorized users may invoke these commands, which dispatch the respective workflows above.

These workflows ensure that code is automatically tested, releases are repeatable, and the documentation site stays up to date.
