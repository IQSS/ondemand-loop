# E2E Tests

OnDemand Loop uses [Cypress](https://cypress.io) for end-to-end (E2E) automated testing. These tests verify that the application works correctly from a user's perspective by simulating real interactions with the browser interface.

### Overview

The automated tests are located in the `e2e_tests/` directory and provide:

- **End-to-end testing** of critical user workflows
- **Docker-based execution** for consistency across development and CI/CD environments
- **GitHub Actions integration** for automated testing on code changes

#### Test Structure

```
e2e_tests/
├── cypress/
│   ├── e2e/                   # Test specifications
│   ├── plugins/               # Application plugins and utilities
│   ├── support/               # Cypress support files
│   │   └── e2e.js             # Global test setup
│   └── fixtures/              # Test data files
├── cypress.config.js          # Cypress configuration
├── package.json               # Node.js dependencies
├── Makefile                   # Test automation commands
└── docker-compose.yml         # Test environment setup
```

### Running Tests Locally

#### Prerequisites

- Docker and Docker Compose installed
- Make utility
- Access to test credentials (see [Local Environment](local_environment.md))

#### Quick Start

1. **Start the test environment:**

```bash
cd e2e_tests
make env_up
```

This command starts OnDemand Loop and all required services using Docker Compose.

2. **Build Cypress dependencies:**

```bash
make cypress_build
```

3. **Run tests:**

```bash
# Run all tests headless
make cypress_run
```

4. **Clean up:**

```bash
make clean
```

#### Available Make Targets

| Target | Description |
|--------|-------------|
| `env_up` | Start test environment (OOD, mocks, services) |
| `env_down` | Stop test environment |
| `env_status` | Show status of environment services |
| `env_logs` | Show logs from environment services |
| `cypress_deps` | Generate/update package-lock.json using Docker container |
| `cypress_build` | Build Cypress project and install dependencies |
| `cypress_run` | Run Cypress tests headless |
| `clean` | Stop environment and clean up artifacts |

#### Environment Variables

Configure tests using these environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `CYPRESS_SPEC` | Specific test spec to run | All tests |
| `LOOP_USERNAME` | Username for OOD authentication | - |
| `LOOP_PASSWORD` | Password for OOD authentication | - |
| `OOD_VERSION` | OnDemand version | `3.1.7` |

Example:
```bash
CYPRESS_SPEC=cypress/e2e/homepage.cy.js make cypress_run
```

### Writing Tests

#### Test Structure

Follow this pattern for new tests:

```javascript
import { visitLoopRoot } from '../plugins/navigation'

describe('Feature Name', () => {
  it('should perform expected behavior', () => {
    // Navigate to the application
    visitLoopRoot()
    
    // Interact with elements
    cy.get('[data-cy=element]').click()
    
    // Assert expected results
    cy.contains('Expected Text').should('be.visible')
  })
})
```

#### Best Practices

1. **Use data attributes** for element selection:  
   ```html
   <button data-cy="submit-button">Submit</button>
   ```   
   ```javascript
   cy.get('[data-cy=submit-button]').click()
   ```

2. **Leverage navigation utilities** instead of manual `cy.visit()` calls:  
   ```javascript
   // Good
   visitLoopRoot()
   
   // Avoid
   cy.visit('/pun/sys/loop', { auth: {...} })
   ```

3. **Use the cy.loop configuration** for consistent settings:  
   ```javascript
   cy.get('.slow-element', { timeout: cy.loop.timeout })
   ```

4. **Add descriptive test names** that explain the expected behavior:  
   ```javascript
   it('should display welcome message and beta notice on first visit', () => {
     // test implementation
   })
   ```

#### Adding New Tests

1. **Create test files** in `cypress/e2e/` with the `.cy.js` extension
2. **Follow naming conventions**: `feature-name.cy.js`
3. **Import/create required utilities**

#### CI/CD Integration

Tests run automatically in GitHub Actions on:

- **Push to main branch** with changes to `application/` or `e2e_tests/`
- **Pull requests** targeting main branch with changes to `application/` or `e2e_tests/`
- **Manual workflow dispatch**

#### GitHub Actions Workflow

The workflow (`.github/workflows/e2e-tests.yml`) performs:

1. **Build application** using `make release_build`
2. **Build Cypress** dependencies
3. **Start test environment** with `make env_up`
4. **Wait for Loop** to be ready using HTTP checks
5. **Run tests** with `make cypress_run`
6. **Upload artifacts** (results, screenshots) on failure

#### Test Artifacts

When tests fail, the following artifacts are automatically uploaded:

- **Screenshots** from failed tests
- **Test results** in JUnit XML format

### Troubleshooting

#### Debugging Tests

1. **View environment logs:**
   ```bash
   make env_logs
   ```

2. **Check service status:**
   ```bash
   make env_status
   ```

3. **Run specific tests:**
   ```bash
   CYPRESS_SPEC=cypress/e2e/homepage.cy.js make cypress_run
   ```

For additional help, consult the [Cypress documentation](https://docs.cypress.io/) or check the project's GitHub Issues.