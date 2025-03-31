# frozen_string_literal: true
module Download
  class DownloadService
    include LoggingCommon

    attr_reader :process_id, :stats

    def initialize
      @process_id = Process.pid
      @start_time = Time.now.to_i
      @stats = { pending: 0, completed: 0 }
    end
    
    def start
      log_info('Process started', {pid: process_id, elapsed_time: elapsed_time})

      File.open(lock_file, 'w') do |service_lock|
        unless service_lock.flock(File::LOCK_EX | File::LOCK_NB) # Exclusive, non-blocking lock
          log_info('Exit. Other DownloadService already running', {pid: process_id, elapsed_time: elapsed_time})
          exit 1
        end

        process
        log_info('Completed', {pid: process_id, elapsed_time: elapsed_time, stats: stats_to_s})
      rescue => e
        log_error('Error while executing DownloadService', {error_class: e.class, error: e.message})
      end
    end

    def process
      while true
        files = DownloadCollection.all.flat_map(&:files).select{|f| f.status == 'ready'}
        stats[:pending] = files.length

        log_info('Processing', {pid: process_id, elapsed_time: elapsed_time, stats: stats_to_s})
        batch = files.first(1)
        return if batch.empty?

        download_threads = batch.map do |file|
          download_connector = Download::DownloadFactory.download_connector(file)
          Thread.new do
            file.status = 'downloading'
            file.save
            download_connector.download(file)
            file.status = 'success'
          rescue => e
            Rails.logger.info e.message
            file.status = 'error'
          ensure
            stats[:completed] += 1
            file.save
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