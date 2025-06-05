# frozen_string_literal: true

class DetachedProcess
  include LoggingCommon
  include DateTimeCommon

  attr_reader :process_id

  def initialize
    @process_id = Process.pid
    @start_time = Time.now
    @command_server = nil
    @services = []
  end

  def launch
    log_info('Process launched', {pid: process_id, elapsed_time: elapsed_time})

    File.open(lock_file, 'w') do |service_lock|
      unless service_lock.flock(File::LOCK_EX | File::LOCK_NB) # Exclusive, non-blocking lock
        log_info('Exit. Other DetachedProcess already running', {pid: process_id, elapsed_time: elapsed_time})
        return
      end

      startup

      log_info('Completed', {pid: process_id, elapsed_time: elapsed_time})
    rescue => e
      log_error('Exit. Error while executing DetachedProcess', {pid: process_id, elapsed_time: elapsed_time}, e)
    ensure
      shutdown
    end
  end


  def lock_file
    File.join(Configuration.metadata_root, 'detached.process.lock')
  end

  private

  def startup
    @command_server = Command::CommandServer.new(socket_path: Configuration.command_server_socket_file)
    @command_server.start

    @services << Download::DownloadService.new(Download::DownloadFilesProvider.new)
    @services << Upload::UploadService.new(Upload::UploadFilesProvider.new)

    controller = DetachedProcessController.new(@services)
    controller.run
  end

  def shutdown
    @command_server.shutdown if @command_server
  end

  def elapsed_time
    elapsed_string(@start_time)
  end

end
