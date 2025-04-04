require 'net/http'
require 'stringio'

class HttpResponseMock
  attr_reader :code, :body

  def initialize(file_path, status_code = 200, headers = {})
    @file_path = file_path
    @code = status_code.to_s
    @headers = headers
    @body = File.read(file_path)
  end

  def [](key)
    @headers[key]
  end

  def is_a?(klass)
    case klass.name
    when 'Net::HTTPRedirection'
      code.start_with?('3')
    when 'Net::HTTPSuccess'
      code.start_with?('2')
    else
      super
    end
  end

  def read_body
    if block_given?
      File.open(@file_path, "rb") do |file|
        while (chunk = file.read(1024))
          yield chunk
        end
      end
    else
      @body
    end
  end
end

class HttpMock
  def initialize(file_path:, status_code: 200, headers: {})
    @file_path = file_path
    @status_code = status_code
    @headers = headers
  end

  def request(req)
    response = HttpResponseMock.new(@file_path, @status_code, @headers)
    if block_given?
      yield response
    else
      response
    end
  end
end
