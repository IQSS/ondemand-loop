# frozen_string_literal: true

module Upload
  class UploadFilesProvider
    include DateTimeCommon

    def recent_files
      retention_period = Configuration.upload_files_retention_period
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
      all.select{ |data| data.file.status.pending? }
    end

    def processing_files
      all.select{ |data| data.file.status.uploading? }
    end

    def all
      Project.all.flat_map do |project|
        project.upload_bundles.flat_map do |upload_bundle|
          upload_bundle.files.map do |file|
            OpenStruct.new(file: file, project: project, upload_bundle: upload_bundle)
          end
        end
      end
    end

  end
end
