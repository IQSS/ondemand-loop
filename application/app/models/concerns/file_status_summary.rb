# frozen_string_literal: true

module FileStatusSummary
  extend ActiveSupport::Concern

  def self.compute_summary(files)
    counts = FileStatus::STATUS.to_h { |status| [status, 0] }
    files.each { |f| counts[f.status.to_s] += 1 }
    counts[:total] = files.size
    OpenStruct.new(counts)
  end

  def self.files_summary(recent_files)
  first_date = recent_files.last&.file&.start_date || DateTimeCommon.now
  last_date = recent_files.first&.file&.end_date || DateTimeCommon.now
  elapsed = DateTimeCommon.elapsed_string(first_date, last_date)
  OpenStruct.new({
                   idle?: true,
                   start_date: first_date,
                   elapsed: elapsed,
                   pending: 0,
                   progress: 0,
                   completed: recent_files.size,
                   total: recent_files.size
                 })

  end

  def status_summary
    FileStatusSummary.compute_summary(status_files || [])
  end
end
