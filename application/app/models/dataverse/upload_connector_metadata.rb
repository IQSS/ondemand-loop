  # frozen_string_literal: true

module Dataverse
  class UploadConnectorMetadata
    def initialize(upload_file)
      @metadata = upload_file.upload_collection.metadata.to_h.deep_symbolize_keys
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
      dataverse_url
    end

    def files_url
      "#{dataverse_url}/dataset.xhtml?persistentId=#{persistent_id}"
    end

    def to_h
      @metadata.deep_stringify_keys
    end
  end
end
