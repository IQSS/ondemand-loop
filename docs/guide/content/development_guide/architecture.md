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

### Requirements
OnDemand Loop aligns with Open OnDemand to ensure compatibility with the same Ruby and Node.js versions.
This version of the application was developed using the following runtime environments:
 - OnDemand v3.1.7
 - Ruby v3.1
 - NodeJS v18
 - Ruby on Rails v7.2.2.1

Testing with Open OnDemand 4.x will begin after the first production release.

### Project Layout

The root of the repository contains several top‑level folders:

| Folder | Purpose |
|--------|---------|
| `application/` | The Rails application with standard `app/`, `config/`, `lib/` etc. |
| `docker/` | Dockerfiles used to build the development images. |
| `docs/` | MkDocs documentation including this guide. |
| `scripts/` | Helper scripts invoked by the `Makefile`. |
| `config/` | Additional configuration shared across the repo. |

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
overridden via YAML or environment variables (see the Admin Guide for details).

`application/test` include all the unit tests and integration tests for the application.
The application uses standard [Rails testing](https://guides.rubyonrails.org/testing.html) with Minitest with Mocha.

The static fixtures for the tests are stored under `application/test/fixtures`

### Development Environment

Loop is designed to run entirely in Docker containers.  The provided `Makefile`
builds the images, starts the containers and executes tests.  No additional
tools need to be installed locally other than Docker, Docker Compose and `make`.
