# Local Environment

The repository includes a Docker-based setup that mirrors a typical Open OnDemand installation.  
This setup allows you to build, run, and test the application locally **without installing Ruby, Node.js, or any other runtime dependencies** on your host machine.

The project [`Makefile`](https://github.com/IQSS/ondemand-loop/blob/main/Makefile) provides convenient commands to manage the full lifecycle: building images, starting containers, running tests, and cleaning up.

---

### Prerequisites

Make sure the following tools are installed on your system:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [GNU Make](https://www.gnu.org/software/make/manual/make.html)

---

### How It Works

The [`docker-compose.yml`](https://github.com/IQSS/ondemand-loop/blob/main/docker-compose.yml) file defines a local development environment where the OnDemand Loop application is mounted directly into a running Open OnDemand container.  
This simulates how the application is deployed in production, allowing you to iterate on code and configuration in real time.

Environment-specific configuration can be overridden by editing the [`.env`](https://github.com/IQSS/ondemand-loop/blob/main/config/.env).
This configuration file is mounted into the deployed application root folder.
For a list of supported configuration properties, refer to the [Admin Guide](../admin.md).

---

!!! note "Application Data"

    For convenience, the `./data/` folder at the root of the project is mounted into the containers and used for all runtime state.

    - **`./data/metadata/`** – stores OnDemand Loop projects, download and upload metadata
    - **`./data/downloads/`** – stores downloaded files, organized by project
    - **`./data/ood/`** – used as the Open OnDemand `data` directory for session state

    You can safely delete this folder to reset the application state, but be aware that all metadata and downloaded files will be lost.

### Running the App
Build the application in development mode and start the containers:

```bash
make loop_build
make loop_up
```

The `make loop_up` command starts the development environment using Docker Compose.
It runs in the foreground, streaming logs from all containers to your terminal.
The shell prompt will not return until you stop the environment manually.

To stop the environment, press <kbd>Ctrl</kbd>+<kbd>C</kbd>. This will gracefully shut down all containers.
Alternatively, in another terminal you can run: `make loop_down`

Once the containers are running visit [https://localhost:33000/pun/sys/loop](https://localhost:33000/pun/sys/loop) and log in with the test user `ood/ood`.

!!! warning "Self-Signed Certificate Warning"
 
    When running the app locally, you will encounter a browser warning about the connection not being secure.  
    This is because the development environment uses a self-signed SSL certificate.  
    You can proceed safely by accepting the exception in your browser.

Refer to [Upgrading Open OnDemand (Development)](ood.md#upgrading-open-ondemand-development) to configure and run the app with a specific Open OnDemand version.

You may also override `OOD_IMAGE` to use another container that already has Open OnDemand installed.

### Make Commands:

| Command                   | Purpose                                                              |
|---------------------------|----------------------------------------------------------------------|
| `make loop_docker_builder`| Build the Docker image used for compiling the app                    |
| `make loop_build`         | Install dependencies and build the application under `application/`  |
| `make loop_up`            | Start the local environment                                          |
| `make loop_down`          | Stop and remove the containers                                       |
| `make clean`              | Remove build artifacts and log files                                 |
| `make logs`               | Tail the application logs                                            |
| `make bash`               | Open a shell inside the running container                            |
| `make test`               | Run the test suite                                                   |
| `make test_bash`          | Open a shell in the test container                                   |
| `make remote_dev_build`   | Build the app for a remote development environment                   |
| `make release_build`      | Build the app for production release                                 |
| `make version`            | Bump the version file using `scripts/loop_version.sh`                |
| `make release_notes`      | Generate release notes from Git history                              |
| `make coverage`           | Update the coverage badges in `docs/badges`                          |
| `make guide`              | Build the user guide with MkDocs                                     |
| `make guide_dev`          | Serve this documentation at `http://localhost:8000`                  |
