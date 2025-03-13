module Dataverse::DatasetHelper
  def file_thumbnail(dataverse_metadata, file)
    if ['image/png','image/jpeg', 'image/bmp', 'image/gif'].include? file.data_file.content_type
      src = "#{dataverse_metadata.full_name}/api/access/datafile/#{file.data_file.id}?imageThumb=true"
      image_tag(src, alt: file.label, title: file.label)
    else
      image_tag("file_thumbnail.png", alt: file.label, title: file.label)
    end
  end
end
