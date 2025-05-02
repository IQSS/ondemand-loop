# frozen_string_literal: true
module Upload
  class UploadService
    include LoggingCommon
    include DateTimeCommon

    attr_reader :files_provider, :stats

    def initialize(upload_files_provider)
      @files_provider = upload_files_provider
      @start_time = Time.now
      @stats = { pending: 0, completed: 0 }
    end

    def start
      log_info('start', {elapsed_time: elapsed_time})
      while true
        files = files_provider.pending_files
        in_progress = files_provider.processing_files
        stats[:pending] = files.length
        stats[:progress] = in_progress.length

        log_info('Processing', {elapsed_time: elapsed_time, stats: stats_to_s})
        batch = files.first(1)
        return if batch.empty?

        upload_threads = batch.map do |file|
          upload_processor = ConnectorClassDispatcher.upload_processor(file)
          Thread.new do
            file.update(start_date: now, status: FileStatus::UPLOADING)
            result = upload_processor.upload
            file.update(end_date: now, status: result.status)
          rescue => e
            log_error('Error while processing file', {file_id: file.id}, e)
            file.update(end_date: now, status: FileStatus::ERROR)
          ensure
            stats[:completed] += 1
          end
        end
        # Wait for all downloads to complete
        upload_threads.each(&:join)
      end

    end

    def shutdown
      log_info('shutdown', {elapsed_time: elapsed_time})
    end

    private

    def elapsed_time
      elapsed_string(@start_time)
    end

    def stats_to_s
      "in_progress=#{stats[:progress]} pending=#{stats[:pending]} completed=#{stats[:completed]}"
    end

  end
end