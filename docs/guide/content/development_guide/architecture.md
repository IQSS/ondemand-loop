# Architecture and Code

OnDemand Loop is a [Ruby on Rails](https://rubyonrails.org/) application that runs as an [Open OnDemand
Passenger app](https://osc.github.io/ood-documentation/latest/tutorials/tutorials-passenger-apps.html).
The project follows standard Rails conventions as long as they do
not interfere with the modern simple design of the application.

Instead of a traditional database it stores the data required to function in YAML files on disk.
A small set of models like `Project`, `DownloadFile`, `UploadBundle`, and `UploadFile` inherit from
`ApplicationDiskRecord` which provides YAML based persistence.

Transfers are processed by background services started by
`DetachedProcessManager`.  Each service loops over pending download or upload
requests and spawns connector specific processors.  Status updates are recorded
back to the YAML metadata so the web UI can poll and display progress.

The web interface communicates with these services via simple command endpoints
exposed through the `CommandRegistry`.  This design keeps the runtime
lightweight while avoiding the need for a separate job queue.

Connectors encapsulate repository-specific logic and are loaded dynamically
through `ConnectorClassDispatcher`. They make Loop extensible by providing
custom processors and controllers for each repository. The reference
implementation is the [Dataverse](https://dataverse.org) connector, with [Zenodo](https://zenodo.org) as an additional
implementation. See the [Connectors](connectors.md) section for the exact features a
connector must implement.

### Development Environment
OnDemand Loop is designed to run entirely within Docker containers.  
The included `Makefile` handles image builds, container orchestration, and test execution.
This means there is no need to install Ruby, Node.js, or any dependencies locally—just:

- **Docker**
- **Docker Compose**
- **GNU Make**

With these installed, you can build, run, and test the application using a single set of commands.

#### Requirements
OnDemand Loop is built to align with Open OnDemand's environment, ensuring compatibility with its supported Ruby and Node.js versions.  
The application has been developed and tested against the following stack:

- **Rocky Linux** 8
- **Open OnDemand** v3.1.7
- **Ruby** 3.1
- **Node.js** 18

For a full compatibility matrix and upgrade notes, see the [Open OnDemand](ood.md) section.


### Project Layout
The repository root contains the following directories:

| Folder         | Purpose                                                                                      |
|----------------|----------------------------------------------------------------------------------------------|
| `application/` | Complete Rails app with `app/`, `config/`, `lib/`, tests, and Gem/Node dependencies.         |
| `docker/`      | Docker build assets including `Dockerfile.builder` and the OOD NGINX `loop.conf`.            |
| `docs/`        | Project documentation including this guide.                                                  |
| `scripts/`     | Shell scripts used by the `Makefile` for building, testing, versioning, and generating docs. |
| `config/`      | Environment files for Docker Compose. Currently contains `.env`.                             |
| `tools/`       | Helper files for project tooling.                                                            |

Other important files live at the root:

- `Makefile` – orchestrates Docker builds and helper commands.
- `docker-compose.yml` – defines the local environment container stack.
- `.github/` – GitHub Actions workflows for CI, guide and releases.

Inside `application/app` important subfolders include:

| Path           | Purpose                                                                 |
|----------------|-------------------------------------------------------------------------|
| `controllers/` | Rails controllers plus connector specific subfolders.                   |
| `views/`       | Rails views with the front end templates.                               |
| `models/`      | Disk based models such as `Project`, `DownloadFile` and `UploadBundle`. |
| `helpers/`     | Rails helpers with utilities to to use in the views.                    |
| `connectors/`  | Connector classes loaded via `ConnectorClassDispatcher`.                |
| `services/`    | Business logic for downloads, uploads and repository APIs.              |
| `process/`     | Lightweight background execution framework used by the services.        |

The main configuration class for the application is lives under `config/configuration_singleton.rb`.
This globally accessible object defines all adjustable settings which can be
overridden via YAML or environment variables (see the [Admin Guide](../admin/index.md) for details).

### Testing

OnDemand Loop uses a comprehensive testing strategy with multiple types of tests.
For instructions on running the test suite see the [Testing](testing.md) guide.

#### Unit and Integration Tests (`application/test`)

The Rails application uses standard [Rails testing](https://guides.rubyonrails.org/testing.html) with Minitest and Mocha for mocking. Test types include:

- **Unit tests** - Test individual components, models, and services in isolation
- **Integration tests** - Test interactions between different parts of the application
- **Controller tests** - Test HTTP request/response handling and routing
- **View tests** - Test view components and template rendering logic
- **System tests** - Test full user workflows through the browser interface

The static fixtures for tests are stored under `application/test/fixtures`.

#### End-to-End Tests (`e2e_tests/`)

Cypress-based E2E tests verify complete user workflows from the browser perspective:

- **User interface testing** - Validate UI components and user interactions
- **Cross-browser compatibility** - Test functionality across different browsers
- **Integration testing** - Verify the application works with external services
- **Regression testing** - Ensure new changes don't break existing functionality

E2E tests run in Docker containers for consistency and are integrated into the CI/CD pipeline. See the [E2E Tests](e2e_tests.md) guide for detailed information on writing and running these tests.
