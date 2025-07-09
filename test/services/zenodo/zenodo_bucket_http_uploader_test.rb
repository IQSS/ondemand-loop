require 'test_helper'

class Zenodo::ZenodoBucketHttpUploaderTest < ActiveSupport::TestCase
  include FileFixtureHelper

  class PutHttpMock < HttpMock
    attr_reader :received_length

    def request(req)
      @received_length = req.body_stream.read&.size || 0
      HttpResponseMock.new(@file_path, @status_code, @headers)
    end
  end

  test 'upload sends file to bucket' do
    file = fixture_path('downloads/basic_http/sample_utf8.txt')
    http = PutHttpMock.new(file_path: file)
    Net::HTTP.expects(:start).yields(http)

    uploader = Zenodo::ZenodoBucketHttpUploader.new('https://zenodo.org/bucket/file', file)
    uploader.upload

    assert_equal File.size(file), http.received_length
  end

  test 'upload raises on failure' do
    file = fixture_path('downloads/basic_http/sample_utf8.txt')
    http = PutHttpMock.new(file_path: file, status_code: 500)
    Net::HTTP.expects(:start).yields(http)
    uploader = Zenodo::ZenodoBucketHttpUploader.new('https://zenodo.org/bucket/file', file)
    assert_raises(RuntimeError) { uploader.upload }
  end
end
