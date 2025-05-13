# frozen_string_literal: true

module Dataverse
  class UploadConnectorStatus
    include LoggingCommon

    attr_reader :file, :connector_metadata

    def initialize(file)
      @file = file
      @connector_metadata = file.upload_collection.connector_metadata
    end

    def upload_progress
      return 0 if FileStatus.new_statuses.include?(file.status)
      return 100 if FileStatus.completed_statuses.include?(file.status)

      command_client = Download::Command::DownloadCommandClient.new(socket_path: ::Configuration.download_server_socket_file)
      request = Download::Command::Request.new(command: 'status.upload', body: {project_id: file.project_id, collection_id: file.collection_id, file_id: file.id})
      response = command_client.request(request)
      log_info("response: #{response}", {response: response})
      log_info("response body : #{response.body}", {response_body: response.body})

      response.body.status[:progress]
    end

  end
end
