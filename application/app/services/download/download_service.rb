# frozen_string_literal: true
module Download
  class DownloadService
    include LoggingCommon

    attr_reader :files_provider, :process_id, :stats

    def initialize(download_files_provider)
      @files_provider = download_files_provider
      @process_id = Process.pid
      @start_time = Time.now.to_i
      @stats = { pending: 0, completed: 0 }
    end
    
    def start
      log_info('Process started', {pid: process_id, elapsed_time: elapsed_time})

      File.open(lock_file, 'w') do |service_lock|
        unless service_lock.flock(File::LOCK_EX | File::LOCK_NB) # Exclusive, non-blocking lock
          log_info('Exit. Other DownloadService already running', {pid: process_id, elapsed_time: elapsed_time})
          return
        end

        process
        log_info('Completed', {pid: process_id, elapsed_time: elapsed_time, stats: stats_to_s})
      rescue => e
        log_error('Exit. Error while executing DownloadService', {pid: process_id, elapsed_time: elapsed_time}, e)
      end
    end

    def process
      while true
        files = files_provider.pending_files
        stats[:pending] = files.length

        log_info('Processing', {pid: process_id, elapsed_time: elapsed_time, stats: stats_to_s})
        batch = files.first(1)
        return if batch.empty?

        download_threads = batch.map do |file|
          download_processor = ConnectorClassDispatcher.download_processor(file)
          Thread.new do
            file.save_status! 'downloading'
            download_processor.download
            file.save_status! 'success'
          rescue => e
            log_error('Error while processing file', {pid: process_id, file_id: file.id}, e)
            file.save_status! 'error'
          ensure
            stats[:completed] += 1
          end
        end
        # Wait for all downloads to complete
        download_threads.each(&:join)
      end

    end

    def stats_to_s
      "pending=#{stats[:pending]} completed=#{stats[:completed]}"
    end

    def lock_file
      File.join(Configuration.metadata_root, 'download.lock')
    end

    private

    def elapsed_time
      total_seconds = Time.now.to_i - @start_time
      Time.at(total_seconds).utc.strftime('%H:%M:%S')
    end

  end
end