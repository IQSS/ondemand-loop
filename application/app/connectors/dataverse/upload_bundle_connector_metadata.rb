# frozen_string_literal: true

module Dataverse
  class UploadBundleConnectorMetadata
    include Dataverse::Concerns::DataverseUrlBuilder

    def initialize(upload_bundle)
      @metadata = upload_bundle.metadata.to_h.deep_symbolize_keys
      @metadata.each_key do |key|
        define_singleton_method("#{key.to_s}="){ |value| @metadata[key] = value }
        define_singleton_method(key){ @metadata[key] }
      end
    end

    # To avoid errors when expected fields are removed from the list of configured attributes
    def method_missing(method_name, *arguments, &block)
      nil
    end

    # TODO: Improve this logic
    def api_key
      return OpenStruct.new({ bundle?: true, server?: false, value: @metadata[:auth_key] }) if @metadata[:auth_key]

      repo_info = ::Configuration.repo_db.get(dataverse_url)
      OpenStruct.new({ bundle?: false, server?: true, value: repo_info.metadata.auth_key }) if repo_info && repo_info.metadata.auth_key
    end

    def api_key?
      api_key.present?
    end

    def repo_name
      dataverse_url
    end

    def fetch_draft?
      api_key? && dataset_id.present? && dataset_title.nil?
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

    def api_key_required?
      api_key.nil? && (collection_id.nil? || dataset_id.nil?)
    end

    def to_h
      @metadata.deep_stringify_keys
    end
  end
end
