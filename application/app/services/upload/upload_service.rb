# frozen_string_literal: true
module Upload
  class UploadService
    include LoggingCommon
    include DateTimeCommon

    attr_reader :files_provider, :stats

    def initialize(upload_files_provider)
      @files_provider = upload_files_provider
      @start_time = Time.now
      @stats = { pending: 0, progress: 0, completed: 0, zombies: 0 }
      Command::CommandRegistry.instance.register('detached.upload.status', self)
    end

    def start
      log_info('start', {elapsed_time: elapsed_time})
      while true
        pending = files_provider.pending_files
        in_progress = files_provider.processing_files
        stats[:pending] = pending.length
        stats[:zombies] = in_progress.length

        log_info('Processing', {elapsed_time: elapsed_time, stats: stats_to_s})
        batch = pending.first(1)
        return if batch.empty?

        upload_threads = batch.map do |file_data|
          upload_processor = ConnectorClassDispatcher.upload_processor(file_data.upload_bundle, file_data.file)
          Thread.new do
            file_data.file.update(start_date: now, status: FileStatus::UPLOADING)
            stats[:progress] += 1
            result = upload_processor.upload
            file_data.file.update(end_date: now, status: result.status)
          rescue => e
            log_error('Error while processing file', {project_id: file_data.project.id, bundle: file_data.upload_bundle.id, file_id: file_data.file.id}, e)
            file_data.file.update(end_date: now, status: FileStatus::ERROR)
          ensure
            stats[:completed] += 1
            stats[:progress] -= 1
          end
        end
        # Wait for all downloads to complete
        upload_threads.each(&:join)
      end

    end

    def process(request)
      data = stats.merge({start_date: @start_time, elapsed: elapsed_time})
      log_info('Requested stats', { stats: data })
      data
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