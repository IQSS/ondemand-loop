# GitHub Actions
This project uses several GitHub Actions workflows to automate testing, releases, and documentation.
Access to these workflows varies based on user permissions.

For the actual definition of the workflows refer to the [repository source](https://github.com/IQSS/ondemand-loop/tree/main/.github/workflows).

### Workflow Summaries

- **test.yml** – Runs the full test suite via `make test` on pull requests and pushes to the `main` branch. It also generates SimpleCov coverage badges when changes are pushed to `main`.
- **guide.yml** – Builds this guide using `make guide` and deploys it to GitHub Pages whenever documentation under `docs/guide` changes on `main`.
- **build_from_hash.yml** – Reusable workflow called by other workflows to build Loop from a specific commit hash for QA or release candidate deployments.
- **create_release_candidate.yml** – Triggered via a `/create_release_candidate` issue comment. Validates the issue, then uses `build_from_hash.yml` to build a release candidate branch for testing (no deployment).
- **create_release.yml** – Triggered via a `/create_release` issue comment. After verifying the last release candidate succeeded and was approved, it calls `release.yml` to tag and publish the release.
- **release.yml** – Internal workflow used by `create_release.yml` to run tests, bump the version file, create a Git tag, and generate GitHub release notes.
- **label_issues_on_release.yml** – Runs when Release is created. It labels closed issues with `released:<tag>` so they can be tracked easily. It can also be run manually with a tag.
- **slash_command_listener.yml** – Listens for issue comments containing `/create_release_candidate` or `/create_release`. Only authorized users may invoke these commands, which dispatch the respective workflows above.

These workflows ensure that code is automatically tested, releases are repeatable, and the documentation site stays up to date.
