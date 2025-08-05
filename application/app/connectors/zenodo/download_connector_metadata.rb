# frozen_string_literal: true

module Zenodo
  class DownloadConnectorMetadata
    def initialize(download_file)
      @metadata = download_file.metadata.to_h.deep_symbolize_keys
      @metadata.each_key do |key|
        define_singleton_method("#{key}=") { |value| @metadata[key] = value }
        define_singleton_method(key) { @metadata[key] }
      end
    end

    def method_missing(method_name, *args, &block)
      nil
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
        server_port: repo_url.port_override
      )
    end

    def to_h
      @metadata.deep_stringify_keys
    end
  end
end
