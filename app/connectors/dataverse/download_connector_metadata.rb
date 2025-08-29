  # frozen_string_literal: true

module Dataverse
  class DownloadConnectorMetadata
    delegate_missing_to :metadata

    def initialize(download_file)
      @metadata = ActiveSupport::OrderedOptions.new
      @metadata.merge!(download_file.metadata.to_h.deep_symbolize_keys)
      @project_id = download_file.project_id
    end

    def repo_name
      parents&.first&.[](:name) || 'N/A'
    end

    def files_url
      return nil unless dataset_id

      dataverse_uri = Dataverse::DataverseUrl.parse(dataverse_url)
      Rails.application.routes.url_helpers.explore_path(
        connector_type: ConnectorType::DATAVERSE.to_s,
        server_domain: dataverse_uri.domain,
        server_scheme: dataverse_uri.scheme_override,
        server_port: dataverse_uri.port,
        object_type: 'datasets',
        object_id: dataset_id,
        version: version,
        active_project: @project_id
      )
    end

    def to_h
      metadata.to_h.deep_stringify_keys
    end

    private

    attr_reader :metadata
  end
end
