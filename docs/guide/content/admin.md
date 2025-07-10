# Admin Guide

This guide describes how to configure the OnDemand Loop application using environment variables and YAML configuration files. The application's configuration is managed through the `ConfigurationSingleton` class, which provides a centralized interface for accessing all configurable properties.

Each property is defined with sensible defaults and can be overridden in one of two ways:

1. **Environment Variables** — Loaded from `.env` files or system-level environment variables.
2. **YAML Files** — Located in `/etc/loop/config/loop.d` by default.

The configuration system uses the `ConfigurationProperty` abstraction to define properties with specific types (e.g., `path`, `integer`, `boolean`). These properties are then exposed as methods on the global `Configuration` object, allowing the rest of the application to access them consistently.

This guide documents each configuration property, including its purpose, default value, and expected type. It is intended for system administrators deploying or managing OnDemand Loop.

## Setting Configuration Values

There are two ways to override the defaults shown below:

- Create a YAML file in the directory pointed to by `LOOP_CONFIG_DIRECTORY` config parameter (by default `/etc/loop/config/loop.d`) and set the property names as keys.
  
```yaml
    download_root: "~/data/ondemand_loop"
    max_download_file_size: "1073741824"
    ood_dashboard_path: "/pun/sys/ood"
```

- Define an enviroment variable in the system or create a `.env` or `.env.<RAILS_ENV>` (for example `.env.development`) file in the application root directory and set the appropriate environment variables. Environment-specific files takes precedence over `.env` in case of collision.

Sample configuration files can be found in the final section of this guide [Sample Configuration Files](#sample-configuration-files)

## List of config properties
- [connector_status_poll_interval](#connector_status_poll_interval)
- [detached_controller_interval](#detached_controller_interval)
- [detached_process_status_interval](#detached_process_status_interval)
- [download_files_retention_period](#download_files_retention_period)
- [download_root](#download_root)
- [files_app_path](#files_app_path)
- [locale](#locale)
- [max_download_file_size](#max_download_file_size)
- [max_upload_file_size](#max_upload_file_size)
- [metadata_root](#metadata_root)
- [ood_dashboard_path](#ood_dashboard_path)
- [ruby_binary](#ruby_binary)
- [ui_feedback_delay](#ui_feedback_delay)
- [upload_files_retention_period](#upload_files_retention_period)
- [zenodo_enabled](#zenodo_enabled)

### connector_status_poll_interval
- **Purpose:** Interval in milliseconds used by the UI when polling connector status.
- **Default:** `5000`
- **Environment Variable:** `OOD_LOOP_CONNECTOR_STATUS_POLL_INTERVAL`

### detached_controller_interval
- **Purpose:** Interval in seconds that the detached process controller waits between checks.
- **Default:** `10`
- **Environment Variable:** `OOD_LOOP_DETACHED_CONTROLLER_INTERVAL`

### detached_process_status_interval
- **Purpose:** Interval in milliseconds between background process status updates displayed in the navigation bar.
- **Default:** `10 * 1000` (10 seconds)
- **Environment Variable:** `OOD_LOOP_DETACHED_PROCESS_STATUS_INTERVAL`

### download_files_retention_period
- **Purpose:** Maximum age in seconds of download status files that will appear in the UI.
- **Default:** `24 * 60 * 60` (one day)
- **Environment Variable:** `OOD_LOOP_DOWNLOAD_FILES_RETENTION_PERIOD`

### download_root
- **Purpose:** Destination directory for files downloaded from remote repositories.
- **Default:** `$HOME/downloads-ondemand`
- **Environment Variable:** `OOD_LOOP_DOWNLOAD_ROOT`

### files_app_path
- **Purpose:** URL path to the Open OnDemand Files app. Used to link directly to downloaded data.
- **Default:** `/pun/sys/dashboard/files/fs`
- **Environment Variable:** `OOD_LOOP_FILES_APP_PATH`

### locale
- **Purpose:** Default locale for the application interface.
- **Default:** `:en` (English)
- **Environment Variable:** `OOD_LOOP_LOCALE`

### max_download_file_size
- **Purpose:** Maximum allowed size in bytes for a single file download.
- **Default:** `10 * 1024 * 1024 * 1024` (10 GB)
- **Environment Variable:** `OOD_LOOP_MAX_DOWNLOAD_FILE_SIZE`

### max_upload_file_size
- **Purpose:** Maximum allowed size in bytes for a single file upload.
- **Default:** `1024 * 1024 * 1024` (1 GB)
- **Environment Variable:** `OOD_LOOP_MAX_UPLOAD_FILE_SIZE`

### metadata_root
- **Purpose:** Directory where Loop stores metadata such as projects and repository metadata.
- **Default:** `$HOME/.downloads-for-ondemand`
- **Environment Variable:** `OOD_LOOP_METADATA_ROOT`

### ood_dashboard_path
- **Purpose:** URL path to the main Open OnDemand dashboard.
- **Default:** `/pun/sys/dashboard`
- **Environment Variable:** `OOD_LOOP_OOD_DASHBOARD_PATH`

### ruby_binary
- **Purpose:** Path to the Ruby interpreter used when launching background scripts.
- **Default:** `File.join(RbConfig::CONFIG['bindir'], 'ruby')`
- **Environment Variable:** `OOD_LOOP_RUBY_BINARY`

### ui_feedback_delay
- **Purpose:** Delay in milliseconds for certain UI feedback messages.
- **Default:** `1500`
- **Environment Variable:** `OOD_LOOP_UI_FEEDBACK_DELAY`

### upload_files_retention_period
- **Purpose:** Maximum age in seconds of upload status files that will appear in the UI.
- **Default:** `24 * 60 * 60` (one day)
- **Environment Variable:** `OOD_LOOP_UPLOAD_FILES_RETENTION_PERIOD`

### zenodo_enabled
- **Purpose:** Enables or disables the optional Zenodo connector.
- **Default:** `false`
- **Environment Variable:** `OOD_LOOP_ZENODO_ENABLED`

## Other Environment Variables
- [LOOP_CONFIG_DIRECTORY](#loop_config_directory)
- [OOD_LOOP_COMMAND_SERVER_FILE](#ood_loop_command_server_file)
- [OOD_LOOP_DETACHED_PROCESS_FILE](#ood_loop_detached_process_file)
- [RACK_ENV](#rack_env)
- [RAILS_ENV](#rails_env)

### LOOP_CONFIG_DIRECTORY
- **Purpose:** Directory that stores YAML configuration files read at startup.
- **Default:** `/etc/loop/config/loop.d`

### OOD_LOOP_COMMAND_SERVER_FILE
- **Purpose:** Location of the UNIX socket used by the command server.
- **Default:** `File.join(metadata_root, 'command.server.sock')`

### OOD_LOOP_DETACHED_PROCESS_FILE
- **Purpose:** Path to the lock file used for detached process management.
- **Default:** `File.join(metadata_root, 'detached.process.lock')`

### RACK_ENV
- **Purpose:** Indicates the Rack environment. Used when `RAILS_ENV` is not set.
- **Default:** `development`

### RAILS_ENV
- **Purpose:** Indicates the Rails environment.
- **Default:** `development`

## Sample Configuration Files

The examples below demonstrate how administrators can override defaults using either a YAML file or environment variables.

### YAML File example

```yaml
# /etc/loop/config/loop.d/config.yml
connector_status_poll_interval: 6000
detached_controller_interval: 5
detached_process_status_interval: 2000
download_files_retention_period: 172800
download_root: /var/loop/downloads
files_app_path: /pun/sys/dashboard/files/custom
locale: es
max_download_file_size: 15000000000
max_upload_file_size: 2000000000
metadata_root: /var/loop/metadata
ood_dashboard_path: /pun/sys/dashboard
ruby_binary: /usr/local/bin/ruby
ui_feedback_delay: 2000
upload_files_retention_period: 172800
zenodo_enabled: true
```

### `.env` File example

```bash
OOD_LOOP_CONNECTOR_STATUS_POLL_INTERVAL=6000
OOD_LOOP_DETACHED_CONTROLLER_INTERVAL=5
OOD_LOOP_DETACHED_PROCESS_STATUS_INTERVAL=2000
OOD_LOOP_DOWNLOAD_FILES_RETENTION_PERIOD=172800
OOD_LOOP_DOWNLOAD_ROOT=/var/loop/downloads
OOD_LOOP_FILES_APP_PATH=/pun/sys/dashboard/files/custom
OOD_LOOP_LOCALE=es
OOD_LOOP_MAX_DOWNLOAD_FILE_SIZE=15000000000
OOD_LOOP_MAX_UPLOAD_FILE_SIZE=2000000000
OOD_LOOP_METADATA_ROOT=/var/loop/metadata
OOD_LOOP_OOD_DASHBOARD_PATH=/pun/sys/dashboard
OOD_LOOP_RUBY_BINARY=/usr/local/bin/ruby
OOD_LOOP_UI_FEEDBACK_DELAY=2000
OOD_LOOP_UPLOAD_FILES_RETENTION_PERIOD=172800
OOD_LOOP_ZENODO_ENABLED=true
LOOP_CONFIG_DIRECTORY=/etc/loop/config
OOD_LOOP_COMMAND_SERVER_FILE=/var/loop/metadata/command.server.sock
OOD_LOOP_DETACHED_PROCESS_FILE=/var/loop/metadata/detached.process.lock
RAILS_ENV=production
```