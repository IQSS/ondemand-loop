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
Based on analysis of existing implementations (Dataverse and Zenodo), a complete connector requires these components:

#### Core Infrastructure Components

- **`ConnectorType`** registration in `app/models/connector_type.rb`
- **URL Parser** class in `app/services/<connector>/<connector>_url.rb`
- **Repository URL Resolver** in `app/services/repo/resolvers/<connector>_resolver.rb`
- **Display Repository Controller Resolver** in `app/connectors/<connector>/display_repo_controller_resolver.rb`

#### Processor Classes (in `app/connectors/<connector>/`)

- **`DownloadConnectorProcessor`** - Handles file downloads from the repository
- **`UploadConnectorProcessor`** - Handles individual file uploads
- **`UploadBundleConnectorProcessor`** - Handles upload bundle operations
- **`RepositorySettingsProcessor`** - Manages repository configuration

#### Metadata Classes (in `app/connectors/<connector>/`)

- **`DownloadConnectorMetadata`** - Stores download-specific metadata
- **`UploadBundleConnectorMetadata`** - Stores upload bundle metadata

#### Handler Classes (in `app/connectors/<connector>/handlers/`)

Handlers implement repository browsing and dataset/file selection workflows:

- **`Landing`** - Repository landing page (lists repositories/servers)
- **Collection handlers** - Browse collections/communities
- **Dataset handlers** - Browse and select datasets
- **File handlers** - List files within datasets
- **Upload handlers** - Dataset creation and upload workflows

#### Supporting Services (in `app/services/<connector>/`)

- **`ApiService`** - Base API service with authentication headers
- **`ProjectService`** - Creates projects and configures download files with connector specific metadata
- **Domain-specific services** (e.g., `DatasetService`, `CollectionService`)

#### Views and Templates (in `app/views/connectors/<connector>/`)

- Landing pages, dataset browsers, file listings
- Upload/download forms and progress views
- Breadcrumb navigation and search interfaces

All connector logic is dynamically resolved through `ConnectorClassDispatcher`, which uses naming conventions to instantiate the correct connector-specific classes based on the `ConnectorType`.

---

### Creating a Connector

Follow these steps to implement a new connector (using `figshare` as an example):

#### 1. Register the Connector Type

Add the new connector to the `TYPES` array in `app/models/connector_type.rb`:

```ruby
TYPES = %w[dataverse zenodo figshare].freeze
```

#### 2. Create URL Parser

Implement URL parsing logic in `app/services/figshare/figshare_url.rb`:

```ruby
module Figshare
  class FigshareUrl
    TYPES = %w[figshare article file unknown].freeze

    attr_reader :type, :article_id, :file_id
    delegate :domain, :scheme, :port, to: :base

    def self.parse(url)
      base = Repo::RepoUrl.parse(url)
      return nil unless base
      new(base)
    end

    def figshare_url
      base.server_url
    end

    private

    def parse_type_and_ids
      # Parse URL segments to extract article/file IDs
      # Set @type, @article_id, @file_id based on URL pattern
    end
  end
end
```

#### 3. Implement URL Resolution

Create a repository URL resolver `app/services/repo/resolvers/figshare_resolver.rb`:

```ruby
module Repo
  module Resolvers
    class FigshareResolver < Repo::BaseResolver
      def priority
        8_000  # Lower number = higher priority
      end

      def resolve(context)
        return unless context.object_url
        return if context.type

        repo_url = Figshare::FigshareUrl.parse(context.object_url)
        return unless repo_url&.domain

        if responds_to_api?(context.http_client, repo_url)
          success(context, repo_url.figshare_url)
        end
      end

      private

      def success(context, repo_base_url)
        context.type = ConnectorType::FIGSHARE
        context.repo_db.set(repo_base_url, type: ConnectorType::FIGSHARE)
      end
    end
  end
end
```

#### 4. Implement Core Processor Classes

Create the processor classes in `app/connectors/figshare/`:

**Download Processor** (`download_connector_processor.rb`):
```ruby
module Figshare
  class DownloadConnectorProcessor
    include LoggingCommon

    def initialize(file)
      @file = file
      @connector_metadata = file.connector_metadata
    end

    def download
      # Implement download logic using repository API
      # Return OpenStruct.new(status: FileStatus::SUCCESS, message: "...")
    end
  end
end
```

**Upload Processors** (`upload_connector_processor.rb`, `upload_bundle_connector_processor.rb`):
```ruby
module Figshare
  class UploadConnectorProcessor
    def initialize(file)
      @file = file
      @connector_metadata = file.upload_bundle.connector_metadata
    end

    def upload
      # Implement file upload logic
    end
  end

  class UploadBundleConnectorProcessor
    def initialize(upload_bundle)
      @upload_bundle = upload_bundle
    end

    def process
      # Implement batch upload processing
    end
  end
end
```

#### 5. Add Metadata Classes

Create metadata classes in `app/connectors/figshare/`:

```ruby
module Figshare
  class DownloadConnectorMetadata
    delegate_missing_to :metadata

    def initialize(download_file)
      @metadata = ActiveSupport::OrderedOptions.new
      @metadata.merge!(download_file.metadata.to_h.deep_symbolize_keys)
    end

    def to_h
      metadata.to_h.deep_stringify_keys
    end
  end

  class UploadBundleConnectorMetadata
    def initialize(upload_bundle)
      @metadata = upload_bundle.metadata.to_h.deep_symbolize_keys
    end

    def configured?
      # Return true if all required metadata is present
    end
  end
end
```

#### 6. Implement Display Controller Resolver

Create `app/connectors/figshare/display_repo_controller_resolver.rb`:

```ruby
module Figshare
  class DisplayRepoControllerResolver
    def initialize(object = nil)
      # Required for ConnectorClassDispatcher interface
    end

    def get_controller_url(object_url)
      figshare_url = Figshare::FigshareUrl.parse(object_url)

      if figshare_url.article?
        redirect_url = link_to_explore(ConnectorType::FIGSHARE, figshare_url,
                                       type: 'articles', id: figshare_url.article_id)
      else
        redirect_url = link_to_landing(ConnectorType::FIGSHARE)
      end

      ConnectorResult.new(redirect_url: redirect_url, success: true)
    end
  end
end
```

#### 7. Add Repository Settings Processor

Create `app/connectors/figshare/repository_settings_processor.rb`:

```ruby
module Figshare
  class RepositorySettingsProcessor
    def initialize(object = nil)
    end

    def process(repository_data)
      # Process repository configuration settings
      # Return ConnectorResult with success/failure status
    end
  end
end
```

#### 8. Create Handler Classes

Implement handlers in `app/connectors/figshare/handlers/`:

- `landing.rb` - Repository landing page
- `articles.rb` - Browse articles/datasets
- `collections.rb` - Browse collections
- Various upload handlers for dataset creation

Each handler should follow this pattern:

```ruby
module Figshare::Handlers
  class Articles
    def initialize(object_id = nil)
      @article_id = object_id
    end

    def params_schema
      [:repo_url, :page, :query]
    end

    def show(request_params)
      # Implement browsing logic
      # Return ConnectorResult with template and locals
    end
  end
end
```

#### 9. Add Supporting Services

Create services in `app/services/figshare/`:

- `api_service.rb` - Base API service
- `project_service.rb` - Project and file creation
- Domain-specific services for articles, collections, etc.

#### 10. Create Views and Templates

Add view templates in `app/views/connectors/figshare/`:

- Landing pages
- Article/collection browsers
- File listing views
- Upload forms

---

### Implementation Patterns and Key Interfaces

#### Dynamic Class Loading

The `ConnectorClassDispatcher` uses Ruby's `constantize` method to dynamically load connector classes:

```ruby
def self.load(module_name, class_name, object)
  connector_class = "#{module_name.to_s.camelize}::#{class_name}"
  connector_class.constantize.new(object)
rescue NameError
  raise ConnectorNotSupported, "Invalid connector type #{module_name}. Class not found: #{connector_class}"
end
```

This requires strict adherence to naming conventions:
- Module name must match connector type (e.g., `Dataverse`, `Zenodo`)
- Class names must match expected patterns (e.g., `DownloadConnectorProcessor`)

#### Handler Interface Pattern

Handlers must implement a consistent interface:

- `initialize(object_id = nil)` - Constructor with optional object ID
- `params_schema` - Array of allowed request parameters
- `show(request_params)` - Main action method returning `ConnectorResult`

#### Processor Interface Pattern

Processors follow these patterns:

**Download Processors:**
- Must implement `download()` method
- Should support cancellation via command registry
- Return status object with `status` and `message` fields

**Upload Processors:**
- Must implement `upload()` method
- Should handle file verification (MD5 checksums)
- Support progress tracking and cancellation

#### Metadata Class Pattern

Metadata classes use `delegate_missing_to` for flexible attribute access:

```ruby
class DownloadConnectorMetadata
  delegate_missing_to :metadata

  def initialize(download_file)
    @metadata = ActiveSupport::OrderedOptions.new
    @metadata.merge!(download_file.metadata.to_h.deep_symbolize_keys)
  end

  def to_h
    metadata.to_h.deep_stringify_keys
  end
end
```

#### ConnectorResult Response Pattern

All handlers and resolvers should return `ConnectorResult` objects:

```ruby
ConnectorResult.new(
  template: '/connectors/figshare/articles/show',
  locals: { articles: articles, pagination: pagination },
  resource: resource_object,
  success: true,
  message: { alert: "Error message" },
  redirect_url: "/path/to/redirect"
)
```

#### URL Parsing Interface

URL parser classes should implement:

- `self.parse(url)` class method
- Type detection methods (e.g., `article?`, `dataset?`)
- ID extraction properties (e.g., `dataset_id`, `file_id`)
- Server URL reconstruction method

#### Authentication Patterns

API services define authentication headers:

```ruby
module Figshare
  class ApiService
    AUTH_HEADER = 'Authorization'  # or connector-specific header

    class UnauthorizedException < StandardError; end
    class ApiKeyRequiredException < StandardError; end
  end
end
```

---

### Asset Support
Connectors may include CSS and JavaScript assets, but it's optional. Assets are deployed alongside the application and should be placed under namespaced folders:

- `app/assets/stylesheets/<connector_type>/dataset.scss`
- `app/javascripts/controllers/<connector_type>/`


These will be bundled and served with the application like any other asset.

---

### Best Practices

#### Architecture and Design

- **Use Dataverse as reference implementation** - It has the most complete feature set and serves as the canonical example
- **Follow naming conventions precisely** - Dynamic class loading requires exact naming patterns for modules and classes
- **Implement all required interfaces** - Even if a repository doesn't support a feature, handle it gracefully with meaningful error messages
- **Use Ruby modules for namespacing** - All connector classes should be namespaced (e.g., `Dataverse::`, `Zenodo::`)

#### Error Handling and User Experience

- **Implement graceful degradation** - Handle unsupported features with clear user feedback
- **Use ConnectorResult consistently** - Return structured results with success/failure status and user messages
- **Support operation cancellation** - Register with `Command::CommandRegistry` for download/upload cancellation
- **Provide meaningful error messages** - Use I18n keys for user-facing error messages

#### API Integration

- **Implement proper authentication** - Uploads and private/draft datasets typically require authorization
- **Handle rate limiting and retries** - Repository APIs may have usage limits
- **Validate checksums when available** - Verify file integrity using MD5 or other hashes provided by the repository
- **Support pagination** - Many repository APIs paginate results for large datasets

#### URL Parsing and Resolution

- **Parse URLs comprehensively** - Handle different URL formats the repository supports (permalinks, versioned URLs, etc.)
- **Support URL reconstruction** - Be able to build canonical URLs from parsed components
- **Set appropriate resolver priorities** - Lower numbers = higher priority in the resolver chain
- **Test edge cases** - Handle malformed URLs, missing components, and ambiguous patterns

#### Testing and Development

- **Use mocks for automated testing** - Create unit, integration, and end-to-end tests with mocked repository responses
- **Test manually with real instances** - Use live repository systems or locally running instances for manual validation
- **Implement comprehensive test coverage** - Test all processor classes, handlers, and metadata classes
- **Document API-specific limitations** - Help users understand what operations are supported
- **Use logging extensively** - Include LoggingCommon and log important operations for debugging

#### Performance Considerations

- **Implement efficient file transfers** - Use streaming uploads/downloads for large files
- **Cache API responses when appropriate** - Reduce API calls for static data
- **Handle large datasets gracefully** - Support pagination and lazy loading for file listings
- **Implement progress tracking** - Provide user feedback for long-running operations
