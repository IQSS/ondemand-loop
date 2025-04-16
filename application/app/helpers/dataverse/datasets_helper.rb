module Dataverse::DatasetsHelper
  def file_thumbnail(dataverse_url, file)
    if [ 'image/png', 'image/jpeg', 'image/bmp', 'image/gif' ].include? file.data_file.content_type
      src = "#{dataverse_url}/api/access/datafile/#{file.data_file.id}?imageThumb=true"
      image_tag(src, alt: file.label, title: file.label)
    else
      image_tag('file_thumbnail.png', alt: file.label, title: file.label)
    end
  end

  def verify_dataset(dataset)
    retrictions_service.validate_dataset(dataset)
  end

  def verify_file(file)
    retrictions_service.validate_dataset_file(file)
  end

  private

  def retrictions_service
    restrictions = Configuration.connector_config(:dataverse)[:restrictions]
    @validation_service ||= Dataverse::DataverseRestrictionsService.new(dataverse_restrictions: restrictions)
  end
end
