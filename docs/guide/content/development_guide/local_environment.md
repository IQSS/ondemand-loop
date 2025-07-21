# Local Environment

The repository contains a Docker based setup that mirrors an Open OnDemand installation.
A `Makefile` exposes handy commands so you don't need to install Ruby, Node or any other dependencies on your workstation.

### Prerequisites
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- `make`

### Running the App

Build the application and start the containers:

```bash
make loop_build
make loop_up
```

Open the app at [https://localhost:33000/pun/sys/loop](https://localhost:33000/pun/sys/loop).

A test user `ood/ood` is configured. The environment uses a self‑signed certificate so your browser will warn about the connection.

!!! warning "Self-Signed Certificate Warning"
 
    When running the app locally, you will encounter a browser warning about the connection not being secure.  
    This is because the development environment uses a self-signed SSL certificate.  
    You can proceed safely by accepting the exception in your browser.
    

Stop the containers with:

```bash
make loop_down
```

Refer to [Upgrading Open OnDemand (Development)](ood.md#upgrading-open-ondemand-development) to configure and run the app with a specific Open OnDemand version.

### Make Commands:

| Command           | Purpose                                                                              |
|-------------------|--------------------------------------------------------------------------------------|
| `make loop_build` | Install the dependencies into `application/vendor/bundle` and builds the application |
| `make loop_up`    | Starts the local environment                                                         |
| `make loop_down`  | Shuts down the local environment                                                     |
| `make logs`       | Tail the application logs                                                            |
| `make bash`       | Open a shell inside the running container                                            |
| `make test`       | Run the test suite                                                                   |
| `make guide_dev`  | Serve this documentation at `http://localhost:8000`                                  |
