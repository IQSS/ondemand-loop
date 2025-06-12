
module DetachedProcessStatus
  extend ActiveSupport::Concern

  def download_status
    command_client = Command::CommandClient.new(socket_path: ::Configuration.command_server_socket_file)
    request = Command::Request.new(command: 'detached.download.status')
    parse_response(command_client.request(request))
  end

  def upload_status
    command_client = Command::CommandClient.new(socket_path: ::Configuration.command_server_socket_file)
    request = Command::Request.new(command: 'detached.upload.status')
    parse_response(command_client.request(request))
  end

  def from_files_summary(files_summary)
    idle = files_summary.downloading == 0 && files_summary.pending == 0
    completed = files_summary.success + files_summary.error + files_summary.cancelled
    data = { idle?: idle, progress: files_summary.downloading, completed: completed }.merge(files_summary.to_h)
    OpenStruct.new(data)
  end

  private

  def parse_response(response)
    idle = response.status.to_s != '200' || (response.body.pending == 0 && response.body.progress == 0)
    data = { idle?: idle }.merge(response.body.to_h)
    OpenStruct.new(data)
  end
end
