<div style="width: 100%; background-color: black; padding: 20px 0; text-align: center;">
  <img src="application/app/assets/images/logo.png" alt="Loop Logo" style="max-width: 300px;">
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

The versions used are referenced in the [Makefile file](./Makefile)

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

> **⚠️ Self-Signed Certificate Warning**
>
> When running the app locally, you will encounter a browser warning about the connection not being secure.
> This is because the development environment uses a self-signed SSL certificate.
> You can proceed safely by accepting the exception in your browser.


## ⚙️ Available Make Commands

The following `make` commands are available to manage the application locally:

| Command                  | Description                                                       |
|--------------------------|-------------------------------------------------------------------|
| `make clean`             | 🧹 Removes temporary build artifacts, logs, and compiled files.   |
| `make loop_docker_builder` | 🐳 Builds the Docker image used for compiling/building the app.   |
| `make loop_build`        | 🏗️ Builds the app inside the Docker builder container.           |
| `make loop_up`           | 🚀 Starts the app and its dependencies in Docker containers.      |
| `make loop_down`         | ⛔ Stops and removes the Docker containers and associated networks. |
| `make bash`              | 🐚 Opens an interactive shell in the app's running Docker container. |
| `make logs`              | 📜 Tails application logs from the running app container. |
| `make test`              | 🧪 Runs the full test suite (e.g., Minitest).                     |
| `make test_bash`         | 🔬 Opens a shell in the test container for manual testing/debugging. |





