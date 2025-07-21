# Admin Guide

This guide describes how to configure the OnDemand Loop application using environment variables and YAML configuration files. The application's configuration is managed through the `ConfigurationSingleton` class, which provides a centralized interface for accessing all configurable properties.

Each property is defined with sensible defaults and can be overridden in one of two ways:

1. **Environment Variables** — Loaded from `.env` files or system-level environment variables.
2. **YAML Files** — Located in `/etc/loop/config/loop.d` by default.

The configuration system uses the `ConfigurationProperty` abstraction to define properties with specific types (e.g., `path`, `integer`, `boolean`). These properties are then exposed as methods on the global `Configuration` object, allowing the rest of the application to access them consistently.

This guide documents each configuration property, including its purpose, default value, and expected type. It is intended for system administrators deploying or managing OnDemand Loop.


### Setting Configuration Values

You can override the default configuration values in **two supported ways**:

#### 1. YAML Configuration Files (`/etc/loop/config/loop.d`)

Create one or more `.yml` files in the directory: `/etc/loop/config/loop.d`

Each file should contain a simple key-value structure where the keys match the configuration property names (e.g. `download_root`, `zenodo_enabled`). These files are loaded **once at application startup**, so any changes require a restart.

#### 2. Environment Variables

You can define environment variables in one of the following ways:

- Set them in the system environment (e.g. using your init system or shell profile)
- Create a `.env` file in the application root
- Create a `.env.<RAILS_ENV>` file for environment-specific values  
  _(e.g., `.env.production`, `.env.development`)_

!!! note "Environment Precedence"

    If both `.env` and `.env.<RAILS_ENV>` (e.g. `.env.production`) are present, the environment-specific file takes precedence.

    These files will also override any variables already defined in the system environment or by the init system.  
    This allows `.env.<RAILS_ENV>` to serve as the authoritative source for configuration in each environment.

---

!!! note "Property Values"

    **File Paths**  
    The system supports dynamic path expansion for user directories. You can reference the current user's home directory using either syntax:

     - `~/data/info` (tilde expansion)
     - `$HOME/data/info` (environment variable)

    Both will automatically resolve to the user's actual home directory path (e.g., `/home/username/data/info`).

    **Numeric Values**  
    For improved readability of large numbers, the system supports Ruby-style numeric formatting with underscores as thousand separators:

     - `65_000` (equivalent to 65000)
     - `86_400` (equivalent to 86400, useful for seconds in a day)

    The underscores are ignored during processing and serve only to make configuration values easier to read and understand.

### List of config properties
- [version](#version)
- [ood_version](#ood_version)
- [metadata_root](#metadata_root)
- [download_root](#download_root)
- [ruby_binary](#ruby_binary)
- [files_app_path](#files_app_path)
- [ood_dashboard_path](#ood_dashboard_path)
- [connector_status_poll_interval](#connector_status_poll_interval)
- [locale](#locale)
- [download_files_retention_period](#download_files_retention_period)
- [upload_files_retention_period](#upload_files_retention_period)
- [ui_feedback_delay](#ui_feedback_delay)
- [detached_controller_interval](#detached_controller_interval)
- [detached_process_status_interval](#detached_process_status_interval)
- [max_download_file_size](#max_download_file_size)
- [max_upload_file_size](#max_upload_file_size)
- [zenodo_enabled](#zenodo_enabled)
- [guide_url](#guide_url)

<a id="version"></a>
**`version`**  
Specifies the path to a file containing the OnDemand Loop version string. This string is displayed in the UI, typically in the footer, to help identify the deployed version.

- **Default**: `/var/www/ood/apps/sys/loop/VERSION`
- **Environment Variable**: _None_

---

<a id="ood_version"></a>
**`ood_version`**  
Specifies the path to the file that contains the installed Open OnDemand version. This version string is used to determine runtime compatibility and for display in the interface.

- **Default**: `/opt/ood/VERSION`
- **Environment Variable**: `OOD_VERSION` or `ONDEMAND_VERSION`

---

<a id="metadata_root"></a>
**`metadata_root`**  
Specifies the directory where OnDemand Loop stores internal metadata, such as project definitions and repository information. This directory must be writable and consistent across sessions.

- **Default**: `~/.loop_metadata`
- **Environment Variable**: `OOD_LOOP_METADATA_ROOT`

---

<a id="download_root"></a>
**`download_root`**  
Defines the destination directory where project-organized files from remote repositories (e.g., Zenodo, Figshare) are downloaded.  
These files are accessible through the Files app integration.

- **Default**: `~/loop_downloads`
- **Environment Variable**: `OOD_LOOP_DOWNLOAD_ROOT`

---

<a id="ruby_binary"></a>
**`ruby_binary`**  
Specifies the path to the Ruby interpreter used to launch detached or background scripts.
By default, this is set to the same Ruby executable used to run the application itself.
The value is determined dynamically at runtime using: `File.join(RbConfig::CONFIG['bindir'], 'ruby')`

- **Default**: `/usr/bin/ruby`
- **Environment Variable**: `OOD_LOOP_RUBY_BINARY`

---

<a id="files_app_path"></a>
**`files_app_path`**  
Specifies the URL path to the Open OnDemand Files app. OnDemand Loop uses this path to create direct links to downloaded data so users can easily browse the filesystem.

- **Default**: `/pun/sys/dashboard/files/fs`
- **Environment Variable**: `OOD_LOOP_FILES_APP_PATH`

---

<a id="ood_dashboard_path"></a>
**`ood_dashboard_path`**  
Defines the base URL path to the main Open OnDemand dashboard. Used for navigation links back to the user's main portal interface.

- **Default**: `/pun/sys/dashboard`
- **Environment Variable**: `OOD_LOOP_OOD_DASHBOARD_PATH`

---

<a id="connector_status_poll_interval"></a>
**`connector_status_poll_interval`**  
Sets the polling interval (in milliseconds) for the frontend to check the status of repository connectors. Lower values increase responsiveness but may increase load.

- **Default**: `5_000`
- **Environment Variable**: `OOD_LOOP_CONNECTOR_STATUS_POLL_INTERVAL`

---

<a id="locale"></a>
**`locale`**  
Defines the default language/locale used by the application interface. This setting determines the translation context for UI text.  
Currently only English is supported.

- **Default**: `:en` (English)
- **Environment Variable**: `OOD_LOOP_LOCALE`

---

<a id="download_files_retention_period"></a>
**`download_files_retention_period`**  
Specifies the maximum age (in seconds) of download metadata files that should remain visible in the UI. Older records will be ignored or cleaned up.

- **Default**: `86_400` (1 day)
- **Environment Variable**: `OOD_LOOP_DOWNLOAD_FILES_RETENTION_PERIOD`

---

<a id="upload_files_retention_period"></a>
**`upload_files_retention_period`**  
Specifies the maximum age (in seconds) of upload metadata files that should remain visible in the UI. This helps manage stale or expired uploads.

- **Default**: `86_400` (1 day)
- **Environment Variable**: `OOD_LOOP_UPLOAD_FILES_RETENTION_PERIOD`

---

<a id="ui_feedback_delay"></a>
**`ui_feedback_delay`**  
Defines the delay in milliseconds for feedback messages in the UI, such as temporary banners or notices after actions like a successful upload.

- **Default**: `1_500`
- **Environment Variable**: `OOD_LOOP_UI_FEEDBACK_DELAY`

---

<a id="detached_controller_interval"></a>
**`detached_controller_interval`**  
Controls how often (in seconds) the detached background process controller checks for updates or process state changes.

- **Default**: `10`
- **Environment Variable**: `OOD_LOOP_DETACHED_CONTROLLER_INTERVAL`

---

<a id="detached_process_status_interval"></a>
**`detached_process_status_interval`**  
Sets the interval (in milliseconds) between updates for background process statuses shown in the navigation bar. Balances UI responsiveness with backend load.

- **Default**: `10_000` (10 seconds)
- **Environment Variable**: `OOD_LOOP_DETACHED_PROCESS_STATUS_INTERVAL`

---

<a id="max_download_file_size"></a>
**`max_download_file_size`**  
Defines the maximum allowed size (in bytes) for an individual file download. Files larger than this limit will be rejected or not initiated.

- **Default**: `10_737_418_240` (10 GB)
- **Environment Variable**: `OOD_LOOP_MAX_DOWNLOAD_FILE_SIZE`

---

<a id="max_upload_file_size"></a>
**`max_upload_file_size`**  
Defines the maximum allowed size (in bytes) for an individual file upload. Files exceeding this limit will be blocked before submission.

- **Default**: `1_073_741_824` (1 GB)
- **Environment Variable**: `OOD_LOOP_MAX_UPLOAD_FILE_SIZE`

---

<a id="zenodo_enabled"></a>
**`zenodo_enabled`**  
Boolean flag to enable or disable the Zenodo connector in the application. If set to `false`, Zenodo integration will be hidden and inactive.

- **Default**: `false`
- **Environment Variable**: `OOD_LOOP_ZENODO_ENABLED`

---

<a id="guide_url"></a>
**`guide_url`**  
URL to the external documentation site. This is used for help links in the interface and should point to the current user or admin guide for your Loop deployment.

- **Default**: `https://iqss.github.io/ondemand-loop/`
- **Environment Variable**: `OOD_LOOP_GUIDE_URL`

### Other Environment Variables
- [OOD_LOOP_CONFIG_DIRECTORY](#ood_loop_config_directory)
- [OOD_LOOP_COMMAND_SERVER_FILE](#ood_loop_command_server_file)
- [OOD_LOOP_DETACHED_PROCESS_FILE](#ood_loop_detached_process_file)
- [RAILS_ENV](#rails_env)

<a id="ood_loop_config_directory"></a>
**`OOD_LOOP_CONFIG_DIRECTORY`**
Specifies the directory containing YAML configuration files that OnDemand Loop loads at startup to configure its behavior.
These files define the values for [environment-specific properties](#list-of-config-properties) such as paths, limits, and UI settings.
The directory is read once at application boot, so any changes require a restart to take effect.

- **Default**: `/etc/loop/config/loop.d`

---

<a id="ood_loop_command_server_file"></a>
**`OOD_LOOP_COMMAND_SERVER_FILE`**  
Defines the location of the UNIX domain socket used by the command server.
This socket allows internal components (like the UI and background workers) to communicate with the command server via local IPC.
The socket path is derived from the metadata directory and calculated like this: `File.join(metadata_root, 'command.server.sock')`

- **Default**: `~/.loop_metadata/command.server.sock`

---

<a id="ood_loop_detached_process_file"></a>
**`OOD_LOOP_DETACHED_PROCESS_FILE`**  
Path to a lock file used for coordinating detached background process execution.
This lock ensures that only one background controller process is active at a time, preventing conflicts or duplicated work.
The lock path is derived from the metadata directory and calculated like this: `File.join(metadata_root, 'detached.process.lock')`

- **Default**: `~/.loop_metadata/detached.process.lock`

---

<a id="rails_env"></a>
**`RAILS_ENV` or `RACK_ENV`**  
Specifies the Rails environment the application is running under.
This setting controls things like caching, logging verbosity, and error reporting.
Common values are `development`, `production`, and `test`.

The application looks for `RAILS_ENV`, fallbacks to `RACK_ENV` and defaults to `development` if none provided.

- **Default**: `development`

### Sample Configuration Files

The examples below demonstrate how administrators can override defaults using either a YAML file or environment variables.

#### YAML File example

```yaml
# /etc/loop/config/loop.d/config.yml
version: /opt/loop/VERSION
ood_version: /opt/ood/VERSION
metadata_root: ~/loop/metadata
download_root: ~/loop/downloads
ruby_binary: /usr/local/bin/ruby
files_app_path: /pun/sys/dashboard/files/custom
ood_dashboard_path: /pun/sys/dashboard
connector_status_poll_interval: 6_000
locale: ":es"
download_files_retention_period: 172_800
upload_files_retention_period: 172_800
ui_feedback_delay: 2_000
detached_controller_interval: 5
detached_process_status_interval: 2_000
max_download_file_size: 15_000_000_000
max_upload_file_size: 2_000_000_000
zenodo_enabled: true
guide_url: https://example.com/loop
```

#### `.env` File example

```bash
OOD_LOOP_CONFIG_DIRECTORY=/etc/loop/config
OOD_LOOP_COMMAND_SERVER_FILE=/var/loop/metadata/command.server.sock
OOD_LOOP_DETACHED_PROCESS_FILE=/var/loop/metadata/detached.process.lock
RAILS_ENV=production

OOD_VERSION=/opt/ood/VERSION
OOD_LOOP_METADATA_ROOT=~/loop/metadata
OOD_LOOP_DOWNLOAD_ROOT=~/loop/downloads
OOD_LOOP_RUBY_BINARY=/usr/local/bin/ruby
OOD_LOOP_FILES_APP_PATH=/pun/sys/dashboard/files/custom
OOD_LOOP_OOD_DASHBOARD_PATH=/pun/sys/dashboard
OOD_LOOP_CONNECTOR_STATUS_POLL_INTERVAL=6_000
OOD_LOOP_LOCALE=:es
OOD_LOOP_DOWNLOAD_FILES_RETENTION_PERIOD=172_800
OOD_LOOP_UPLOAD_FILES_RETENTION_PERIOD=172_800
OOD_LOOP_UI_FEEDBACK_DELAY=2_000
OOD_LOOP_DETACHED_CONTROLLER_INTERVAL=5
OOD_LOOP_DETACHED_PROCESS_STATUS_INTERVAL=2_000
OOD_LOOP_MAX_DOWNLOAD_FILE_SIZE=15_000_000_000
OOD_LOOP_MAX_UPLOAD_FILE_SIZE=2_000_000_000
OOD_LOOP_ZENODO_ENABLED=true
OOD_LOOP_GUIDE_URL=https://example.com/loop
```
