# frozen_string_literal: true

class UploadStatus
  attr_reader :file

  def initialize(file)
    @file = file
  end

  def upload_progress
    return 0 if FileStatus.new_statuses.include?(file.status)
    return 100 if FileStatus.completed_statuses.include?(file.status)

    command_client = Command::CommandClient.new(socket_path: ::Configuration.command_server_socket_file)
    request = Command::Request.new(command: 'upload.status', body: { project_id: file.project_id, upload_bundle_id: file.upload_bundle_id, file_id: file.id })
    response = command_client.request(request)
    return 0 if response.error? || response.body.status.nil?

    total = response.body.status[:total].to_i
    return 0 if total.zero?

    uploaded = response.body.status[:uploaded].to_i
    [(uploaded.to_f / total * 100).to_i, 100].min
  end
end
