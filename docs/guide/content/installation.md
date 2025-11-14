# Installation Guide

This guide explains how to build and deploy **OnDemand Loop** for **production use** alongside an existing [Open OnDemand](https://openondemand.org) installation.
OnDemand Loop is developed and tested as an integrated **Passenger application** within [OnDemand's application framework](https://osc.github.io/ood-documentation/latest/tutorials/tutorials-passenger-apps.html). For production deployment, it should be installed under the system application directory, typically: `/var/www/ood/apps/sys/loop`

!!! note "Development Notes"

    This guide covers production installation only. If you're setting up OnDemand Loop for development purposes or as an Open OnDemand development application, please refer to the [Development Guide](development_guide/index.md) instead.

## Overview

Installing OnDemand Loop involves two main steps:

1. **Building** - Install the Ruby gems and Node.js packages, execute the assets pipeline, and compile the CSS and JavaScript
2. **Deploying** - Copy the built application to the Open OnDemand system application directory

## System Requirements

These requirements apply to the environment where you build/deploy the application—whether that's the Open OnDemand server itself, a dedicated build machine (physical or virtual), or a Docker container.

### Required Software

- **Open OnDemand** 3.1 or newer (only for deployment)
- **Ruby** 3.1 or 3.3 (matching your OOD version)
- **Bundler** (usually comes pre-installed with Ruby)
- **Node.js** 18 or 20 (matching your OOD version)

!!! tip "Version Requirements by OOD Release"
    The software versions you need depend on which version of Open OnDemand you're running.
    OnDemand Loop is designed and tested to work with the Ruby and Node.js versions bundled with your Open OnDemand installation.

    **Open OnDemand 3.x:** Ruby 3.1, Node.js 18  
    **Open OnDemand 4.x:** Ruby 3.3, Node.js 20

    If you're unsure which versions to use, check the bundled software that came with your Open OnDemand installation, or refer to the version mapping matrix in [ood_versions.mk](https://github.com/IQSS/ondemand-loop/blob/main/tools/make/ood_versions.mk).

<a id="ondemand-loop-repo-info"></a>
!!! info ":fontawesome-brands-github: OnDemand Loop Repo"

     - [https://github.com/IQSS/ondemand-loop](https://github.com/IQSS/ondemand-loop)
     - [https://github.com/IQSS/ondemand-loop/releases](https://github.com/IQSS/ondemand-loop/releases)

---

### Building the Application

The build process installs all required Ruby gems and Node.js packages into local directories within the application, ensuring no dependency conflicts with system-wide installations.

- **Ruby gems** are installed under `vendor/bundle`.  
- **Node packages** are installed under `node_modules`.  
- The build process also **precompiles CSS and JavaScript assets** for production use.

You can build the application using one of the following approaches:

#### Using the OnDemand Loop Docker builder image
This is a Rocky Linux 8–based container image provided by the project.
It includes the exact Ruby, Node.js, and system dependencies required to build the app, ensuring reproducible and consistent builds across environments.

This method is recommended for CI pipelines and reproducible local builds, though it may not fit all production workflows.

#### Using the local filesystem
This approach runs the build directly on your host system.
It requires all the dependencies to be installed locally, and allows you to integrate with existing system-level configurations or development tools.

This method is suitable when building on the OOD server itself (which already has the required dependencies) or when you prefer to build on your own controlled environment.

### Building with OnDemand Loop Docker builder image

This method uses pre-configured Docker images that contain the exact Ruby and Node.js versions for specific Open OnDemand releases.
This is the recommended approach as it ensures build consistency and doesn't require installing dependencies on your build machine.

The repository includes a Makefile with helper targets that use the [scripts/loop_build.sh](https://github.com/IQSS/ondemand-loop/blob/main/scripts/loop_build.sh) script.
See that script for the exact commands executed during the build.

#### Building with the Default Configuration for OODv3.1.x

```bash
cd /tmp
git clone --branch <tag-or-branch> https://github.com/IQSS/ondemand-loop.git loop
cd loop

# Build using Docker builder image with the default configuration for OOD 3.1.x
make release_build
```

#### Building for Other OOD Versions

To support compatibility across multiple Open OnDemand releases, OnDemand Loop provides Docker images tailored to specific OOD versions.
You can build for a specific version using the `OOD_VERSION` variable.

```bash
cd /tmp
git clone --branch <tag-or-branch> https://github.com/IQSS/ondemand-loop.git loop
cd loop

# Build for a specific OOD version
make release_build OOD_VERSION=4.0.0
```

After building, the compiled application will be in the `application/` directory, ready for deployment.

!!! info "Available OOD_VERSION Values"
    For a complete list of supported `OOD_VERSION` values with pre-configured Docker builder images, see [ood_versions.mk](https://github.com/IQSS/ondemand-loop/blob/main/tools/make/ood_versions.mk) in the repository. This file contains all Open OnDemand versions we have tested and provide builder configurations for.

### Building on the Local Filesystem

This method builds the application using the required dependencies installed on your own servers.
Use this approach when:

- You need to build for an OOD version or environment not supported by the Docker images
- You're building directly on the OOD server (which already has the correct dependencies)
- You have a dedicated build machine configured with the appropriate dependencies

#### Building on the OOD Server

Building directly on the OOD server ensures the build environment matches the runtime environment exactly, as the server already has the required dependencies installed by Open OnDemand.

```bash
cd /tmp
git clone --branch <tag-or-branch> https://github.com/IQSS/ondemand-loop.git loop
cd loop

# Build using local Ruby and Node.js
make native_build
```

#### Building on your Own Build Server

If you have configured a build machine with the required dependencies:

```bash
cd /tmp
git clone --branch <tag-or-branch> https://github.com/IQSS/ondemand-loop.git loop
cd loop

# Verify Ruby and Node.js versions match your target OOD version
ruby --version
node --version

# Build using local dependencies
make native_build
```

After building, the compiled application will be in the `application/` directory, ready for deployment.

---

## Deploying the Application

Once you've built the application, you need to deploy it to the Open OnDemand system application directory.
The deployment method you choose depends on where you built the application and how your infrastructure is managed.

All deployment methods copy the fully self-contained `application/` directory (including `vendor/bundle`, `node_modules`, and `.bundle/config`) to `/var/www/ood/apps/sys/loop` on the OOD server.

### Local Deployment with rsync

Use this method when you built the application **on the OOD server itself**.

```bash
# After building on the OOD server
cd /tmp/loop

# Deploy using rsync (preserves dotfiles like .bundle/config)
sudo mkdir -p /var/www/ood/apps/sys/loop
sudo rsync -a --delete ./application/ /var/www/ood/apps/sys/loop/

# Set ownership and permissions
sudo chown -R root:root /var/www/ood/apps/sys/loop
sudo chmod -R a+rX /var/www/ood/apps/sys/loop

# Verify deployment
test -f /var/www/ood/apps/sys/loop/.bundle/config || { echo 'Missing .bundle/config'; exit 1; }
test -d /var/www/ood/apps/sys/loop/vendor/bundle || { echo 'Missing vendor/bundle'; exit 1; }
```

### Remote Deployment with rsync

Use this method when you built the application **on a different machine** (build machine, CI/CD server, etc.) and need to transfer it to the OOD server.

```bash
# After building on the build machine
cd /tmp/loop

# Copy to OOD server (preserves dotfiles and metadata)
rsync -a --delete ./application/ user@your-ood-server:/var/www/ood/apps/sys/loop/
```

**On the OOD server**, run the post-deployment steps:

```bash
# Set ownership and permissions
sudo chown -R root:root /var/www/ood/apps/sys/loop
sudo chmod -R a+rX /var/www/ood/apps/sys/loop

# Verify deployment
test -f /var/www/ood/apps/sys/loop/.bundle/config || { echo 'Missing .bundle/config'; exit 1; }
test -d /var/www/ood/apps/sys/loop/vendor/bundle || { echo 'Missing vendor/bundle'; exit 1; }
```

### Deployment with Puppet and the OnDemand Puppet Module

For sites already using the [Open OnDemand Puppet module](https://github.com/OSC/ondemand-puppet-module), deploying Loop through Puppet provides automated, version-controlled deployment that integrates with your existing infrastructure management workflows.

This method requires pushing the built application to a Git repository that Puppet can access.

#### Create Deployment Repository

Push the built application to a dedicated deployment repository:

```bash
# Navigate to the built application directory
cd application

# Initialize a new Git repository for the built artifacts
git init

# Add all files, including dotfiles (.bundle/config, etc.)
git add .

git commit -m "Built version for deployment"

# Add your deployment repository as remote
git remote add origin https://github.com/your-org/deploy-ondemand-loop.git

# Create and push a deployment branch
BRANCH=production_v1.0.0-2025-07-09
git checkout -b "$BRANCH"
git push -u origin "$BRANCH"

# Verify the deployment repository files:
# - .bundle/config
# - vendor/bundle
# - node_modules
```

#### Configure Puppet

Configure Puppet to deploy from your deployment repository:

```yaml
# Hiera (e.g., /etc/puppetlabs/code/environments/production/data/common.yaml)
openondemand::install_apps:
  'loop':
    ensure: latest
    git_repo: https://github.com/your-org/deploy-ondemand-loop.git
    git_revision: production_v1.0.0-2025-07-09
```

!!! tip "Puppet Deployment Tips"
    - Use `ensure: latest` if you want Puppet to update on each run; use `present` to pin a specific version.
    - Keep your deployment repository dedicated to **built artifacts only**—no source files—so Puppet fetches only what it needs.
    - Puppet will automatically handle file permissions and ownership.

---

## Post-Installation

### Verify the Installation

After deploying the application, verify that it's working correctly:

1. **Browse the application files** using the OOD Files app:
    ```
    https://<your-server>/pun/sys/dashboard/files/fs/var/www/ood/apps/sys/loop
    ```

2. **Verify the deployed version** matches the expected `VERSION` file

3. **Check that Ruby gems are present** under `vendor/bundle`

4. **Check that Node.js modules are present** under `node_modules`

5. **Launch OnDemand Loop** by visiting:
    ```
    https://<your-server>/pun/sys/loop
    ```
    The application should load after clicking **Initialize** once.

6. **Confirm the homepage displays** with a welcome message

### Configuring Navigation Menu Appearance

Consult the [Customizations guide](admin/customizations.md) for details on:

- Adjusting the Open OnDemand manifest
- Customizing the in-application navigation bar
- Default values and customization examples
- Best practices for tailoring menus to your deployment

### Dataverse Integration

Dataverse supports **External Tools**, which enable integrations with external web applications.
By registering OnDemand Loop as an External Tool with `dataset` scope, users can launch Loop directly from a dataset page to initiate transfers into the HPC cluster.

To register OnDemand Loop as a Dataverse External Tool:

```bash
curl --location 'http://localhost:8080/api/admin/externalTools' \
--header 'Content-Type: application/json' \
--data '{
  "displayName": "Explore in OOD",
  "description": "An external tool to Explore and Download dataset files in OOD",
  "toolName": "ondemand_loop_dataset_tool",
  "scope": "dataset",
  "types": ["explore"],
  "toolUrl": "https://localhost:33000/pun/sys/loop/connect/dataverse/external_tool_dataset",
  "httpMethod": "GET",
  "toolParameters": {
    "queryParameters": [
      {"dataverse_url": "{siteUrl}"},
      {"dataset_id": "{datasetPid}"},
      {"version": "{datasetVersion}"},
      {"locale": "{localeCode}"}
    ]
  }
}'
```

!!! note "Production Configuration"
    The example above uses local development URLs. For production deployments, replace:

    - `http://localhost:8080` with your Dataverse server URL
    - `https://localhost:33000/pun/sys/loop` with your Open OnDemand Loop URL
