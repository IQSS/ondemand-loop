<div style="width: 100%; background-color: black; padding: 20px 0; text-align: center;">
  <img src="docs/guide/content/assets/banner.png" alt="OnDemand Loop Logo" style="max-width: 300px;">
</div>

![Line coverage](docs/badges/coverage-line.svg)
![Branch coverage](docs/badges/coverage-branch.svg)

# OnDemand Loop

Application to transfer data from heterogeneous research data repositories into Open OnDemand. With the possibility of syncing the data back.

Creating the perfect loop for research data

The first remote repository integration is Dataverse.
Dataverse will be used as the reference implementation for all features related to this application.

OnDemand Loop has been designed from the ground up to be a companion to the Open OnDemand application.
It is deployed into the Open OnDemand environment as another passenger app.
It has been configured to be deployed under the folder: /var/www/ood/apps/sys/loop

The OnDemand environment will launch the application in the same way as the Dashboard app.
The URL will be https://<ood-server>/pun/sys/loop

### License

This project is licensed under the [MIT License](LICENSE).

## 🚀 Deployment
The application has been designed to be installed as a OnDemand passenger app.

### System Requirements
- `Ruby`
- `NodeJS`

The application has been built to work with the same Ruby and NodeJS requirements as Open OnDemand.

### Installation
Select a version to deploy, we recommend to install the [latest version ](https://github.com/IQSS/ondemand-loop/releases/latest)
To install the application as a system application, checkout the release into the OnDemand server sys folder and build the application:

```bash
cd /var/www/ood/apps/sys
git clone --branch v1.0.0#2025-06-06 --depth 1 https://github.com/IQSS/ondemand-loop.git loop
cd loop
./loop_build.sh
```

The build process simply install the dependencies into the `vendor/bundle` application folder and compile the CSS and Javascript files.

Now launch the application: `https://<your-server>/pun/sys/loop`

## 🛠️ Development
To try the application locally or to update or create new features,
we have created a Docker based local environment to build and run the application.

The required Docker images to build and run has been created and uploaded into the official DockerHub:
 - [App Builder Images](https://hub.docker.com/r/hmdc/ondemand-loop/tags)
 - [OnDemand Environment Images](https://hub.docker.com/r/hmdc/sid-ood/tags)

The versions used are referenced in the [Makefile file](./tools/make/ood_versions.mk)

### Prerequisites
Ensure you have the following installed:
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- `make` (usually pre-installed on Linux/macOS, Windows users may need to install it via WSL or Git Bash)

### Local Environment
The local environment uses Docker compose to start the following containers:
 - Open OnDemand v3.1.7
 - SMTP server

Docker compose will mount the local `application` directory into the OOD `/var/www/ood/apps/sys/loop` folder.

To run the application locally, build the application and start Docker compose.
These commands have been abstracted into Make targets:
  ```sh
  make loop_build
  make loop_up
  ```

The local environment has configured a test user with the following credentials:
 - username: ood
 - password: ood

Launch the application: [https://localhost:33000/pun/sys/loop](https://localhost:33000/pun/sys/loop)  
Launch OOD: [https://localhost:33000/pun/sys/dashboard](https://localhost:33000/pun/sys/dashboard)

Supported Open OnDemand versions:
 - v3.1.7
 - v3.1.14
 - v4.0.0
 - v4.0.6

  ```sh
  # How to build and run for OODv3.1.14
  make clean
  make loop_build OOD_VERSION=3.1.14
  make loop_up OOD_VERSION=3.1.14
  ```

> **⚠️ Self-Signed Certificate Warning**
>
> When running the app locally, you will encounter a browser warning about the connection not being secure.
> This is because the development environment uses a self-signed SSL certificate.
> You can proceed safely by accepting the exception in your browser.


## ⚙️ Available Make Commands

The following `make` commands are available to manage the application locally:

| Command                  | Description                                                    |
|--------------------------|----------------------------------------------------------------|
| `make loop_docker_builder` | 🐳 Build the Docker image used for compiling the app.          |
| `make loop_build`          | 🏗️ Install dependencies and build the application.            |
| `make loop_up`             | 🚀 Start the app and its dependencies in Docker containers.    |
| `make loop_down`           | ⛔ Stop and remove the Docker containers and networks.          |
| `make clean`               | 🧹 Remove build artifacts and logs.                            |
| `make logs`                | 📜 Tail the application logs.                                  |
| `make bash`                | 🐚 Open a shell inside the running container.                  |
| `make test`                | 🧪 Run the full test suite.                                    |
| `make test_bash`           | 🔬 Open a shell in the test container.                         |
| `make remote_dev_build`    | 🛠️ Build the app for a remote development environment.        |
| `make release_build`       | 📦 Build the app for production release.                       |
| `make version`             | 🔖 Bump the version file for releases.                         |
| `make release_notes`       | 📝 Generate release notes from Git history.                    |
| `make coverage`            | 📊 Update the coverage badges.                                 |
| `make guide`               | 📚 Build this documentation with MkDocs.                       |
| `make guide_dev`           | 📚 Serve the documentation locally at `http://localhost:8000`. |





