require 'net/http'
require 'uri'
require 'json'
# require 'mime/types'
require 'tempfile'

module Dataverse
  class ProgressIO
    def initialize(io, progress_file_path)
      @io = io
      @progress_file_path = progress_file_path
      @bytes_sent = 0
    end

    def read(length = nil, outbuf = nil)
      chunk = @io.read(length, outbuf)
      if chunk
        @bytes_sent += chunk.bytesize
        File.write(@progress_file_path, @bytes_sent)
      end
      chunk
    end

    def rewind
      @io.rewind
      @bytes_sent = 0
      File.write(@progress_file_path, 0)
    end
  end


  class HttpUploader
    def initialize(upload_file)
      @upload_file = upload_file
      @file_path = upload_file.metadata.file_location
      raise "File path not found" unless @file_path && File.exist?(@file_path)

      @filename = upload_file.filename
      @description = upload_file.metadata[:description]
      @directory_label = upload_file.metadata[:directory_label]
      @categories = ['Data']
      @restrict = 'false'
      @tab_ingest = 'false'
      @persistent_id = upload_file.metadata[:persistent_id]
      @api_key = upload_file.metadata[:api_key]
      @dataverse_url = upload_file.metadata[:dataverse_url]
      @progress_file = "/tmp/upload_#{upload_file.id}.progress"
    end

    def upload
      uri = URI("#{@dataverse_url}/api/datasets/:persistentId/add")
      uri.query = URI.encode_www_form({ persistentId: @persistent_id })

      boundary = "----RubyMultipartPost#{rand(1_000_000)}"
      content_type = @upload_file.metadata[:content_type] || MIME::Types.type_for(@filename).first.to_s

      # Build the full multipart body in a temp file
      tmp = Tempfile.new('upload-body')
      tmp.binmode

      # File part
      tmp.write("--#{boundary}\r\n")
      tmp.write("Content-Disposition: form-data; name=\"file\"; filename=\"#{@filename}\"\r\n")
      tmp.write("Content-Type: #{content_type}\r\n\r\n")
      File.open(@file_path, 'rb') { |f| IO.copy_stream(f, tmp) }
      tmp.write("\r\n")

      # jsonData part
      json_data = {
        description: @description,
        directoryLabel: @directory_label,
        categories: @categories,
        restrict: @restrict,
        tabIngest: @tab_ingest
      }.to_json

      tmp.write("--#{boundary}\r\n")
      tmp.write("Content-Disposition: form-data; name=\"jsonData\"\r\n\r\n")
      tmp.write(json_data)
      tmp.write("\r\n--#{boundary}--\r\n")
      tmp.rewind

      # Wrap body in progress-tracking stream
      progress_io = ProgressIO.new(tmp, @progress_file)

      # Make the request
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Post.new(uri.request_uri)
      request['X-Dataverse-key'] = @api_key
      request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
      request.body_stream = progress_io
      request.content_length = tmp.size
      request['Transfer-Encoding'] = 'identity'

      response = http.request(request)

      tmp.close
      tmp.unlink
      response
    end

    def progress
      return 0 unless File.exist?(@progress_file)
      bytes_sent = File.read(@progress_file).to_i
      (bytes_sent.to_f / @upload_file.size * 100).round
    end
  end

end
