# frozen_string_literal: true
module Upload
  class UploadService
    include LoggingCommon
    include DateTimeCommon
    include EventLogger
    include Command::CommandHandler

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
          previous_status = file_data.file.status.to_s
          Thread.new do
            file_data.file.update(start_date: now, end_date: nil, status: FileStatus::UPLOADING)
            log_upload_file_event(file_data.file, message: 'events.upload_file.started', metadata: {destination: file_data.upload_bundle.connector_metadata.external_url})
            stats[:progress] += 1
            result = upload_processor.upload
            previous_status = file_data.file.status.to_s
            file_data.file.update(end_date: now, status: result.status)
          rescue => e
            log_error('Error while processing file', {project_id: file_data.project.id, bundle: file_data.upload_bundle.id, file_id: file_data.file.id}, e)
            file_data.file.update(end_date: now, status: FileStatus::ERROR)
            log_upload_file_event(file_data.file, message: 'events.upload_file.error', metadata: {error: e.message, previous_status: previous_status})
          ensure
            stats[:completed] += 1
            stats[:progress] -= 1
            log_upload_file_event(file_data.file, message: 'events.upload_file.finished')
          end
        end
        # Wait for all downloads to complete
        upload_threads.each(&:join)
      end

    end

    def handle_command(request)
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