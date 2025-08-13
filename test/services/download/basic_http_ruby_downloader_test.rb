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
      target = Download::BasicHttpRubyDownloader.new("https://doi.org/10.xxxx", download_location, temp_location, headers: {})
      target.download

      assert File.exist?(download_location)
      refute File.exist?(temp_location)
      assert_files_content_equal(download_file, download_location)
    end
    
  end

  test 'resumes download from existing temp file' do
    download_file = fixture_path('/downloads/basic_http/sample_utf8.txt')
    http_mock = HttpMock.new(file_path: download_file)

    Dir.mktmpdir do |dir|
      download_location = File.join(dir, 'output.txt')
      temp_location = File.join(dir, 'output.txt.part')
      original = File.read(download_file)
      File.open(temp_location, 'wb') { |f| f.write(original[0, 5]) }

      Net::HTTP.expects(:start).yields(http_mock)
      target = Download::BasicHttpRubyDownloader.new('http://example', download_location, temp_location, headers: {})
      target.download

      assert File.exist?(download_location)
      assert target.partial_downloads
      assert_files_content_equal(download_file, download_location)
    end
  end

  test 'server without range support restarts download and marks partial_downloads false' do
    download_file = fixture_path('/downloads/basic_http/sample_utf8.txt')
    http_mock = HttpMock.new(file_path: download_file, support_range: false)

    Dir.mktmpdir do |dir|
      download_location = File.join(dir, 'output.txt')
      temp_location = File.join(dir, 'output.txt.part')
      original = File.read(download_file)
      File.open(temp_location, 'wb') { |f| f.write(original[0, 5]) }

      Net::HTTP.expects(:start).yields(http_mock)
      target = Download::BasicHttpRubyDownloader.new('http://example', download_location, temp_location, headers: {})
      target.download

      assert File.exist?(download_location)
      refute target.partial_downloads
      assert_files_content_equal(download_file, download_location)
    end
  end

  test 'follows redirects' do
    file = fixture_path('/downloads/basic_http/sample_utf8.txt')
    first = HttpMock.new(file_path: file, status_code:302, headers:{'location'=>'/next'})
    second = HttpMock.new(file_path: file)
    Net::HTTP.stubs(:start).yields(first).then.yields(second)
    Dir.mktmpdir do |dir|
      dl = File.join(dir, 'o.txt')
      tmp = File.join(dir, 'o.txt.part')
      target = Download::BasicHttpRubyDownloader.new('http://example', dl, tmp, headers: {})
      target.download
      assert File.exist?(dl)
    end
  end

  test 'download can be cancelled' do
    file = fixture_path('/downloads/basic_http/sample_utf8.txt')
    mock_http = HttpMock.new(file_path: file)
    Net::HTTP.expects(:start).yields(mock_http)
    Dir.mktmpdir do |dir|
      dl = File.join(dir, 'o.txt')
      tmp = File.join(dir, 'o.part')
      target = Download::BasicHttpRubyDownloader.new('http://e', dl, tmp, headers: {})
      target.download do |_|
        true
      end
      refute File.exist?(dl)
      assert File.exist?(tmp)
    end
  end

end
