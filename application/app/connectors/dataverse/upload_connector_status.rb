# frozen_string_literal: true

module Dataverse
  class UploadConnectorStatus
    include LoggingCommon

    attr_reader :file, :connector_metadata

    def initialize(file)
      @file = file
      @connector_metadata = file.upload_batch.connector_metadata
    end

    def upload_progress
      return 0 if FileStatus.new_statuses.include?(file.status)
      return 100 if FileStatus.completed_statuses.include?(file.status)

      command_client = Command::CommandClient.new(socket_path: ::Configuration.command_server_socket_file)
      request = Command::Request.new(command: 'upload.status', body: {project_id: file.project_id, collection_id: file.collection_id, file_id: file.id})
      response = command_client.request(request)
      total = response.body.status[:total].to_i
      uploaded = response.body.status[:uploaded].to_i
      [ (uploaded.to_f / total * 100).to_i, 100 ].min
    end

  end
end
