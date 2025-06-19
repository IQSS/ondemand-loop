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

    def initialize_download_files(project, dataset, file_ids)
      dataset_files = dataset.files.select { |f| file_ids.include?(f.id) }
      dataset_files.map do |dataset_file|
        DownloadFile.new.tap do |f|
          f.id = DownloadFile.generate_id
          f.project_id = project.id
          f.creation_date = now
          f.type = ConnectorType::ZENODO
          f.filename = dataset_file.filename
          f.status = FileStatus::PENDING
          f.size = dataset_file.filesize
          f.metadata = {
            zenodo_url: @zenodo_url,
            record_id: dataset.id,
            id: dataset_file.id,
            download_url: dataset_file.download_url,
            download_location: nil,
            temp_location: nil
          }
          @file_utils.make_download_file_unique(f)
        end
      end
    end
  end
end
