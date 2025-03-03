# Dataverse for OnDemand

This project is an integration of Dataverse for Open OnDemand to allow managing the file transferring from
both applications. This software is intended to be run as a Passenger app in a Open OnDemand setup.

## 🚀 Getting Started

### Prerequisites
Ensure you have the following installed:
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- `make` (usually pre-installed on Linux/macOS, Windows users may need to install it via WSL or Git Bash)


## 📦 Available commands

The following `make` commands are available to manage the application:

### Start and Stop Containers
- **Start the container in the background:**
  ```sh
  make up
  ```
- **Stop the container:**
  ```sh
  make down
  ```
- **Restart the container:**
  ```sh
  make restart
  ```

### Build and Install Dependencies
- **Build or rebuild the container:**
  ```sh
  make build
  ```
- **Install dependencies with `bundle install`:**
  ```sh
  make install
  ```

### Running the Application
- **Start the Rails server:**
  ```sh
  make server
  ```
  The server will be accessible at `http://localhost:3000`.
- **Start the Rails server in production mode:**
  ```sh
  make prod_server
  ```

### Debugging and Logs
- **View development logs for the Rails application:**
  ```sh
  make logs
  ```
- **Open a Bash shell inside the Rails app container:**
  ```sh
  make bash
  ```
- **Open a Rails console inside the app container:**
  ```sh
  make console
  ```

### Running Tests
- **Run tests using RSpec:**
  ```sh
  make tests
  ```
  
## Start developing and running the application

To start developing or running the developer server, run the following commands:

```sh
make build
```
To build the developer container image

```sh
make install
```
To install all gem dependencies with Bundle

```sh
make server
```
To run the developer Rails server and see the application in `localhost:3000`
