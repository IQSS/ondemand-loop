# frozen_string_literal: true

module FileStatusSummary
  extend ActiveSupport::Concern

  def status_summary
    files = status_files || []
    counts = FileStatus::STATUS.to_h { |status| [status, 0] }
    files.each { |f| counts[f.status.to_s] += 1 }
    counts[:total] = files.size
    OpenStruct.new(counts)
  end
end
