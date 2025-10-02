# frozen_string_literal: true

class DetachedProcess
  include LoggingCommon
  include DateTimeCommon
  include Command::CommandHandler

  attr_reader :process_id

  def initialize
    @process_id = Process.pid
    @start_time = Time.now
    @command_server = nil
    @services_manager = nil
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

  def handle_command(request)
    log_info("Shutdown command received...", { pid: process_id })
    @services_manager.shutdown if @services_manager
    return {message: 'shutdown request completed'}
  end

  private

  def startup
    Command::CommandRegistry.instance.register('detached.process.shutdown', self)

    @command_server = Command::CommandServer.new(socket_path: Configuration.command_server_socket_file)
    @command_server.start

    @services << Download::DownloadService.new(Download::DownloadFilesProvider.new)
    @services << Upload::UploadService.new(Upload::UploadFilesProvider.new)

    @services_manager = DetachedServicesManager.new(@services)
    @services_manager.run
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
