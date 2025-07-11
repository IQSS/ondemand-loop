# Upgrading Open OnDemand

The Open OnDemand container used in development comes from the [ondemand_development](https://github.com/hmdc/ondemand_development) project.
Available tags can be browsed on [Docker Hub](https://hub.docker.com/r/hmdc/sid-ood/tags) and follow the format `ood-<version>.el8`, for example `ood-3.1.7.el8`.

The exact image tag used in the OnDemand Loop development environment is controlled by the `OOD_IMAGE` variable in the `Makefile`.
To upgrade:

1. Edit `Makefile` and change `OOD_IMAGE` to the desired tag, e.g. `hmdc/sid-ood:ood-3.1.8.el8`.
2. Run `make loop_down` to stop any running containers.
3. Start the environment again with `make loop_up` which will pull the new image.

If the image requires a different Ruby or Node version, update the builder image in the same way so the application can be rebuilt.
