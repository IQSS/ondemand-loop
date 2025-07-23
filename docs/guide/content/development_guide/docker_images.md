# Docker Images

OnDemand Loop uses two specialized Docker images to streamline development and ensure consistent environments across different setups.

---

### 🐳 Open OnDemand Image

This image provides a complete Open OnDemand installation for testing your application in a realistic environment.

#### Components
- Minimal Rocky Linux 8 base system
- Full Open OnDemand installation and configuration
- Apache/NGINX/Passenger web server setup

!!! info "For supported Open OnDemand versions, see the [Open OnDemand compatibility section](./ood.md)."

---

### ⚙️ Builder Image

This image handles all build operations, testing, and development tasks without requiring you to install Ruby, Node.js, or other dependencies locally.

#### Components
- Minimal Rocky Linux 8 base system
- Ruby and Node.js (versions matching Open OnDemand requirements)
- Build tools, Rake, and development dependencies

#### Available Versions

| Image Tag | Target | Ruby | Node.js |
|-----------|--------|------|---------|
| `hmdc/ondemand-loop:builder-R3.1` | OOD v3.x | 3.1 | 18 |
| `hmdc/ondemand-loop:builder-R3.3` | OOD v4.x | 3.3 | 20 |

#### Image Organization
All OnDemand Loop Docker images are hosted under the [hmdc/ondemand-loop](https://hub.docker.com/r/hmdc/ondemand-loop/tags) repository on DockerHub.

**Tag Naming Convention:**

- **Builder images:** `builder-Rx.x` (where `x.x` = Ruby version)
    - Example: `hmdc/ondemand-loop:builder-R3.3`
- **Other images:** Specific naming based on purpose (development environments, testing images, etc.)

!!! info "🔧 The builder image definition is maintained in [`docker/Dockerfile.builder`](https://github.com/IQSS/ondemand-loop/blob/main/docker/Dockerfile.builder)."

!!! note "Creating New Builder Images"

    When Open OnDemand updates require newer Ruby or Node.js versions:
    
    1. Update the Makefile target [`loop_docker_builder`](https://github.com/IQSS/ondemand-loop/blob/main/Makefile#L28) with new version numbers
    2. Run `make loop_docker_builder` to build and tag the new image
    3. Push the image to DockerHub for team use

---

### Helper Scripts

The `scripts/` directory contains automation scripts used by the Makefile and Docker containers:

| Script                   | Purpose                  | Usage                                                                                    |
|--------------------------|--------------------------|------------------------------------------------------------------------------------------|
| `guide.sh`               | Documentation management | Builds or serves this documentation using MkDocs                                         |
| `loop_build.sh`          | Application build        | Installs dependencies, compiles Rails assets and prepares the application for deployment |
| `loop_coverage_badge.sh` | Coverage reporting       | Generates and updates test coverage badges in `docs/badges`                              |
| `loop_release_notes.sh`  | Release automation       | Creates release notes from Git commit history                                            |
| `loop_test.sh`           | Test execution           | Runs the complete test suite and generates coverage reports                              |
| `loop_version.sh`        | Version management       | Updates version numbers in preparation for new releases                                  |

!!! info "These scripts are called automatically by Makefile targets, so you typically won't need to run them directly."