# frozen_string_literal: true

module Common
  class FileSorter
    include DateTimeCommon

    def most_relevant(files)
      files.sort_by do |file|
        [ status_priority(file.status), -sort_date(file) ]
      end
    end

    def most_recent(files)
      files.sort_by do |file|
        -sort_date(file)
      end
    end

    private

    def sort_date(file)
      date = file.end_date || file.start_date || file.creation_date
      to_time(date)&.to_i || 0
    end

    def status_priority(status)
      case
      when status.downloading? || status.uploading?
        0
      when status.pending?
        1
      when status.cancelled?
        2
      when status.error?
        3
      else
        4
      end
    end
  end
end
