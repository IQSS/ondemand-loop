# frozen_string_literal: true

require 'test_helper'

class Dataverse::ProjectServiceTest < ActiveSupport::TestCase

  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    @sample_uri = URI('https://example.com:443')
    @service = Dataverse::ProjectService.new(@sample_uri.to_s)
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'the class is initialized' do
    assert @service.kind_of?(Dataverse::ProjectService)
  end

  test 'initialize project' do
    project = @service.initialize_project
    assert project.valid?
    assert project.kind_of?(Project)
    assert_not_nil project.name
  end

  test 'initialize download files' do
    valid_json = load_file_fixture(File.join('dataverse', 'dataset_version_response', 'valid_response.json'))
    dataset = Dataverse::DatasetVersionResponse.new(valid_json)
    valid_json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'valid_response.json'))
    files_page = Dataverse::DatasetFilesResponse.new(valid_json)
    project = @service.initialize_project
    assert project.save
    download_files = @service.initialize_download_files(project, dataset.data.dataset_persistent_id, dataset, files_page, [4])
    assert download_files.kind_of?(Array)
    assert_equal 1, download_files.count
    assert download_files[0].kind_of?(DownloadFile)
    assert download_files[0].valid?

    assert_equal project.id, download_files[0].project_id
    assert_equal FileStatus::PENDING, download_files[0].status
    assert_equal ConnectorType::DATAVERSE, download_files[0].type
    assert_equal 272314, download_files[0].size
    assert_equal '/screenshot.png', download_files[0].filename

    assert_equal '4', download_files[0].metadata[:id]
    assert_equal 'https://example.com', download_files[0].metadata[:dataverse_url]
    assert_equal '2.0', download_files[0].metadata[:version]
    assert_equal 'local://1946f5acedb-fdf849a8d0f3', download_files[0].metadata[:storage]
    assert_equal '13035cba04a51f54dd8101fe726cda5c', download_files[0].metadata[:md5]
    assert_equal 'image/png', download_files[0].metadata[:content_type]
    assert_nil download_files[0].metadata[:download_url]
    assert_nil download_files[0].metadata[:download_location]
    assert_nil download_files[0].metadata[:temp_location]
  end
end