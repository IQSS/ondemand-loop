module Dataverse
  class ProjectService
    include LoggingCommon
    include DateTimeCommon

    def initialize(dataverse_url, file_utils: Common::FileUtils.new)
      @dataverse_url = dataverse_url
      @file_utils = file_utils
    end

    def initialize_project
      name = ProjectNameGenerator.generate
      Project.new(id: name, name: name)
    end

    def initialize_download_files(project, dataset_id, dataset, files_page, file_ids)
      dataset_files = files_page.files_by_ids(file_ids)
      dataset_files.each.map do |dataset_file|
        DownloadFile.new.tap do |f|
          f.id = DownloadFile.generate_id
          f.project_id = project.id
          f.creation_date = now
          f.type = ConnectorType::DATAVERSE
          f.filename = dataset_file.full_filename
          f.status = FileStatus::PENDING
          f.size = dataset_file.filesize
          f.metadata = {
            dataverse_url: @dataverse_url,
            dataset_id: dataset_id,
            version: dataset.version,
            title: dataset.title,
            parents: dataset.data.parents,
            id: dataset_file.data_file.id.to_s,
            content_type: dataset_file.content_type,
            storage: dataset_file.data_file.storage_identifier,
            md5: dataset_file.data_file.md5,
            download_url: nil,
            temp_location: nil,
          }

          @file_utils.make_download_file_unique(f)
        end
      end
    end
  end
end