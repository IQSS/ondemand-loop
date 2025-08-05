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

    def create_files_from_record(project, record, file_ids)
      record_files = record.files.select { |f| file_ids.include?(f.id) }
      record_files.map do |record_file|
        DownloadFile.new.tap do |f|
          f.id = DownloadFile.generate_id
          f.project_id = project.id
          f.creation_date = now
          f.type = ConnectorType::ZENODO
          f.filename = record_file.filename
          f.status = FileStatus::PENDING
          f.size = record_file.filesize
          f.metadata = {
            zenodo_url: @zenodo_url,
            type: 'records',
            type_id: record.id,
            id: record_file.id,
            download_url: record_file.download_url,
            temp_location: nil
          }
          @file_utils.make_download_file_unique(f)
        end
      end
    end

    def create_files_from_deposition(project, deposition, file_ids)
      files = deposition.files.select { |f| file_ids.include?(f.id) }
      files.map do |deposition_file|
        DownloadFile.new.tap do |f|
          f.id = DownloadFile.generate_id
          f.project_id = project.id
          f.creation_date = now
          f.type = ConnectorType::ZENODO
          f.filename = deposition_file.filename
          f.status = FileStatus::PENDING
          f.size = deposition_file.filesize
          f.metadata = {
            zenodo_url: @zenodo_url,
            type: 'depositions',
            type_id: deposition.id,
            id: deposition_file.id,
            download_url: deposition_file.download_url,
            temp_location: nil
          }
          @file_utils.make_download_file_unique(f)
        end
      end
    end

  end
end
