# Connectors
Connectors are a core extension point of OnDemand Loop.
They encapsulate repository-specific behavior, allowing the application to support multiple [external repository platforms](../user_guide/supported_repositories.md) such as [Dataverse](https://dataverse.org) and [Zenodo](https://zenodo.org) without modifying the core codebase.  
Dataverse is currently the most complete and serves as the reference implementation.

Each connector is responsible for implementing the full lifecycle of interactions with a remote repository—such as URL parsing, dataset browsing, file listing, and upload/download operations.

!!! warning "Connector Deployment Model"

    Connectors are currently **built and deployed as part of the main application**.
    They are **required at build time** and are not dynamically pluggable.

    While the architecture follows naming and loading conventions that could support plugin-based loading in the future, all connector logic, templates, and assets must currently reside within the application codebase and be included in the build.


### Core Responsibilities
Every connector must implement logic to support:

- **Repository URL parsing** (identify and extract dataset/file components)
- **Dataset browsing** (for downloads and uploads)
- **File listing within datasets**
- **Downloading individual files**
- **Selecting/creating datasets for upload**
- **Uploading files to the repository**

If a particular feature is not supported by the remote repository, the connector is still expected to handle that case gracefully and provide meaningful feedback to the user.

---

### Required Components
To integrate a connector fully, you will need to implement:

- **`ConnectorType`**: Symbolic identifier for the repository (e.g., `:dataverse`, `:zenodo`)
- **`Repo::Resolvers`**: Service class that detects the connector based on a repository URL
- **Connector URL Logic**: Parsing and reconstruction of URLs into components like dataset ID, file ID, etc.
- **Controllers & Routes**: For browsing, searching, or dataset and file selection
- **Views**: Templates under standard Rails view paths
- **Display Repo Resolver**: Redirect logic for repository-specific views
- **Connector Metadata**: Classes that store extra data for downloads and uploads
- **Connector Processors**: Logic for executing downloads, uploads, and metadata preparation
- **Status Trackers**: To monitor upload/download job state

All connector logic is dynamically resolved through [`ConnectorClassDispatcher`](https://github.com/IQSS/ondemand-loop/blob/main/application/app/connectors/connector_class_dispatcher.rb), based on the `ConnectorType`.

---

### Creating a Connector
!!! warning "Connector Folder Structure in Transition"

    Connector code is currently mixed with the core application. We are in the process of moving connector-specific classes, templates, and assets into a dedicated `connectors/` folder for better modularity.

Follow these steps to add a new connector:

#### 1. Register the Connector
- Add a new value to `ConnectorType` (e.g., `:figshare`)
- Create a URL resolver in `app/services/repo/resolvers/` that recognizes repository URLs and returns the correct `ConnectorType`

#### 2. Implement Controller and Views
- Add controllers under:  
  `app/controllers/<connector_type>/`
- Add templates under:  
  `app/views/<connector_type>/`

These are used for browsing and selecting datasets or files.

#### 3. Add Connector Processors
Place these in `app/connectors/<connector_type>/`. Required processors include:

- `DownloadConnectorProcessor`
- `UploadBundleConnectorProcessor`
- `UploadConnectorProcessor`
- `RepositorySettingsProcessor`

Each processor implements core logic for interacting with the repository API.

#### 4. Add Metadata Classes
Also in `app/connectors/<connector_type>/`:

- `DownloadConnectorMetadata`
- `UploadBundleConnectorMetadata`

These classes are used to store and retrieve repository-specific metadata for associated models.

#### 5. Add Status Classes
Used to monitor job status and present updates in the UI:

- `DownloadConnectorStatus`
- `UploadConnectorStatus`

#### 6. Add Supporting Services and Models
Use these folders if needed:

- `app/services/<connector_type>/`
- `app/models/<connector_type>/`

---

### Asset Support
Connectors may include CSS and JavaScript assets, but it's optional. Assets are deployed alongside the application and should be placed under namespaced folders:

- `app/assets/stylesheets/<connector_type>/dataset.scss`
- `app/javascripts/controllers/<connector_type>/`


These will be bundled and served with the application like any other asset.

---

### Best Practices

- Use Dataverse as a reference implementation.
- Always implement full feature coverage—even if only to handle the "unsupported" case.
- Follow the naming conventions precisely to ensure dynamic dispatch works.
- Document any API-specific behavior clearly to help users understand limits and expectations.
- Test manually with real repository URLs; there are currently no connector-specific mocks or stubs.
