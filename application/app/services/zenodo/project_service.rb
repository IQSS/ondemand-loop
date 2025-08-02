module Zenodo
  class ProjectService
    include DateTimeCommon

    def initialize(zenodo_url = 'https://zenodo.org', file_utils: Common::FileUtils.new)
      @zenodo_url = zenodo_url
      @file_utils = file_utils
    end

    def initialize_project
      name = ProjectNameGenerator.generate
      Project.new(id: name, name: name)
    end

    def initialize_download_files(project, record, file_ids)
      record_files = record.files.select { |f| file_ids.include?(f.id) }
      record_files.map do |file|
        DownloadFile.new.tap do |f|
          f.id = DownloadFile.generate_id
          f.project_id = project.id
          f.creation_date = now
          f.type = ConnectorType::ZENODO
          f.filename = file.filename
          f.status = FileStatus::PENDING
          f.size = file.filesize
          f.metadata = {
            zenodo_url: @zenodo_url,
            record_id: record.id,
            id: file.id,
            download_url: file.download_url,
            temp_location: nil
          }
          @file_utils.make_download_file_unique(f)
        end
      end
    end
  end
end
