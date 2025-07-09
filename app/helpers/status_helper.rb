module StatusHelper

  def cancel_button_disabled?(status)
    FileStatus.completed_statuses.include?(status)
  end
end
