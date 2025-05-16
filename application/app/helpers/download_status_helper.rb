module DownloadStatusHelper

  def cancel_button_class(status)
    FileStatus.completed_statuses.include?(status) ? 'disabled' : ''
  end
end
