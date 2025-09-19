# Contributing a Change

We welcome contributions to OnDemand Loop!

Whether you're fixing bugs, adding features, or improving documentation, this guide will help you contribute effectively.

---

### 🔍 1. Plan Your Contribution
**Before you start coding:**
- [Search existing issues](https://github.com/IQSS/ondemand-loop/issues) to check if your idea is already being discussed
- For bug reports: Include steps to reproduce, expected vs actual behavior, and environment details
- For new features: Describe the use case and how it fits with OnDemand Loop's goals
- For small fixes: You can skip creating an issue and go straight to implementation

---

### ⚙️ 2. Set Up Your Development Environment

1. **Fork and clone** the repository
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-descriptive-branch-name
   ```
3. **Review the coding standards** in [CONTRIBUTING.md](https://github.com/IQSS/ondemand-loop/blob/main/CONTRIBUTING.md)
4. **Start the development environment:**
   ```bash
   make loop_build   # Builds the application
   make dev_up       # Starts the development environment
   ```

---

### 🧪 3. Implement and Test Your Changes
#### Writing Code
- Follow existing code patterns and conventions
- Keep changes focused and atomic
- Add comments for complex logic
- Update relevant documentation

#### Writing Tests
- **Always include tests** for new functionality or bug fixes
- Use **Minitest** for unit tests and **Mocha** for mocking
- Place tests in the appropriate `test/` subdirectory
- Aim for high test coverage on new code

#### Running Tests Locally
```bash
# Build the application first
make loop_build

# Run the full test suite
make test

# Run specific test files (if needed)
make test_bash
bundle exec rake test TEST=test/path/to/specific_test.rb

# Generate a coverage report
bundle exec rake test:coverage
```

**Understanding Coverage Reports:**
Running `bundle exec rake test:coverage` generates detailed coverage reports using [SimpleCov](https://github.com/simplecov-ruby/simplecov):

- **HTML report:** `application/tmp/coverage/index.html` (open in browser for detailed view)
- **Console output:** Shows line and branch coverage percentages

```bash
# Example output
Coverage report generated for Minitest to /usr/local/app/tmp/coverage.
Line Coverage: 92.38% (3272 / 3542)
Branch Coverage: 67.72% (579 / 855)
```

#### Documentation Changes
If you modified documentation:
```bash
make guide        # Build documentation locally
make guide_dev    # Serve at http://localhost:8000 for live preview
```

---

### 🚀 4. Submit Your Pull Request
#### Before Submitting
- [ ] All tests pass locally
- [ ] Code follows project conventions
- [ ] Documentation is updated (if applicable)
- [ ] Commit messages are clear and descriptive

#### Creating the PR
1. **Push your branch** to your fork
2. **Open a Pull Request** against the `main` branch
3. **Reference the related issue** (e.g., "Fixes #123" or "Addresses #456")
4. **Write a clear PR description:**
    - What problem does this solve?
    - What changes did you make?
    - How did you test it?
    - Any breaking changes or special considerations?

---

### 👀 5. Review Process

#### What Happens Next
1. **Automated checks** run (tests, linting, security scans)
2. **Team approval required** before CI pipeline runs (security measure)
3. **Code review** by maintainers
4. **Feedback and iteration** until approved
5. **Merge** when everything looks good

#### During Review
- **Be responsive** to feedback and questions
- **Ask for clarification** if review comments are unclear
- **Make requested changes** in new commits (don't force-push during review)
- **Be patient** - we'll review as soon as possible!

#### Quality Standards
We look for:

- ✅ Code quality and maintainability
- ✅ Adequate test coverage
- ✅ Documentation completeness
- ✅ Compatibility with existing features
- ✅ Performance considerations

---

### 🆘 Need Help?
- **Questions about the codebase?** Open a discussion or comment on your PR
- **Stuck on tests?** Check existing test patterns in the `test/` directory
- **General questions?** Feel free to ask in your issue or PR

!!! success "Thank you for contributing to OnDemand Loop! 🎉"
