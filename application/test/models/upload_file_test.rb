require 'test_helper'

class UploadFileTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    UploadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    UploadBatch.stubs(:metadata_root_directory).returns(@tmp_dir)
    @valid_attributes = {
      'id' => '123-321', 'project_id' => '456-789', 'upload_batch_id' => '111-222', 'type' => ConnectorType::DATAVERSE,
      'file_location' => 'path/to/file.jpg',
      'filename' => 'test.png',
      'status' => FileStatus::PENDING, 'size' => 1024,
      'creation_date' => nil,
      'start_date' => nil,
      'end_date' => nil
    }
    @batch_attributes = {
      'id' => '111-222', 'project_id' => '456-789', 'type' => ConnectorType::DATAVERSE,
      'creation_date' => nil,
      'metadata' => {
        'persistent_id' => '',
        'dataverse_url' => '',
        'api_key' => '',
      }
    }
    @project = Project.new id: '456-789', name: 'Test Project'
    @project.save
    @upload_batch = UploadBatch.new(@batch_attributes)
    @upload_batch.save
    @upload_file = UploadFile.new(@valid_attributes)
    @expected_filename = File.join(Project.upload_batches_directory('456-789'), '111-222', 'files', '123-321.yml')
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'should initialize with valid attributes' do
    assert_equal '123-321', @upload_file.id
    assert_equal '456-789', @upload_file.project_id
    assert_equal '111-222', @upload_file.upload_batch_id
    assert_equal 'test.png', @upload_file.filename
    assert_equal FileStatus::PENDING, @upload_file.status
    assert_equal 1024, @upload_file.size
  end

  test 'should be valid' do
    assert @upload_file.valid?
  end

  test 'should be invalid because of invalid values' do
    assert @upload_file.valid?
    @upload_file.size = -1
    refute @upload_file.valid?
    assert_includes @upload_file.errors[:size], 'must be greater than or equal to 0'
  end

  test 'should validate max file size' do
    assert @upload_file.valid?
    @upload_file.size = 2.gigabytes
    refute @upload_file.valid?
    assert_includes @upload_file.errors[:size], 'is too large (maximum allowed is 1 GB)'
  end

  test 'to_h' do
    expected_hash = map_objects(@valid_attributes)
    assert_equal expected_hash, @upload_file.to_h
  end

  test 'to_json' do
    expected_json = map_objects(@valid_attributes).to_json
    assert_equal expected_json, @upload_file.to_json
  end

  test 'to_yaml' do
    expected_yaml = map_objects(@valid_attributes).to_yaml
    assert_equal expected_yaml, @upload_file.to_yaml
  end

  test 'save with valid attributes' do
    assert @upload_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'save twice only creates one file' do
    files_directory = Pathname.new(File.join(Project.upload_batches_directory('456-789'), '111-222', 'files'))
    assert @upload_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, files_directory.children.count
    assert @upload_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, files_directory.children.count
  end

  test 'save stopped due to invalid attributes' do
    @upload_file.size = 'invalid_type'
    refute @upload_file.save
    refute File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'find does not find the record if it was not saved' do
    refute UploadFile.find('456-789', '111-222', '123-321')
  end

  test 'find retrieves the record if it was saved' do
    assert @upload_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert UploadFile.find('456-789', '111-222', '123-321')
  end

  test 'find retrieves the record with the same stored values' do
    assert @upload_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    loaded_file = UploadFile.find('456-789', '111-222', '123-321')
    assert loaded_file
    assert_equal '123-321', loaded_file.id
    assert_equal '456-789', loaded_file.project_id
    assert_equal ConnectorType::DATAVERSE, loaded_file.type
    assert_equal 'test.png', loaded_file.filename
    assert_equal FileStatus::PENDING, loaded_file.status
    assert_equal 1024, loaded_file.size
  end

  test 'find retrieves the record only if both ids match' do
    assert @upload_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert UploadFile.find('456-789', '111-222', '123-321')
    refute UploadFile.find('456-780', '111-222', '123-321')
    refute UploadFile.find('456-789', '111-222', '123-322')
    refute UploadFile.find('456-789', '111-223', '123-321')
  end

  test 'update' do
    project = create_project
    upload_batch = create_upload_batch(project)
    target = create_upload_file(project, upload_batch)
    target.update(status: FileStatus::CANCELLED)
    assert_equal FileStatus::CANCELLED, target.status
  end

  def map_objects(hash)
    hash['type'] = hash['type'].to_s
    hash['status'] = hash['status'].to_s
    hash
  end
end