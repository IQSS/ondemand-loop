# Testing

OnDemand Loop uses a comprehensive testing strategy to ensure stability, correctness, and confidence when making changes.  
The testing approach covers everything from low-level unit tests to full end-to-end workflows, allowing contributors to verify functionality at the right level of detail.

All tests run inside Docker for a consistent and reproducible environment.  
They are integrated with CI/CD so every pull request is validated automatically.

---

### Overview
The test suite is divided into layers:

- **Unit tests** – verify models, services, and helpers in isolation.
- **Integration tests** – check how components interact across boundaries (controllers, connectors).
- **System tests** – simulate user flows in a real browser using Rails’ built-in system test framework.
- **End-to-End (E2E) tests** – Cypress tests that run against the full application stack (see [E2E Tests](e2e_tests.md)).

All Rails tests live under `application/test` and follow Rails conventions:

| Directory         | Purpose |
|-------------------|---------|
| `models/`         | Model behavior and validation |
| `controllers/`    | HTTP request/response handling |
| `services/`       | Business logic and helpers |
| `connectors/`     | Repository-specific logic |
| `integration/`    | Higher-level interactions |
| `system/`         | Browser-driven Rails system tests |
| `views/`, `helpers/`, `lib/`, `utils/` | Other layers |
| `fixtures/`       | Sample data for deterministic tests |

Tests use [Minitest](https://guides.rubyonrails.org/testing.html) with [Mocha](https://mocha.jamesmead.org/) for mocking.  

---

### Running Tests
Tests run inside a Docker container using the provided `Makefile` targets.

#### Common Targets
- `make test_bash` – open an interactive shell inside the test container.
- `make test_exec` – run commands non-interactively (piped via `echo`).

#### Run the full suite
```bash
echo 'bundle exec rake test' | make test_exec
```

#### Run a single test file
```bash
echo 'bundle exec rake test TEST=test/models/application_disk_record_test.rb' | make test_exec
```

#### Run a specific test by line number
```bash
echo 'bundle exec rake test TEST=test/models/application_disk_record_test.rb:52' | make test_exec
```

#### Run all tests in a directory
```bash
echo 'bundle exec rake test TEST="test/services/**/*_test.rb"' | make test_exec
```

#### Use options (verbose, stop on failure, seed)
```bash
echo 'bundle exec rake test TESTOPTS="--verbose --stop-on-failure --seed=1234"' | make test_exec
```

### Interactive Mode
For exploratory work, start a shell and run tests manually:
```bash
make test_bash
bundle exec rake test
```

---

### Best Practices
- Keep tests **fast** and **isolated**; prefer fixtures and mocks over external dependencies.
- Use **descriptive test names** that explain behavior, not implementation.
- Organize tests consistently with application code (mirror directory structure).
- Add **system tests** for new UI workflows; add **E2E tests** when behavior depends on the full environment.
- Run the full test suite locally before opening a pull request.  
