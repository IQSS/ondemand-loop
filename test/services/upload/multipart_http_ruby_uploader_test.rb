require 'test_helper'

class Upload::MultipartHttpRubyUploaderTest < ActiveSupport::TestCase
  def setup
    @tmp_file = Tempfile.new('upload')
    @tmp_file.write('abc')
    @tmp_file.rewind
  end

  def teardown
    @tmp_file.close
    @tmp_file.unlink
  end

  test 'progress io reports bytes read' do
    progress = []
    io = Upload::MultipartHttpRubyUploader::ProgressIO.new(@tmp_file.path, chunk_size: 1) do |ctx|
      progress << ctx.dup
    end
    while io.read(1); end
    assert_equal 3, progress.last[:uploaded]
    assert_equal 3, progress.last[:total]
  end

  test 'upload streams file and succeeds' do
    response = stub(code: '200', body: 'ok')
    response.stubs(:is_a?).with(Net::HTTPSuccess).returns(true)
    http = Class.new {
      define_method(:request) do |req|
        while req.body_stream.read(1024); end
        response
      end
    }.new
    Net::HTTP.stubs(:start).yields(http).returns(response)

    uploader = Upload::MultipartHttpRubyUploader.new('https://ex.org/upload', @tmp_file.path)
    progress = []
    body = uploader.upload do |ctx|
      progress << ctx.dup
      false
    end

    assert progress.last[:uploaded] > 0
    assert_equal 'ok', body
  end
end
