# Installation Guide

This guide explains how to build and deploy **OnDemand Loop** for **production use** alongside an existing [Open OnDemand](https://openondemand.org) installation.
OnDemand Loop is developed and tested as an integrated **Passenger application** within [OnDemand's application framework](https://osc.github.io/ood-documentation/latest/tutorials/tutorials-passenger-apps.html). For production deployment, it should be installed under the system application directory, typically: `/var/www/ood/apps/sys/loop`

!!! note "Development Notes"

    This guide covers production installation only. If you're setting up OnDemand Loop for development purposes or as an Open OnDemand development application, please refer to the [Development Guide](development_guide/index.md) instead.


### System Requirements

The software versions you need depend on which version of Open OnDemand you're running.
OnDemand Loop is designed and tested to work with the Ruby and Node.js versions bundled with your Open OnDemand installation.  
Here's what you need based on your OOD version:

**For Open OnDemand 3.x:**

- Ruby 3.1
- Node.js 18

**For Open OnDemand 4.x:**

- Ruby 3.3  
- Node.js 20

#### Required Software

- **Open OnDemand** 3.1 or newer
- **Ruby** 3.1 or 3.3 (matching your OOD version)
- **Bundler** (usually comes pre-installed with Ruby)
- **Node.js** 18 or 20 (matching your OOD version)

#### Finding the Right Versions

If you're unsure which versions to use, check the bundled software that came with your Open OnDemand installation.
OnDemand Loop includes a version mapping matrix used for the local environment [ood_versions.mk](https://github.com/IQSS/ondemand-loop/blob/main/tools/make/ood_versions.mk)
that shows exactly which Ruby and Node.js versions correspond to each OOD release.

### Building the Application

<a id="ondemand-loop-repo-info"></a>
!!! info ":fontawesome-brands-github: OnDemand Loop Repo"

     - [https://github.com/IQSS/ondemand-loop](https://github.com/IQSS/ondemand-loop)
     - [https://github.com/IQSS/ondemand-loop/releases](https://github.com/IQSS/ondemand-loop/releases)

The repository includes a Makefile with helper targets and utility scripts to facilitate the building process.
The preferred way to build OnDemand Loop is to install all Ruby gems and Node packages into local folders, avoiding conflicts with system-wide installs. 
This is exactly how the [scripts/loop_build.sh](https://github.com/IQSS/ondemand-loop/blob/main/scripts/loop_build.sh) script operates and how the application has been tested.
See that script for the exact commands executed during the build.

To run the build inside the default Docker builder image targeting an OnDemand v3.1.7 installation, execute:

```bash
make release_build
```

The script stores Ruby gems under `vendor/bundle` and Node packages in
`node_modules` within the `application` directory with the rest of the OnDemand Loop code
so that the build is isolated from system packages.

This command installs all Ruby and Node dependencies and precompiles the CSS and
JavaScript assets. If you run the build manually make sure to execute the
`scripts/loop_build.sh` script **from inside the `application` directory** so
that `bundle` and `npm` find the `Gemfile` and `package.json` files.

#### Building for Other Open OnDemand Versions
To support compatibility and testing across multiple Open OnDemand releases, OnDemand Loop provides Docker images tailored to a predefined set of OOD versions.
You can easily build the project against a specific version using the `OOD_VERSION` variable.

The list of supported OOD versions is documented in the [Open OnDemand](development_guide/ood.md) section of the [Development Guide](development_guide/index.md).

To build the project for a specific version, run:

```bash
make clean
make release_build OOD_VERSION=3.1.14
```

This will generate a release-compatible build of the application using the environment that matches the specified OOD version.

!!! warning "Alternative Build Options"

    If you're targeting an OOD version not explicitly supported by the build system, there are two options:

    **Use our build scripts,** but ensure that the Ruby and Node.js versions match the ones used by your target Open OnDemand version.
    This is required to maintain compatibility with system-installed gems and compiled assets.

    **Recommended:** Build the application directly on your OOD server using the Ruby and Node.js environments already provided by Open OnDemand.
    This ensures the resulting assets and dependencies are aligned with your server environment.

### Deployment Options

#### 1. Build on the Server

Clone the repository (or a release tag) directly into the OOD server, run the build script,
and copy the built application into the OnDemand application `sys` folder.
For links to the repository and releases, [jump to repo info](#ondemand-loop-repo-info).

```bash
cd /tmp
git clone --branch <tag-or-branch> https://github.com/IQSS/ondemand-loop.git loop
cd loop/application
../scripts/loop_build.sh
mkdir /var/www/ood/apps/sys/loop
cp -R ./* /var/www/ood/apps/sys/loop/
```

#### 2. Build Elsewhere and Copy

If you prefer to compile the application in a controlled environment, run the
build steps on another machine and then copy `ondemand-loop/application` directory to
`/var/www/ood/apps/sys` on your production server. Then rename it to `loop`, ie: `/var/www/ood/apps/sys/loop`.
Ensure file permissions are preserved during the transfer.

#### 3. Deploy with Puppet

Sites already managing Open OnDemand with the official Puppet module can deploy
Loop in a similar fashion to the Dashboard app. Build the application using the
steps above, then copy the resulting `loop` directory into a dedicated branch of
your deployment repository. The Puppet configuration can then reference that
branch when installing the app:

```yaml
openondemand::install_apps:
  'loop':
    ensure: latest
    git_repo: https://github.com/sample/deploy-ondemand-loop.git
    git_revision: production_v1.0.0-2025-07-09
```

This approach keeps the build artifacts under version control while allowing the
Puppet module to deploy the precompiled application.

### Dataverse Integration

Dataverse supports **External Tools**, which enable integrations with external
web applications. By registering OnDemand Loop as an External Tool with
`dataset` scope, users can launch Loop directly from a dataset page to initiate
transfers into the HPC cluster.

With Dataverse running at `http://localhost:8080` and the Loop app accessible at
`https://localhost:33000`, register the tool using:

```bash
curl --location 'http://localhost:8080/api/admin/externalTools' \
--header 'Content-Type: application/json' \
--data '{
  "displayName": "Explore in OOD",
  "description": "An external tool to Explore and Download dataset files in OOD",
  "toolName": "ondemand_loop_dataset_tool",
  "scope": "dataset",
  "types": ["explore"],
  "toolUrl": "https://localhost:33000/pun/sys/loop/integrations/dataverse/external_tool/dataset",
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

For production deployments, adjust the Dataverse URL and the `toolUrl` to match
your server names.

### Verify the Installation

1. Visit the OOD files application and browse the application files:  
    `https://<your-server>/pun/sys/dashboard/files/fs/var/www/ood/apps/sys/loop`
1. Verify the deployed version if the expected `VERSION`
1. Verify the Ruby gems are deployed under `vendor/bundle`
1. Check the NodeJS modules are deployed `node_modules`
1. Launch the OnDemand Loop application by visiting the URL: `https://<your-server>/pun/sys/loop` in a browser. The application should load after clicking **Initialize** once.
1. The OnDemand Loop homepage should display with a welcome message.
