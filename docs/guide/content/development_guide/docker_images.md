# Docker Images

Two main images are used during development:

- **Builder Image** – `hmdc/ondemand-loop:builder-R3.1`. This image contains Ruby, Node and build tools. It runs the unit tests and other commands invoked by the `make` targets. The Dockerfile lives at `docker/Dockerfile.builder` and you can rebuild it with `make loop_docker_builder`. This project maintains the builder image and updates it whenever the Open OnDemand stack requires newer Ruby or Node versions.
- **Open OnDemand Image** – `hmdc/sid-ood:ood-3.1.7.el8` by default. Docker compose launches this image and mounts the application under `/var/www/ood/apps/sys/loop`. The image itself is managed in the [ondemand_development](https://github.com/hmdc/ondemand_development) project which provides a minimal Rocky8 environment with Puppet to install Open OnDemand. Requests to upgrade OOD should be made in that project. You may also override `OOD_IMAGE` to use another container that already has Open OnDemand installed as long as the Loop application is mounted to `/var/www/ood/apps/sys/loop`.

Versions for these images are defined in the `Makefile`. If you need to rebuild the builder image locally run `make loop_docker_builder`.

### Helper Scripts

The `scripts/` folder contains small helper scripts used by the Makefile and Docker images:

| Script | Purpose |
|--------|---------|
| `loop_build.sh` | Precompiles Rails assets inside the builder image. |
| `loop_test.sh` | Runs the full test suite and generates coverage data. |
| `loop_release_notes.sh` | Creates release notes from Git history. |
| `loop_version.sh` | Bumps the version file for releases. |
| `loop_coverage_badge.sh` | Updates the coverage badges in `docs/badges`. |
| `guide.sh` | Builds or serves this documentation via MkDocs. |