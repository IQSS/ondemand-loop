# frozen_string_literal: true

module Dataverse
  class UploadBatchConnectorMetadata
    def initialize(upload_batch)
      @metadata = upload_batch.metadata.to_h.deep_symbolize_keys
      @metadata.each_key do |key|
        define_singleton_method("#{key.to_s}="){ |value| @metadata[key] = value }
        define_singleton_method(key){ @metadata[key] }
      end
    end

    # To avoid errors when expected fields are removed from the list of configured attributes
    def method_missing(method_name, *arguments, &block)
      nil
    end

    def server_domain
      @server_domain ||= URI.parse(dataverse_url).host
    end

    # TODO: Improve this logic
    def api_key
      return OpenStruct.new({ collection?: true, server?: false, value: @metadata[:api_key] }) if @metadata[:api_key]

      repo_info = RepoRegistry.repo_db.get(server_domain)
      OpenStruct.new({ collection?: false, server?: true, value: repo_info.metadata.api_key }) if repo_info && repo_info.metadata.api_key
    end

    def api_key?
      api_key.present?
    end

    def repo_name
      dataverse_url
    end

    def dataset_url
      "#{dataverse_url}/dataset.xhtml?persistentId=#{dataset_id}&version=DRAFT"
    end

    def display_collection?
      collection_title.present?
    end

    def select_collection?
      api_key? && collection_id.nil? && dataset_id.nil?
    end

    def display_dataset?
      dataset_title.present?
    end
    def select_dataset?
      api_key? && collection_id.present? && dataset_id.nil?
    end

    def to_h
      @metadata.deep_stringify_keys
    end
  end
end
