module Dataverse::Concerns::DataverseUrlBuilder
  extend ActiveSupport::Concern

  def collection_url
    raise 'collection_id is missing' unless collection_id
    FluentUrl.new(dataverse_url)
      .add_path('dataverse')
      .add_path(collection_id)
      .to_s
  end

  def dataset_url(version: nil)
    raise 'dataset_id (DOI) is missing' unless dataset_id
    url = FluentUrl.new(dataverse_url)
              .add_path('dataset.xhtml')
              .add_param('persistentId', dataset_id)
    url.add_param('version', version) if version
    url.to_s
  end
end