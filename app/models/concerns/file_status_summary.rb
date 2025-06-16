# frozen_string_literal: true

module FileStatusSummary
  extend ActiveSupport::Concern

  def self.compute_summary(files)
    counts = FileStatus::STATUS.to_h { |status| [status, 0] }
    elapsed = 0
    earliest_start = nil
    latest_end = nil

    files.each do |f|
      counts[f.status.to_s] += 1
      if f.start_date && f.end_date
        start_date = DateTimeCommon.to_time(f.start_date)
        end_date = DateTimeCommon.to_time(f.end_date)

        elapsed += DateTimeCommon.elapsed(start_date, end_date)
        earliest_start = start_date if earliest_start.nil? || start_date < earliest_start
        latest_end = end_date if latest_end.nil? || end_date > latest_end
      end
    end

    counts[:total] = files.size
    counts[:elapsed] = DateTimeCommon.format_elapsed(elapsed)
    counts[:start_date] = DateTimeCommon.to_string(earliest_start)
    counts[:end_date] =  DateTimeCommon.to_string(latest_end)
    OpenStruct.new(counts)
  end

  def status_summary
    FileStatusSummary.compute_summary(status_files || [])
  end
end
