require 'test_helper'

class Upload::UploadFilesProviderTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @provider = Upload::UploadFilesProvider.new
  end

  test 'pending_files filters pending status' do
    project = upload_project(files: 1)
    Project.stubs(:all).returns([ project ])
    files = @provider.pending_files
    assert_equal 1, files.length
  end

  test 'processing_files filters uploading status' do
    project = upload_project(files: 1)
    project.upload_bundles.first.files.first.status = FileStatus::UPLOADING
    Project.stubs(:all).returns([ project ])
    files = @provider.processing_files
    assert_equal 1, files.length
  end

  test 'recent_files sorts by state and time' do
    project = upload_project(files: 2)
    files = project.upload_bundles.first.files
    files.first.status = FileStatus::UPLOADING
    files.first.creation_date = Time.now.strftime('%Y-%m-%dT%H:%M:%S')
    files.last.status = FileStatus::UPLOADING
    files.last.creation_date = (Time.now - 60).strftime('%Y-%m-%dT%H:%M:%S')
    Project.stubs(:all).returns([ project ])
    list = @provider.recent_files
    assert_equal [ files.first, files.last ], list.map(&:file)
  end
end
