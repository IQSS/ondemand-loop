  # frozen_string_literal: true

module Dataverse
  class DownloadConnectorMetadata
    def initialize(download_file)
      @metadata = download_file.metadata.to_h.deep_symbolize_keys
      @metadata.each_key do |key|
        define_singleton_method("#{key.to_s}="){ |value| @metadata[key] = value }
        define_singleton_method(key){ @metadata[key] }
      end
    end

    # To avoid errors when expected fields are removed from the list of configured attributes
    def method_missing(method_name, *arguments, &block)
      nil
    end

    def repo_name
      parents&.first&.[](:name) || 'N/A'
    end

    def files_url
      return nil unless dataset_id

      dataverse_uri = Dataverse::DataverseUrl.parse(dataverse_url)
      scheme = dataverse_uri.scheme_override
      hostname = dataverse_uri.domain
      port = dataverse_uri.port
      Rails.application.routes.url_helpers.view_dataverse_dataset_path(dv_scheme: scheme, dv_hostname: hostname, dv_port: port, persistent_id: dataset_id)
    end

    def to_h
      @metadata.deep_stringify_keys
    end
  end
end
