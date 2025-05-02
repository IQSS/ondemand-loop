# frozen_string_literal: true
module Upload
  class UploadProcess
    include LoggingCommon
    include DateTimeCommon

    attr_reader :process_id

    def initialize
      @process_id = Process.pid
      @start_time = Time.now
      @services = []
    end

    def launch
      log_info('Process launched', {pid: process_id, elapsed_time: elapsed_time})

      File.open(lock_file, 'w') do |service_lock|
        unless service_lock.flock(File::LOCK_EX | File::LOCK_NB) # Exclusive, non-blocking lock
          log_info('Exit. Other UploadProcess already running', {pid: process_id, elapsed_time: elapsed_time})
          return
        end

        startup

        log_info('Completed', {pid: process_id, elapsed_time: elapsed_time})
      rescue => e
        log_error('Exit. Error while executing UploadProcess', {pid: process_id, elapsed_time: elapsed_time}, e)
      ensure
        shutdown
      end
    end


    def lock_file
      File.join(Configuration.metadata_root, 'upload.process.lock')
    end

    private

    def startup
      #@services << Upload::Command::UploadCommandServer.new(socket_path: Configuration.upload_server_socket_file)
      @services << Upload::UploadService.new(Upload::UploadFilesProvider.new)

      @services.each(&:start)
    end

    def shutdown
      @services.each(&:shutdown)
    end

    def elapsed_time
      elapsed_string(@start_time)
    end

  end
end