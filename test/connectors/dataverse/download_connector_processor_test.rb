# frozen_string_literal: true

require 'test_helper'

class Dataverse::DownloadConnectorProcessorTest < ActiveSupport::TestCase

  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)

    @project = create_project
    @project.save

    @file = create_download_file(@project)
    @file.id = 'file-123'
    @file.filename = 'data.csv'
    @file.metadata = {
      id: '456',
      md5: Digest::MD5.hexdigest('test content'),
      dataverse_url: 'http://example.com',
      download_url: nil,
      temp_location: nil,
    }

    @download_path = @file.download_location
    @temp_path = @file.download_tmp_location

    File.write(@download_path, 'test content') # for MD5 match

    @processor = Dataverse::DownloadConnectorProcessor.new(@file)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test 'should return success response when download and md5 match' do
    repo_db = Repo::RepoDb.new(db_path: Tempfile.new('repo').path)
    ::Configuration.stubs(:repo_db).returns(repo_db)
    mock_downloader = mock('downloader')
    Download::BasicHttpRubyDownloader
      .expects(:new).with('http://example.com/api/access/datafile/456?format=original',
                          @download_path,
                          @temp_path,
                          headers: {})
      .returns(mock_downloader)

    mock_downloader.stubs(:partial_downloads).returns(false)
    mock_downloader.expects(:download).yields(nil)

    response = @processor.download
    assert_equal FileStatus::SUCCESS, response.status
    assert_match 'download completed', response.message
    assert true
  end

  test 'should return cancelled response if download is cancelled' do
    mock_downloader = mock('downloader')
    Download::BasicHttpRubyDownloader.stubs(:new).returns(mock_downloader)
    mock_downloader.stubs(:partial_downloads).returns(false)
    mock_downloader.expects(:download).yields(nil)

    @processor.instance_variable_set(:@cancelled, true)
    response = @processor.download

    assert_equal FileStatus::CANCELLED, response.status
    assert_match 'cancelled', response.message
  end

  test 'should return error response if md5 does not match' do
    File.write(@download_path, 'bad content') # Wrong checksum

    mock_downloader = mock('downloader')
    Download::BasicHttpRubyDownloader.stubs(:new).returns(mock_downloader)
    mock_downloader.stubs(:partial_downloads).returns(false)
    mock_downloader.expects(:download).yields(nil)

    response = @processor.download

    assert_equal FileStatus::ERROR, response.status
    assert_match 'md5 check failed', response.message
  end

  test 'should set cancelled true when process receives matching request' do
    request = Command::Request.new(command: 'download.cancel', body: {file_id: 'file-123'})
    result = @processor.process(request)

    assert_equal true, @processor.cancelled
    assert_equal 'cancellation requested', result[:message]
  end

  test 'should ignore request if file id does not match' do
    request = Command::Request.new(command: 'download.cancel', body: {file_id: 'other-id'})

    result = @processor.process(request)

    assert_nil result
    assert_equal false, @processor.cancelled
  end

  test 'should update file metadata with download url' do
    mock_downloader = mock('downloader')
    Download::BasicHttpRubyDownloader.stubs(:new).returns(mock_downloader)
    mock_downloader.stubs(:partial_downloads).returns(false)
    mock_downloader.stubs(:download).yields(nil)

    expected_url = 'http://example.com/api/access/datafile/456?format=original'

    @file.expects(:update).twice.with do |arg|
      metadata = arg[:metadata]
      metadata['download_url'] == expected_url
    end

    @processor.download
  end

  test 'keeps temp file and flags restart when download fails with range support' do
    repo_db = Repo::RepoDb.new(db_path: Tempfile.new('repo').path)
    ::Configuration.stubs(:repo_db).returns(repo_db)
    file = create_download_file(@project)
    file.id = 'file-x'
    file.filename = 'data2.csv'
    file.metadata = {
      id: '789',
      md5: Digest::MD5.hexdigest('content'),
      dataverse_url: 'http://example.com',
      download_url: nil,
      temp_location: nil,
      partial_downloads: nil,
    }
    file.stubs(:update) { |**args| file.metadata = args[:metadata]; true }
    processor = Dataverse::DownloadConnectorProcessor.new(file)

      download_location = file.download_location
      temp_location = file.download_tmp_location
      FileUtils.mkdir_p(File.dirname(temp_location))
      File.write(temp_location, 'partial')

    mock_downloader = mock('downloader')
    mock_downloader.stubs(:partial_downloads).returns(true)
    Download::BasicHttpRubyDownloader.stubs(:new).returns(mock_downloader)
    mock_downloader.expects(:download).raises(StandardError.new('boom'))

    result = processor.download
    assert_equal FileStatus::ERROR, result.status
    assert File.exist?(temp_location)
    assert processor.connector_metadata.partial_downloads
  end

  test 'removes temp file when download fails without range support' do
    file = create_download_file(@project)
    repo_db = Repo::RepoDb.new(db_path: Tempfile.new('repo').path)
    ::Configuration.stubs(:repo_db).returns(repo_db)
    file.id = 'file-y'
    file.filename = 'data3.csv'
    file.metadata = {
      id: '790',
      md5: Digest::MD5.hexdigest('content'),
      dataverse_url: 'http://example.com',
      download_url: nil,
      temp_location: nil,
      partial_downloads: nil,
    }
    file.stubs(:update) { |**args| file.metadata = args[:metadata]; true }
    processor = Dataverse::DownloadConnectorProcessor.new(file)

      download_location = file.download_location
      temp_location = file.download_tmp_location
      FileUtils.mkdir_p(File.dirname(temp_location))
      File.write(temp_location, 'partial')

    mock_downloader = mock('downloader')
    mock_downloader.stubs(:partial_downloads).returns(false)
    Download::BasicHttpRubyDownloader.stubs(:new).returns(mock_downloader)
    mock_downloader.expects(:download).raises(StandardError.new('boom'))

    result = processor.download
    assert_equal FileStatus::ERROR, result.status
    refute File.exist?(temp_location)
    refute processor.connector_metadata.partial_downloads
  end

  test 'includes api key header when available' do
    repo_db = Repo::RepoDb.new(db_path: Tempfile.new('repo').path)
    repo_db.set('http://example.com', type: ConnectorType::DATAVERSE, metadata: {auth_key: 'KEY'})
    ::Configuration.stubs(:repo_db).returns(repo_db)

      mock_downloader = mock('downloader')
      Download::BasicHttpRubyDownloader
        .expects(:new).with('http://example.com/api/access/datafile/456?format=original',
                            @download_path,
                            @temp_path,
                            headers: { Dataverse::ApiService::AUTH_HEADER => 'KEY' })
        .returns(mock_downloader)
      mock_downloader.stubs(:partial_downloads).returns(false)
      mock_downloader.stubs(:download).yields(nil)

    @processor.download
  end
end

