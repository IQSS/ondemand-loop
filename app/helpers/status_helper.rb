module StatusHelper

  def download_file_size(file)
    current_size = file.connector_status.download_size
    total_size = file.size
    "#{number_to_human_size(current_size)} / #{number_to_human_size(total_size)}"
  end
  def cancel_button_disabled?(status)
    FileStatus.completed_statuses.include?(status)
  end

  def retry_button_visible?(file)
    file.restart_possible?
  end
end
