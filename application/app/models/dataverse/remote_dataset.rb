# app/models/dataverse/remote_dataset.rb
module Dataverse
  class RemoteDataset
    attr_reader :url, :dataset_name, :api_key, :doi

    def initialize(attrs = {})
      @url = attrs[:url]
      @dataset_name = attrs[:dataset_name]
      @api_key = attrs[:api_key]
      @doi = attrs[:doi]
    end

    def valid?
      url.present? && api_key.present?
    end

    def to_h
      {
        type: 'Dataverse',
        url: url,
        dataset_name: dataset_name,
        api_key: api_key,
        doi: doi
      }
    end
  end
end
