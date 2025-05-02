# frozen_string_literal: true
require 'net/http'
require 'uri'
require 'fileutils'

module Upload
  # Utility class to upload a file to an HTTP url.
  # It uploads the file in chunks to be memory efficient.
  # It supports cancelling the upload at any point.
  class BasicHttpRubyUploader
    include LoggingCommon

    attr_reader :upload_url, :upload_file, :temp_file

    def initialize(upload_url, upload_file, temp_file)
      @upload_url = upload_url
      @upload_file = upload_file
      @temp_file = temp_file
    end

    def upload(&block)
      log_info('Uploading...', { url: upload_url, file: upload_file, temp: temp_file })
      FileUtils.cp(upload_file, temp_file)
      upload_follow_redirects(upload_url, temp_file, &block)
    ensure
      File.delete(temp_file) if File.exist?(temp_file)
    end

    private

    def upload_follow_redirects(url, file_path, headers = {}, limit = 3, &block)
      raise "Too many redirects" if limit <= 0

      uri = URI.parse(url)
      request = Net::HTTP::Post.new(uri, headers)
      request.body_stream = File.open(file_path, 'rb')
      request.content_length = File.size(file_path)
      request['Content-Type'] = 'application/octet-stream'

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        response = http.request(request)

        if redirect?(response)
          new_url = URI.join(url, response['location']).to_s
          log_info('Redirect...', { url: new_url, file: file_path, temp: temp_file })
          return upload_follow_redirects(new_url, file_path, headers, limit - 1, &block)
        end

        unless response.is_a?(Net::HTTPSuccess)
          raise "Failed to upload: #{response.code} #{response.message}"
        end

        if block_given?
          context = create_context(url, file_path, request.content_length)
          cancel = yield context
          if cancel
            log_info('Upload canceled.', { url: url, file: file_path, temp: temp_file })
            return
          end
        end

        log_info('Upload successful.', { url: url, file: file_path })
      end
    end

    def redirect?(response)
      response.is_a?(Net::HTTPRedirection) && response['location']
    end

    def create_context(url, location, total)
      {
        url: url,
        location: location,
        total: total
      }
    end
  end
end
