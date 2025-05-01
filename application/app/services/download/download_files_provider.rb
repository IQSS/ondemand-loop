# frozen_string_literal: true

module Download
  class DownloadFilesProvider
    include DateTimeCommon

    def recent_files
      retention_period = Configuration.download_files_retention_period
      all.select{|data| data.file.end_date.blank? || elapsed(data.file.end_date) < retention_period }
         .sort_by do |data|
        group = if data.file.start_date && data.file.end_date.nil?
                  0 # In Progress
                elsif data.file.start_date.nil?
                  1 # Pending
                else
                  2 # Completed / Other
                end

        start_time = to_time(data.file.start_date)
        created_time = to_time(data.file.creation_date)
        [
          group,
          group == 0 ? start_time : (group == 1 ? created_time : start_time)
        ]
      end

    end

    def pending_files
      Project.all.flat_map(&:files).select{|f| f.status.pending?}
    end

    def processing_files
      Project.all.flat_map(&:files).select{|f| f.status.downloading?}
    end

    def all
      Project.all.flat_map do |project|
        project.files.map do |file|
          OpenStruct.new(file: file, project: project)
        end
      end
    end

  end
end
