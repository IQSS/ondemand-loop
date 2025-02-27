# Dataverse for OnDemand

This project is an integration of Dataverse for Open OnDemand to allow managing the file transferring from
both applications. This software is intended to be run as a Passenger app in a Open OnDemand setup.

## 🚀 Getting Started

### Prerequisites
Ensure you have the following installed:
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- `make` (usually pre-installed on Linux/macOS, Windows users may need to install it via WSL or Git Bash)

## 📦 Setup & Usage

### 1 Build the Docker Containers
```sh
make build
```
This will build the application and install dependencies inside the container.

### 2 Start the Development Server
```sh
make up
```
Starts the Rails application in development mode on [http://localhost:3000](http://localhost:3000).

### 3 Stop the Containers
```sh
make down
```
Stops and removes running containers.

### 4 Restart the Containers
```sh
make restart
```
Stops, then starts the containers again.

### 5 View Logs
```sh
make logs
```
Shows the logs for the Rails container.

### 6 Open a Bash Shell in the Rails Container
```sh
make bash
```
Opens an interactive shell session inside the Rails app container. Inside that shell you can run the Rails generators
to develop the application.

### 7 Open a Rails Console
```sh
make console
```
Runs a Rails Console inside the app container

### 8 Run RSpec Tests
```sh
make test
```
Executes RSpec tests inside the container.

## 📺 Troubleshooting

- If the app does not start properly, rebuild the containers:
  ```sh
  make build
  ```
