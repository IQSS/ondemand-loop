module Dataverse::DatasetsHelper
  def file_thumbnail(dataverse_url, file)
    if [ 'image/png', 'image/jpeg', 'image/bmp', 'image/gif' ].include? file.data_file.content_type
      src = "#{dataverse_url}/api/access/datafile/#{file.data_file.id}?imageThumb=true"
      image_tag(src, alt: file.label, title: file.label)
    else
      image_tag('file_thumbnail.png', alt: file.label, title: file.label)
    end
  end

  def md5_with_copy(md5sum)
    length = md5sum.length
    truncated = "#{md5sum[0, 3]}...#{md5sum[length-3, 3]}"
    # unique_id = "md5_#{SecureRandom.hex(4)}"

    content_tag(:div, class: 'd-inline-flex align-items-center gap-2') do
      concat content_tag(:code, truncated, class: 'text-monospace')
      # concat button_tag(
      #          "Copy",
      #          type: "button",
      #          class: "btn btn-sm btn-outline-secondary",
      #          id: unique_id,
      #          data: { clipboard_text: md5sum, bs_toggle: "tooltip", bs_title: "Copy to clipboard" },
      #          onclick: "copyToClipboard(this);"
      #        )
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
