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
    @lock_file = Configuration.detached_process_lock_file
    setup_cleanup_handlers
  end

  def launch
    log_info('Process launched', { pid: process_id, lock_file: @lock_file })
    startup
    log_info('Completed', { pid: process_id, elapsed_time: elapsed_time })
  rescue => e
    log_error('Exit. Error while executing DetachedProcess', { pid: process_id, elapsed_time: elapsed_time }, e)
  ensure
    shutdown
  end

  private

  def startup
    @command_server = Command::CommandServer.new(socket_path: Configuration.command_server_socket_file)
    @command_server.start

    @services << Download::DownloadService.new(Download::DownloadFilesProvider.new)
    @services << Upload::UploadService.new(Upload::UploadFilesProvider.new)

    controller = DetachedProcessManager.new(@services)
    controller.run
  end

  def shutdown
    @command_server.shutdown if @command_server
  end

  def elapsed_time
    elapsed_string(@start_time)
  end

  def setup_cleanup_handlers
    # Clean up lock file when process exits normally or abnormally
    at_exit do
      cleanup_lock_file
    end

    # Handle signals gracefully (TERM, INT, QUIT, HUP)
    %w[TERM INT QUIT HUP].each do |signal|
      Signal.trap(signal) do
        log_info("Received #{signal}, shutting down gracefully...", { pid: process_id })
        cleanup_lock_file
        exit(0)
      end
    end
  end

  def cleanup_lock_file
    return unless @lock_file && File.exist?(@lock_file)

    File.delete(@lock_file)
    log_info("Lock file cleaned up", { pid: process_id, lock_file: @lock_file })
  rescue => e
    # Log error but don't raise to avoid masking the original exit reason
    log_error("Could not clean up lock file", { pid: process_id, lock_file: @lock_file }, e)
  end
end
