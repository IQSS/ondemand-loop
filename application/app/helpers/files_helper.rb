# frozen_string_literal: true

module FilesHelper
  include DateTimeCommon

  def files_progress_data(file_status_count, title = '')
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

  def files_summary(recent_files)
    first_date = recent_files.first.created_at || now
    last_date = recent_files.last.created_at || now
    elapsed = elapsed(first_date, last_date)
    OpenStruct.new({
      start_date: first_date,
      elapsed: elapsed,
      pending: 0,
      progress: 0,
      completed: recent_files.size,
      total: recent_files.size
    })
  end

end