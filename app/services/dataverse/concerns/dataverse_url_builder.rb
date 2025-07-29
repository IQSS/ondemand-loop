module Dataverse::Concerns::DataverseUrlBuilder
  extend ActiveSupport::Concern

  def build_dataverse_url(scheme, domain, port)
    scheme ||= 'https'
    base = "#{scheme}://#{domain}"
    base += ":#{port}" if port
    FluentUrl.new(base).to_s
  end

  def collection_url
    build_collection_url(dataverse_url, collection_id)
  end

  def build_collection_url(dataverse_url, collection_id)
    raise 'dataverse URL is missing' unless dataverse_url
    raise 'collection_id is missing' unless collection_id
    FluentUrl.new(dataverse_url)
             .add_path('dataverse')
             .add_path(collection_id)
             .to_s
  end

  def dataset_url(version: nil)
    build_dataset_url(dataverse_url, dataset_id, version: version)
  end

  def build_dataset_url(dataverse_url, dataset_id, version: nil)
    raise 'dataverse URL is missing' unless dataverse_url
    raise 'dataset_id (DOI) is missing' unless dataset_id
    dataset_url = FluentUrl.new(dataverse_url)
                   .add_path('dataset.xhtml')
                   .add_param('persistentId', dataset_id)
    dataset_url.add_param('version', version) if version
    dataset_url.to_s
  end

  module_function :build_dataverse_url, :build_collection_url, :build_dataset_url
end