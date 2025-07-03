# frozen_string_literal: true

require 'net/http'

module Zenodo
  # Utility class to upload a file to a Zenodo bucket using PUT and raw binary stream.
  # It supports progress reporting and cancellation via block/yield.
  class ZenodoBucketHttpUploader
    include LoggingCommon

    attr_reader :upload_url, :upload_file_path, :headers

    def initialize(upload_url, upload_file_path, headers = {})
      @upload_url = upload_url
      @upload_file_path = upload_file_path
      @headers = headers
    end

    def upload(&)
      log_info('Uploading to Zenodo bucket...', { url: upload_url, file: upload_file_path })
      upload_stream(upload_url, upload_file_path, headers, &)
    end

    private

    def upload_stream(url, file_path, headers, &)
      uri = URI.parse(url)

      file_io = ProgressIO.new(file_path) do |context|
        if block_given?
          cancel = yield context
          if cancel
            log_info('Upload canceled.', { url: upload_url, file: upload_file_path })
            return
          end
        end
      end

      request = Net::HTTP::Put.new(uri)
      headers.each { |key, value| request[key] = value }
      request.body_stream = file_io
      request.content_length = File.size(file_path)
      request.content_type = 'application/octet-stream'

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        response = http.request(request)
        raise "Upload failed. code=#{response.code} body=#{response.body}" unless response.is_a?(Net::HTTPSuccess)
        log_info('Upload complete.', { status: response.code })
      end
    ensure
      file_io&.close
    end

    # Reuses the same progress reporting class from Multipart uploader
    class ProgressIO
      def initialize(file_path, chunk_size: 16 * 1024, &callback)
        @total_size = File.size(file_path)
        @file = File.open(file_path, 'rb')
        @uploaded = 0
        @chunk_size = chunk_size
        @callback = block_given? ? callback : nil
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
          uploaded: @uploaded
        }
        @callback.call(context) if @callback
      end
    end
  end
end
