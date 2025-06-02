module Dataverse::Concerns::DataverseUrlBuilder
  extend ActiveSupport::Concern

  def collection_url
    raise 'collection_id is missing' unless collection_id

    "#{dataverse_url}/dataverse/#{collection_id}"
  end

  def dataset_url(version: nil)
    raise 'dataset_id (DOI) is missing' unless dataset_id

    url = "#{dataverse_url}/dataset.xhtml?persistentId=#{dataset_id}"
    url += "&version=#{version}" if version
    url
  end
end