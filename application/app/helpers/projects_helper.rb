module ProjectsHelper

  def project_header_class(active)
    active ? 'bg-primary-subtle' : 'bg-body-secondary'
  end

  def project_border_class(active)
    active ? 'border-primary-subtle' : ''
  end

  def project_progress_data(project)
    pending = project.count.pending.to_i + project.count.downloading.to_i
    completed = project.count.success.to_i
    cancelled = project.count.cancelled.to_i
    error = project.count.error.to_i
    {
      id: project.id,
      pending: pending,
      completed: completed,
      cancelled: cancelled,
      error: error,
      total: project.count.total
    }
  end

end