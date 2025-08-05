# frozen_string_literal: true

require 'test_helper'

class Zenodo::DownloadConnectorProcessorTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @project.save
    @file = create_download_file(@project)
    @file.metadata = { zenodo_url: 'https://zenodo.org', download_url: 'https://zenodo.org/file.txt' }
    @file.stubs(:update)
    Project.stubs(:find).with(@project.id).returns(@project)
    @processor = Zenodo::DownloadConnectorProcessor.new(@file)
  end

  test 'successful download' do
    Download::BasicHttpRubyDownloader.any_instance.stubs(:download).yields(nil)
    FileUtils.stubs(:mkdir_p)
    result = @processor.download
    assert_equal FileStatus::SUCCESS, result.status
  end

  test 'cancelled download' do
    Download::BasicHttpRubyDownloader.any_instance.stubs(:download).yields(nil)
    FileUtils.stubs(:mkdir_p)
    @processor.instance_variable_set(:@cancelled, true)
    result = @processor.download
    assert_equal FileStatus::CANCELLED, result.status
  end

  test 'process cancellation request' do
    req = OpenStruct.new(body: OpenStruct.new(file_id: @file.id))
    res = @processor.process(req)
    assert_equal true, @processor.cancelled
    assert_equal 'cancellation requested', res[:message]
  end

  test 'includes api key header when available' do
    repo_info = OpenStruct.new(metadata: OpenStruct.new(auth_key: 'KEY'))
    RepoRegistry.repo_db.stubs(:get).with('https://zenodo.org').returns(repo_info)
    FileUtils.stubs(:mkdir_p)

    download_location = @file.download_location
    temp_location = "#{download_location}.part"
    mock_downloader = mock('downloader')
    Download::BasicHttpRubyDownloader
      .expects(:new)
      .with('https://zenodo.org/file.txt', download_location, temp_location,
            headers: { Zenodo::ApiService::AUTH_HEADER => 'Bearer KEY' })
      .returns(mock_downloader)
    mock_downloader.stubs(:download).yields(nil)

    @processor.download
  end
end
