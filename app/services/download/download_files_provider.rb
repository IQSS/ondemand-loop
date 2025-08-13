# frozen_string_literal: true

module Download
  class DownloadFilesProvider
    include DateTimeCommon

    def recent_files
      retention_period = Configuration.download_files_retention_period
      list = all.select { |data| FileStatus.active_statuses.include?(data.file.status) || elapsed(data.file.end_date) < retention_period }
      file_map = list.to_h { |data| [ data.file, data ] }
      Common::FileSorter.new.most_relevant(file_map.keys).map { |file| file_map[file] }
    end

    def pending_files
      Project.all.flat_map(&:download_files).select { |f| f.status.pending? }
    end

    def processing_files
      Project.all.flat_map(&:download_files).select { |f| f.status.downloading? }
    end

    def all
      Project.all.flat_map do |project|
        project.download_files.map do |file|
          OpenStruct.new(file: file, project: project)
        end
      end
    end
  end
end
