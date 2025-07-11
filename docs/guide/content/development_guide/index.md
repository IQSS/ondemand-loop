# Development Guide

This section provides everything you need to understand, run, customize, and contribute to the [OnDemand Loop](https://github.com/IQSS/ondemand-loop) application.
Whether you're fixing a bug, extending functionality, or integrating with a new repository, this guide is your entry point.

### Quick Start

Clone the [repository](https://github.com/IQSS/ondemand-loop) and start the local environment using the built in `Makefile` targets:

```bash
make loop_build
make loop_up
```

Once the containers are running visit [https://localhost:33000/pun/sys/loop](https://localhost:33000/pun/sys/loop) and log in with the test user `ood/ood`.

Run `make loop_down` to stop the containers when you are finished.

The documentation is organized by topic to help you find what you need quickly:

- [Architecture and Code](architecture.md)  
  Overview of the system design, key components, and how the codebase is organized.

- [Connectors](connectors.md)  
  Details on how OnDemand Loop interacts with external repositories like Dataverse, Figshare, or Zenodo.

- [Local Environment](local_environment.md)  
  How to set up and run OnDemand Loop locally for development.

- [Docker Images](docker_images.md)  
  Information on the Docker-based setup and available images.

- [Upgrading Open OnDemand](upgrade_ood.md)  
  Guidance for updating the Open OnDemand environment.

- [Dataverse Integration](dataverse_integration.md)  
  Specifics on how integration with Dataverse is implemented.

- [Contributing a Change](contributing.md)  
  Best practices and workflow for contributing code or documentation.

- [GitHub Actions](github_actions.md)  
  How CI is handled using GitHub Actions, including testing and deployment workflows.

Each page is self-contained but builds on shared understanding of the architecture and workflows.  
If you're new to the project, we recommend starting with:

- [Architecture and Code Structure](architecture.md)
- [Local Environment](local_environment.md)
