# frozen_string_literal: true
module Download
  class DownloadService
    include LoggingCommon
    include DateTimeCommon
    include EventLogger

    attr_reader :files_provider, :stats

    def initialize(download_files_provider)
      @files_provider = download_files_provider
      @start_time = Time.now
      @stats = { pending: 0, progress: 0, completed: 0, zombies: 0 }
      Command::CommandRegistry.instance.register('detached.download.status', self)
    end

    def start
      log_info('start', {elapsed_time: elapsed_time})
      while true
        files = files_provider.pending_files
        in_progress = files_provider.processing_files
        stats[:pending] = files.length
        stats[:zombies] = in_progress.length

        batch = files.first(1)
        return if batch.empty?

          log_info('Processing Batch', {elapsed_time: elapsed_time, stats: stats_to_s})
          download_threads = batch.map do |file|
            download_processor = ConnectorClassDispatcher.download_processor(file)
            previous_status = file.status.to_s
            Thread.new do
              file.update(start_date: now, end_date: nil, status: FileStatus::DOWNLOADING)
              log_download_file_event(file, message: 'events.download_file.started', metadata: {repo_url: file.connector_metadata.external_url})
              stats[:progress] += 1
              result = download_processor.download
              previous_status = file.status.to_s
              file.update(end_date: now, status: result.status)
            rescue => e
              log_error('Error while processing file', {file_id: file.id}, e)
              file.update(end_date: now, status: FileStatus::ERROR)
              log_download_file_event(file, message: 'events.download_file.error', metadata: {error: e.message, previous_status: previous_status})
            ensure
              stats[:completed] += 1
              stats[:progress] -= 1
              log_download_file_event(file, message: 'events.download_file.finished')
            end
          end
        # Wait for all downloads to complete
        download_threads.each(&:join)
      end

    end

    def process(request)
      stats.merge({start_date: @start_time, elapsed: elapsed_time})
    end

    def shutdown
      log_info('shutdown', {elapsed_time: elapsed_time})
    end

    private

    def elapsed_time
      elapsed_string(@start_time)
    end

    def stats_to_s
      "zombies=#{stats[:zombies]} in_progress=#{stats[:progress]} pending=#{stats[:pending]} completed=#{stats[:completed]}"
    end
  end
end