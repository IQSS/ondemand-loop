# frozen_string_literal: true
require 'net/http'
require 'uri'
require 'fileutils'
require 'json'
require 'mime/types'

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
      upload_file_to_dataverse(
        'screenshot_diagram.jpg',
        'df120162-bde1-44df-8a22-df6e8e596753',
        'My description.',
        'data/subdir1',
        ['Data'],
        'false',
        'false',
        'doi:10.5072/FK2/TA1ZIN',
        'http://localhost:8080'
      )

    ensure
      File.delete(temp_file) if File.exist?(temp_file)
    end

    def upload_file_to_dataverse(file_path, api_key, description, directory_label, categories, restrict, tab_ingest, persistent_id, api_url_base)
      uri = URI("#{api_url_base}/api/datasets/:persistentId/add")
      uri.query = URI.encode_www_form({ persistentId: persistent_id })

      # Prepare the multipart form data boundary
      boundary = "----RubyMultipartPost#{rand(1_000_000)}"
      post_body = []

      # Add the file part
      file = File.open(file_path, 'rb')
      filename = File.basename(file_path)
      content_type = MIME::Types.type_for(filename).first.to_s

      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\"\r\n"
      post_body << "Content-Type: #{content_type}\r\n\r\n"
      post_body << file.read
      post_body << "\r\n"

      # Add the JSON data part
      json_data = {
        description: description,
        directoryLabel: directory_label,
        categories: categories,
        restrict: restrict,
        tabIngest: tab_ingest
      }.to_json

      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"jsonData\"\r\n\r\n"
      post_body << json_data
      post_body << "\r\n"

      post_body << "--#{boundary}--\r\n"

      # Build the request
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request["X-Dataverse-key"] = api_key
      request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
      request.body = post_body.join

      # Perform the request
      response = http.request(request)
      puts "Response Code: #{response.code}"
      puts "Response Body: #{response.body}"
    end

    private

    def upload_follow_redirects(url, file_path, headers = {}, limit = 3, &block)
      raise "Too many redirects" if limit <= 0

      uri = URI.parse(url)
      request = Net::HTTP::Post.new(uri, headers)
      request.body_stream = File.open(file_path, 'rb')
      request.content_length = File.size(file_path)
      request['Content-Type'] = 'application/octet-stream'
      request['X-Dataverse-key'] = @upload_file.metadata.api_key

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
