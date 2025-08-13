# frozen_string_literal: true

module Upload
  class UploadFilesProvider
    include DateTimeCommon

    def recent_files
      retention_period = Configuration.upload_files_retention_period
      list = all.select { |data| FileStatus.active_statuses.include?(data.file.status) || elapsed(data.file.end_date) < retention_period }
      file_map = list.to_h { |data| [ data.file, data ] }
      Common::FileSorter.new.most_relevant(file_map.keys).map { |file| file_map[file] }
    end

    def pending_files
      all.select { |data| data.file.status.pending? }
    end

    def processing_files
      all.select { |data| data.file.status.uploading? }
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
