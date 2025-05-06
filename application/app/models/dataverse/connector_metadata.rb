  # frozen_string_literal: true

module Dataverse
  class ConnectorMetadata
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
      hostname = URI.parse(dataverse_url).hostname
      Rails.application.routes.url_helpers.view_dataverse_dataset_path(dv_hostname: hostname, persistent_id: persistent_id)
    end

    def to_h
      @metadata.deep_stringify_keys
    end
  end
end
