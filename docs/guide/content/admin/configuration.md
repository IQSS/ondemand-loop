# Configuration

This section covers all the core system settings that control how OnDemand Loop operates in your environment. The configuration system uses the `ConfigurationProperty` abstraction to define properties with specific types (e.g., `path`, `integer`, `boolean`). These properties are then exposed as methods on the global `Configuration` object, allowing the rest of the application to access them consistently.

### Setting Configuration Values

You can override the default configuration values in **two supported ways**:

#### 1. YAML Configuration Files (`/etc/loop/config/loop.d`)

Create one or more `.yml` files in the directory: `/etc/loop/config/loop.d`

Each file should contain a simple key-value structure where the keys match the configuration property names (e.g. `download_root`). These files are loaded **once at application startup**, so any changes require a restart.

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

### Configuration Properties

The following properties control various aspects of OnDemand Loop's behavior. Each property can be set via YAML configuration files or environment variables as described above.

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
- [restart_delay](#restart_delay)
- [detached_controller_interval](#detached_controller_interval)
- [detached_process_status_interval](#detached_process_status_interval)
- [max_download_file_size](#max_download_file_size)
- [max_upload_file_size](#max_upload_file_size)
- [guide_url](#guide_url)
- [http_proxy](#http_proxy)
- [default_connect_timeout](#default_connect_timeout)
- [default_read_timeout](#default_read_timeout)
- [default_pagination_items](#default_pagination_items)
- [dataverse_hub_url](#dataverse_hub_url)
- [zenodo_default_url](#zenodo_default_url)
- [logging_root](#logging_root)
- [navigation](#navigation)

---

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
Defines the destination directory where project-organized files from [remote repositories](../user_guide/supported_repositories.md) (e.g., Dataverse, Zenodo) are downloaded.
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

<a id="restart_delay"></a>
**`restart_delay`**  
Sets the delay in milliseconds before redirecting users after application restart or reset operations. This gives users time to read completion messages.

- **Default**: `3_000`
- **Environment Variable**: `OOD_LOOP_RESTART_DELAY`

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

<a id="guide_url"></a>
**`guide_url`**  
URL to the external documentation site. This is used for help links in the interface and should point to the current user or admin guide for your Loop deployment.

- **Default**: `https://iqss.github.io/ondemand-loop/`
- **Environment Variable**: `OOD_LOOP_GUIDE_URL`

---

<a id="http_proxy"></a>
**`http_proxy`**  
Proxy server settings for outbound HTTP requests made by internal clients (such as the `Common::HttpClient` class). This is used to route API requests through a proxy, which may be required in secure or enterprise network environments.

The value should be a hash with the following optional keys:
- `:host`: proxy server hostname or IP (e.g., `'proxy.example.com'`)
- `:port`: port number used by the proxy (e.g., `8080`)
- `:user`: (optional) username for proxy authentication
- `:password`: (optional) password for proxy authentication

- **Default**: no proxy (`nil`)
- **Environment Variable**: _Not supported_

---

<a id="default_connect_timeout"></a>
**`default_connect_timeout`**  
Global default timeout (in seconds) for opening an HTTP connection. This setting applies to all HTTP requests made by internal clients like `Common::HttpClient`.

- **Default**: `5` seconds
- **Environment Variable**: `OOD_LOOP_DEFAULT_CONNECTION_TIMEOUT`

---

<a id="default_read_timeout"></a>
**`default_read_timeout`**  
Global default timeout (in seconds) for waiting for data to be read from an open HTTP connection. Used by the internal HTTP client to ensure long-running requests do not block the app indefinitely.

- **Default**: `15` seconds
- **Environment Variable**: `OOD_LOOP_DEFAULT_READ_TIMEOUT`

---

<a id="default_pagination_items"></a>
**`default_pagination_items`**  
Specifies the default number of items to display per page in paginated responses.
This setting affects UI components and API calls that support pagination, ensuring consistent page sizes across the application when no explicit value is provided.

- **Default**: `20` items
- **Environment Variable**: `OOD_LOOP_DEFAULT_PAGINATION_ITEMS`

---

<a id="dataverse_hub_url"></a>
**`dataverse_hub_url`**  
Specifies the URL to the Dataverse Hub API endpoint for retrieving the list of available Dataverse installations.
This endpoint provides a registry of public Dataverse repositories that users can browse and connect to from the application.
The URL should point to the `/api/installations` endpoint of a Dataverse Hub instance.
For development or testing environments, this can be pointed to a mock server.

- **Default**: `https://hub.dataverse.org/api/installations`
- **Environment Variable**: `OOD_LOOP_DATAVERSE_HUB_URL`

---

<a id="zenodo_default_url"></a>
**`zenodo_default_url`**  
Defines the default Zenodo server URL used throughout the application.
This URL serves as the default target for Zenodo operations when no specific server is configured.
It affects the Zenodo landing page, search functionality, and server selection in the UI.
For development or testing environments, this can be pointed to alternative Zenodo instances or mock servers.

- **Default**: `https://zenodo.org`
- **Environment Variable**: `OOD_LOOP_ZENODO_DEFAULT_URL`

---

<a id="logging_root"></a>
**`logging_root`**  
Defines the root directory where application log files are written.
When set, logs are organized into subdirectories named after the system user running the application (e.g., `<logging_root>/<username>/`).

If this property is not set:

- **Rails application logs** default to the OnDemand Passenger log location: `/var/log/ondemand-nginx/<username>/`
- **Detached process logs** are written under the metadata directory: `~/.loop_metadata/logs/`

This setting is useful for centralizing logs, integrating with system monitoring, or storing logs on dedicated volumes for backup and retention.

- **Default**: `nil`
- **Environment Variable**: `OOD_LOOP_LOGGING_ROOT`

---

<a id="navigation"></a>
**`navigation`**
Defines custom navigation bar items that override or extend the default application navigation.
This array property allows administrators to customize the navigation bar at the top of the application, including hiding default items, adding new links, or creating dropdown menus.
For detailed configuration options and examples, see the [Navigation Customization](customizations.md#application-navigation-bar) section.

- **Default**: `[]` (empty array, uses default navigation)
- **Environment Variable**: _Not supported_

---

### Other Environment Variables

These additional environment variables control application behavior and are typically set at the system level.

- [OOD_LOOP_CONFIG_DIRECTORY](#ood_loop_config_directory)
- [OOD_LOOP_COMMAND_SERVER_FILE](#ood_loop_command_server_file)
- [OOD_LOOP_DETACHED_PROCESS_FILE](#ood_loop_detached_process_file)
- [RAILS_ENV](#rails_env)

---

<a id="ood_loop_config_directory"></a>
**`OOD_LOOP_CONFIG_DIRECTORY`**  
Specifies the directory containing YAML configuration files that OnDemand Loop loads at startup to configure its behavior.
These files define the values for [environment-specific properties](#configuration-properties) such as paths, limits, and UI settings.
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
restart_delay: 3_000
detached_controller_interval: 5
detached_process_status_interval: 2_000
max_download_file_size: 15_000_000_000
max_upload_file_size: 2_000_000_000
guide_url: https://example.com/loop
dataverse_hub_url: https://hub.dataverse.org/api/installations
zenodo_default_url: https://zenodo.org
logging_root: /var/log/loop
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
OOD_LOOP_RESTART_DELAY=3_000
OOD_LOOP_DETACHED_CONTROLLER_INTERVAL=5
OOD_LOOP_DETACHED_PROCESS_STATUS_INTERVAL=2_000
OOD_LOOP_MAX_DOWNLOAD_FILE_SIZE=15_000_000_000
OOD_LOOP_MAX_UPLOAD_FILE_SIZE=2_000_000_000
OOD_LOOP_GUIDE_URL=https://example.com/loop
OOD_LOOP_DATAVERSE_HUB_URL=https://hub.dataverse.org/api/installations
OOD_LOOP_ZENODO_DEFAULT_URL=https://zenodo.org
OOD_LOOP_LOGGING_ROOT=/var/log/loop
```