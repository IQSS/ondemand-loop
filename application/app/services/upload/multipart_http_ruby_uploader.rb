# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'net/http/post/multipart'

module Upload
  # Utility class to upload a file via multipart/form-data using Net::HTTP.
  # It streams the file for memory efficiency and supports progress reporting and cancellation.
  class MultipartHttpRubyUploader
    include LoggingCommon

    attr_reader :upload_url, :upload_file_path, :payload, :headers

    def initialize(upload_url, upload_file_path, payload = {}, headers = {})
      @upload_url = upload_url
      @upload_file_path = upload_file_path
      @payload = payload
      @headers = headers
    end

    def upload(&)
      log_info('Uploading...', { url: upload_url, file: upload_file_path, payload: payload })
      upload_multipart(upload_url, upload_file_path, payload, headers, &)
    end

    private

    def default_headers
      {}
    end

    def upload_multipart(url, file_path, payload, headers, &)
      uri = URI.parse(url)
      log_info("Uploading file #{file_path} to #{url}", { url: url, file_path: file_path })

      file_io = ProgressIO.new(file_path) do |context|
        if block_given?
          cancel = yield context
          if cancel
            log_info('Upload canceled.', { url: upload_url, file: upload_file_path })
            raise :upload_canceled
          end
        end
      end

      upload_io = UploadIO.new(file_io, 'application/octet-stream', File.basename(file_path))

      multipart = {
        'file' => upload_io,
        'jsonData' => payload.to_json
      }

      request = Net::HTTP::Post::Multipart.new(uri.request_uri, multipart, default_headers.merge(headers))

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        response = http.request(request)
        log_info("response: #{response.code}", { response: response, body: response.body })
        raise "Upload failed: #{response.code}" unless response.is_a?(Net::HTTPSuccess)
        log_info('Upload complete.', { status: response.code })
      end
    rescue => e
      log_error('Upload failed.', { error: e.message })
      raise
    ensure
      file_io&.close
    end

    # Internal class for chunked reading with progress reporting
    class ProgressIO
      def initialize(file_path, chunk_size: 16 * 1024)
        @total_size = File.size(file_path)
        @file = File.open(file_path, 'rb')
        @uploaded = 0
        @chunk_size = chunk_size
        #@callback = block_given? ? Proc.new : nil
        @file_path = file_path
      end

      def path
        @file_path
      end

      def read(length = nil, outbuf = nil)
        chunk = @file.read(length || @chunk_size, outbuf)
        if chunk
          @uploaded += chunk.bytesize
          report_progress
        end
        chunk
      end

      def rewind
        @file.rewind
        @uploaded = 0
      end

      def close
        @file.close
      end

      private

      def report_progress
        context = {
          file: @file_path,
          total: @total_size,
          uploaded: @uploaded,
          percent: ((@uploaded.to_f / @total_size) * 100).round(2)
        }
        #@callback.call(context) if @callback
      end
    end
  end
end
