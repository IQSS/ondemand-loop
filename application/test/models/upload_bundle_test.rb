require 'test_helper'

class UploadBundleTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    UploadBundle.stubs(:metadata_root_directory).returns(@tmp_dir)
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    @valid_attributes = {
      'id' => '123-321', 'project_id' => '456-789',
      'remote_repo_url' => 'https://demo.repo.com/dataset',
      'type' => ConnectorType::DATAVERSE,
      'name' => 'foo',
      'creation_date' => nil,
      'metadata' => {
        'persistent_id' => '',
        'dataverse_url' => '',
        'api_key' => '',
      }
    }
    @project = Project.new id: '456-789', name: 'Test Project'
    @project.save
    @upload_bundle = UploadBundle.new(@valid_attributes)
    @expected_filename = File.join(Project.upload_bundles_directory('456-789'), '123-321', 'metadata.yml')
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'should initialize with valid attributes' do
    assert_equal '123-321', @upload_bundle.id
    assert_equal '456-789', @upload_bundle.project_id
    assert_equal ConnectorType::DATAVERSE, @upload_bundle.type
  end

  test 'should be valid' do
    assert @upload_bundle.valid?
  end

  test 'should be invalid because of invalid values' do
    assert @upload_bundle.valid?
    @upload_bundle.id = nil
    refute @upload_bundle.valid?
    assert_includes @upload_bundle.errors[:id], "can't be blank"
  end

  test 'to_h' do
    expected_hash = map_objects(@valid_attributes)
    assert_equal expected_hash, @upload_bundle.to_h
  end

  test 'to_json' do
    expected_json = map_objects(@valid_attributes).to_json
    assert_equal expected_json, @upload_bundle.to_json
  end

  test 'to_yaml' do
    expected_yaml = map_objects(@valid_attributes).to_yaml
    assert_equal expected_yaml, @upload_bundle.to_yaml
  end

  test 'save with valid attributes' do
    assert @upload_bundle.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'save twice only creates one file' do
    files_directory = Pathname.new(Project.upload_bundles_directory('456-789'))
    assert @upload_bundle.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, files_directory.children.count
    assert @upload_bundle.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, files_directory.children.count
  end

  test 'save stopped due to invalid attributes' do
    @upload_bundle.id = nil
    refute @upload_bundle.save
    refute File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'destroy removes the file from the filesystem' do
    assert @upload_bundle.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'

    assert @upload_bundle.destroy, 'Destroy did not return true'
    refute File.exist?(@expected_filename), 'File was not deleted from the file system'

    refute UploadBundle.find('456-789', '123-321'), 'Upload Bundle should not be found after destroy'
  end


  test 'find does not find the record if it was not saved' do
    refute UploadBundle.find('456-789', '123-321')
  end

  test 'find retrieves the record if it was saved' do
    assert @upload_bundle.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert UploadBundle.find('456-789', '123-321')
  end

  test 'find retrieves the record with the same stored values' do
    assert @upload_bundle.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    loaded_file = UploadBundle.find('456-789', '123-321')
    assert loaded_file
    assert_equal '123-321', loaded_file.id
    assert_equal '456-789', loaded_file.project_id
    assert_equal ConnectorType::DATAVERSE, loaded_file.type
  end

  test 'find retrieves the record only if both ids match' do
    assert @upload_bundle.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert UploadBundle.find('456-789', '123-321')
    refute UploadBundle.find('456-780', '123-321')
    refute UploadBundle.find('456-789', '123-322')
  end

  test 'project upload bundles methods returns empty list' do
    assert_empty @project.upload_bundles
  end

  test 'project upload bundles methods returns list with the collection' do
    assert @upload_bundle.save
    assert_equal 1, @project.upload_bundles.count
    upload_bundle = @project.upload_bundles.first
    assert_instance_of UploadBundle, upload_bundle
    assert_equal @upload_bundle.id, upload_bundle.id
    assert_equal @upload_bundle.project_id, upload_bundle.project_id
  end

  def map_objects(hash)
    hash['type'] = hash['type'].to_s
    hash
  end
end