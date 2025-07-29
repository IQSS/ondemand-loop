module ProjectsHelper

  def active_project?(project_id)
    Current.settings.user_settings.active_project.to_s == project_id
  end
  def project_header_class(active)
    active ? 'bg-primary-subtle' : 'bg-body-secondary'
  end

  def project_border_class(active)
    active ? 'border-primary-subtle' : ''
  end

  def project_progress_data(file_status_count, title = '')
    pending = file_status_count.pending.to_i + file_status_count.downloading.to_i
    completed = file_status_count.success.to_i
    cancelled = file_status_count.cancelled.to_i
    error = file_status_count.error.to_i
    {
      id: SecureRandom.uuid,
      title: title,
      pending: pending,
      completed: completed,
      cancelled: cancelled,
      error: error,
      total: file_status_count.total
    }
  end

end