# frozen_string_literal: true

module Zenodo
  class ProjectService
    include DateTimeCommon

    def initialize(zenodo_url = Zenodo::ZenodoUrl::DEFAULT_URL, file_utils: Common::FileUtils.new)
      @zenodo_url = zenodo_url
      @file_utils = file_utils
    end

    def initialize_project
      name = ProjectNameGenerator.generate
      Project.new(id: name, name: name)
    end

    def create_files_from_record(project, record, file_ids)
      build_download_files(
        project: project,
        source: record,
        file_ids: file_ids,
        type: 'records'
      )
    end

    def create_files_from_deposition(project, deposition, file_ids)
      build_download_files(
        project: project,
        source: deposition,
        file_ids: file_ids,
        type: 'depositions'
      )
    end

    private

    def build_download_files(project:, source:, file_ids:, type:)
      source.files.select { |f| file_ids.include?(f.id) }.map do |file|
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
            type: type,
            type_id: source.id,
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
