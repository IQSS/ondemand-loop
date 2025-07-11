# Connectors

Connectors are a key extension point of OnDemand Loop. They abstract repository specific
behaviour so that the core application can support multiple remote repositories
without changing its own code. [Dataverse](https://dataverse.org) and [Zenodo](https://zenodo.org) are already implemented with
Dataverse acting as the reference implementation.

Every connector must provide logic for:

* Repository URL identification and parsing
* dataset browsing
* listing files within a dataset
* downloading individual files
* selecting datasets for upload
* uploading files to a dataset

A connector typically contains:

- `actions/` – service objects used by controllers when displaying repository pages.
- `download_connector_processor.rb` – downloads files for the connector.
- `upload_connector_processor.rb` – handles uploading individual files.
- `upload_bundle_connector_processor.rb` – creates and manages upload bundles.
- `display_repo_controller_resolver.rb` – resolves a repository URL into a controller/action inside OnDemand Loop.

Dataverse and Zenodo connectors are already implemented and can be used as a reference. All connector classes are dynamically loaded using `ConnectorClassDispatcher` so adding a new connector only requires following the same naming conventions.

### Creating a Connector

1. Copy one of the existing connectors (`app/connectors/dataverse` or `app/connectors/zenodo`) as a starting point and update module names.
2. Implement a resolver under `app/services/repo/resolvers/` that can recognise URLs for your repository and return the proper `ConnectorType`.
3. Add controller classes and views under `app/controllers/<connector>` to browse collections and datasets.
4. Provide processor classes implementing the behaviour required by Loop:
    - identify and parse repository URLs
    - browse datasets and list files
    - download individual files
    - select datasets for upload
    - upload files to a dataset
5. Register any additional routes in `config/routes.rb`.

Following these conventions allows Loop to load the connector dynamically and display it in the Repositories menu.
