# frozen_string_literal: true

require 'test_helper'

class Download::BasicHttpRubyDownloadTest < ActiveSupport::TestCase

  test 'Should store the download URL in the expected location' do

    download_file = fixture_path('/downloads/basic_http/sample_utf8.txt')
    http_mock = HttpMock.new(
      file_path: download_file,
    )

    Dir.mktmpdir do |dir|
      download_location = File.join(dir, 'output.txt')
      temp_location = File.join(dir, 'output.txt.part')
      Net::HTTP.expects(:start).yields(http_mock)
      target = Download::BasicHttpRubyDownloader.new("https://doi.org/10.xxxx", download_location, temp_location)
      target.download

      assert File.exist?(download_location)
      refute File.exist?(temp_location)
      assert_files_content_equal(download_file, download_location)
    end
    
  end

end
