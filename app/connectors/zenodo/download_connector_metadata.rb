# frozen_string_literal: true

module Zenodo
  class DownloadConnectorMetadata
    delegate_missing_to :metadata

    def initialize(download_file)
      @metadata = ActiveSupport::OrderedOptions.new
      @metadata.merge!(download_file.metadata.to_h.deep_symbolize_keys)
      @project_id = download_file.project_id
    end

    def repo_name
      "Zenodo"
    end

    def files_url
      repo_url = Repo::RepoUrl.parse(zenodo_url)
      Rails.application.routes.url_helpers.explore_path(
        connector_type: ConnectorType::ZENODO.to_s,
        server_domain: repo_url.domain,
        object_type: type,
        object_id: type_id,
        server_scheme: repo_url.scheme_override,
        server_port: repo_url.port_override,
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
