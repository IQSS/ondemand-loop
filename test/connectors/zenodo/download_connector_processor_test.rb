require 'test_helper'

class Zenodo::DownloadConnectorProcessorTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @project.save
    @file = create_download_file(@project)
    @file.metadata = { download_url: 'http://example.com/file.txt' }
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
end
