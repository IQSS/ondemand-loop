# Contributing a Change

This project welcomes contributions! Follow the steps below to submit code improvements or new features.

## 1. Create an Issue
- Search existing issues to avoid duplicates.
- If your idea or bug is new, open an issue describing the problem or feature request.

## 2. Implement the Change with Tests
- Create a topic branch from `main`.
- Follow the style guidelines in [CONTRIBUTING.md](https://github.com/IQSS/ondemand-loop/blob/main/CONTRIBUTING.md).
- Write tests using Minitest and Mocha to cover your change.

## 3. Run the Test Suite
Execute the tests inside the Docker builder image:
```bash
make test
```
This command runs `bundle exec rake test` to execute the tests. The suite generates a coverage report using [SimpleCov](https://github.com/simplecov-ruby/simplecov). The HTML report is saved under `application/tmp/coverage/index.html`, open to view details.

The coverage results are printed in the test output. Example:
```bash
Finished in 10.208027s, 59.7569 runs/s, 167.3193 assertions/s.
610 runs, 1708 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for Minitest to /usr/local/app/tmp/coverage.
Line Coverage: 92.38% (3272 / 3542)
Branch Coverage: 67.72% (579 / 855)
```

If you changed any documentation run `make guide` to build the MkDocs site locally. Use `make guide_dev` to serve it at `http://localhost:8000` for quick previews.

## 4. Create a Pull Request
- Push your branch and open a PR referencing the issue.
- Describe what you changed and why.
- Verify that tests pass in CI and that coverage remains high.

## 5. Wait for Review
Address any feedback from maintainers until the PR is approved and merged.
