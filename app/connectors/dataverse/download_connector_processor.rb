# frozen_string_literal: true
module Dataverse
  # Dataverse connector download processor. Responsible for downloading files of type Dataverse
  class DownloadConnectorProcessor
    include LoggingCommon

    attr_reader :file, :connector_metadata, :cancelled
    def initialize(file)
      @file = file
      @connector_metadata = file.connector_metadata
      @cancelled = false
      Command::CommandRegistry.instance.register('download.cancel', self)
    end

    def download
      download_url = FluentUrl.new(connector_metadata.dataverse_url)
                             .add_path('api')
                             .add_path('access')
                             .add_path('datafile')
                             .add_path(connector_metadata.id.to_s)
                             .add_param(:format, 'original')
                             .to_s
      download_location = file.download_location
      temp_location = file.download_tmp_location
      FileUtils.mkdir_p(File.dirname(download_location))

      connector_metadata.download_url = download_url
      connector_metadata.temp_location = temp_location
      file.update({metadata: connector_metadata.to_h})

      repo_info = RepoRegistry.repo_db.get(connector_metadata.dataverse_url)
      api_key = repo_info&.metadata&.auth_key
      headers = {}
      headers[Dataverse::ApiService::AUTH_HEADER] = api_key if api_key.present?

      download_processor = Download::BasicHttpRubyDownloader.new(
        download_url,
        download_location,
        temp_location,
        headers: headers
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
        return response(FileStatus::ERROR, 'file download failed')
      end

      connector_metadata.partial_downloads = download_processor.partial_downloads
      file.update({ metadata: connector_metadata.to_h })

      if cancelled
        FileUtils.rm_f(temp_location) if download_processor.partial_downloads == false
        return response(FileStatus::CANCELLED, 'file download cancelled')
      end

      md5_result = verify(download_location, connector_metadata.md5)
      log_info('Download completed', {id: file.id, location: download_location, md5_valid: md5_result})
      if md5_result
        response(FileStatus::SUCCESS, 'file download completed')
      else
        response(FileStatus::ERROR, 'file download completed, md5 check failed')
      end
    end

    def process(request)
      if file.id == request.body.file_id
        # CANCELLATION IS FOR THIS FILE
        @cancelled = true
        return {message: 'cancellation requested'}
      end

      return nil
    end

    private

    def verify(file_path, expected_md5)
      log_info('Verifying file', {file_path: file_path, expected_md5: expected_md5})
      return false unless File.exist?(file_path)

      file_md5 = Digest::MD5.file(file_path).hexdigest
      if file_md5 == expected_md5
        log_info('Checksum verification success', {file_path: file_path, expected_md5: expected_md5})
        true
      else
        log_error('Checksum verification failed', {file_path: file_path, expected_md5: expected_md5, current_md5: file_md5})
        false
      end
    end

    def response(file_status, message)
      OpenStruct.new({status: file_status, message: message})
    end
  end
end
