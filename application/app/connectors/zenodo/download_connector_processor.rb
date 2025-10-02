# frozen_string_literal: true

module Zenodo
  class DownloadConnectorProcessor
    include LoggingCommon
    include EventLogger
    include Command::CommandHandler

    attr_reader :file, :connector_metadata, :cancelled

    def initialize(file)
      @file = file
      @connector_metadata = file.connector_metadata
      @cancelled = false
      Command::CommandRegistry.instance.register('file.download.cancel', self)
    end

    def download
      download_url = connector_metadata.download_url
      download_location = file.download_location
      temp_location = file.download_tmp_location
      FileUtils.mkdir_p(File.dirname(download_location))

      repo_info = ::Configuration.repo_db.get(connector_metadata.zenodo_url)
      api_key = repo_info&.metadata&.auth_key
      headers = {}
      headers[Zenodo::ApiService::AUTH_HEADER] = "Bearer #{api_key}" if api_key.present?

      download_processor = Download::BasicHttpRubyDownloader.new(
        download_url,
        download_location,
        temp_location,
        headers: headers,
      )
      begin
        download_processor.download do |_context|
          cancelled
        end
      rescue StandardError => e
        connector_metadata.partial_downloads = download_processor.partial_downloads
        file.update({ metadata: connector_metadata.to_h })
        FileUtils.rm_f(temp_location) if download_processor.partial_downloads == false
        log_error('Download failed', { id: file.id, url: download_url, partial_downloads: download_processor.partial_downloads }, e)
        log_download_file_event(file, message: 'events.download_file.error', metadata: {
          error: e.message,
          url: download_url,
          partial_downloads: download_processor.partial_downloads
        })
        return response(FileStatus::ERROR, 'file download failed')
      end

      connector_metadata.partial_downloads = download_processor.partial_downloads
      file.update({ metadata: connector_metadata.to_h })

      if cancelled
        FileUtils.rm_f(temp_location) if download_processor.partial_downloads == false
        return response(FileStatus::CANCELLED, 'file download cancelled')
      end

      response(FileStatus::SUCCESS, 'file download completed')
    end

    def handle_command(request)
      if file.id == request.body.file_id
        @cancelled = true
        return { message: 'cancellation requested' }
      end
      nil
    end

    private

    def response(file_status, message)
      OpenStruct.new({ status: file_status, message: message })
    end
  end
end

