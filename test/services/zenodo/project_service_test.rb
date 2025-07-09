require 'test_helper'

class Zenodo::ProjectServiceTest < ActiveSupport::TestCase
  include ZenodoHelper

  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    @service = Zenodo::ProjectService.new('https://zenodo.org', file_utils: Common::FileUtils.new)
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'initialize_project builds project with name' do
    p = @service.initialize_project
    assert p.valid?
    assert_kind_of Project, p
    assert_not_nil p.name
  end

  test 'initialize_download_files builds download records' do
    record_json = load_zenodo_fixture('record_response.json')
    record = Zenodo::RecordResponse.new(record_json)
    project = @service.initialize_project
    assert project.save
    files = @service.initialize_download_files(project, record, [record.files.first.id])
    assert_equal 1, files.length
    file = files.first
    assert_equal project.id, file.project_id
    assert_equal 'data/file1.txt', file.filename
    assert_equal ConnectorType::ZENODO, file.type
    assert_equal record.id, file.metadata[:record_id]
    assert_equal 'https://zenodo.org', file.metadata[:zenodo_url]
  end
end
