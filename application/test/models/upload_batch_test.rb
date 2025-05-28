require 'test_helper'

class UploadBatchTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    UploadBatch.stubs(:metadata_root_directory).returns(@tmp_dir)
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
    @upload_batch = UploadBatch.new(@valid_attributes)
    @expected_filename = File.join(Project.upload_batches_directory('456-789'), '123-321', 'metadata.yml')
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'should initialize with valid attributes' do
    assert_equal '123-321', @upload_batch.id
    assert_equal '456-789', @upload_batch.project_id
    assert_equal ConnectorType::DATAVERSE, @upload_batch.type
  end

  test 'should be valid' do
    assert @upload_batch.valid?
  end

  test 'should be invalid because of invalid values' do
    assert @upload_batch.valid?
    @upload_batch.id = nil
    refute @upload_batch.valid?
    assert_includes @upload_batch.errors[:id], "can't be blank"
  end

  test 'to_h' do
    expected_hash = map_objects(@valid_attributes)
    assert_equal expected_hash, @upload_batch.to_h
  end

  test 'to_json' do
    expected_json = map_objects(@valid_attributes).to_json
    assert_equal expected_json, @upload_batch.to_json
  end

  test 'to_yaml' do
    expected_yaml = map_objects(@valid_attributes).to_yaml
    assert_equal expected_yaml, @upload_batch.to_yaml
  end

  test 'save with valid attributes' do
    assert @upload_batch.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'save twice only creates one file' do
    files_directory = Pathname.new(Project.upload_batches_directory('456-789'))
    assert @upload_batch.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, files_directory.children.count
    assert @upload_batch.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, files_directory.children.count
  end

  test 'save stopped due to invalid attributes' do
    @upload_batch.id = nil
    refute @upload_batch.save
    refute File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'destroy removes the file from the filesystem' do
    assert @upload_batch.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'

    assert @upload_batch.destroy, 'Destroy did not return true'
    refute File.exist?(@expected_filename), 'File was not deleted from the file system'

    refute UploadBatch.find('456-789', '123-321'), 'Upload Batch should not be found after destroy'
  end


  test 'find does not find the record if it was not saved' do
    refute UploadBatch.find('456-789', '123-321')
  end

  test 'find retrieves the record if it was saved' do
    assert @upload_batch.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert UploadBatch.find('456-789', '123-321')
  end

  test 'find retrieves the record with the same stored values' do
    assert @upload_batch.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    loaded_file = UploadBatch.find('456-789', '123-321')
    assert loaded_file
    assert_equal '123-321', loaded_file.id
    assert_equal '456-789', loaded_file.project_id
    assert_equal ConnectorType::DATAVERSE, loaded_file.type
  end

  test 'find retrieves the record only if both ids match' do
    assert @upload_batch.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert UploadBatch.find('456-789', '123-321')
    refute UploadBatch.find('456-780', '123-321')
    refute UploadBatch.find('456-789', '123-322')
  end

  test 'project upload batches methods returns empty list' do
    assert_empty @project.upload_batches
  end

  test 'project upload batches methods returns list with the collection' do
    assert @upload_batch.save
    assert_equal 1, @project.upload_batches.count
    upload_batch = @project.upload_batches.first
    assert_instance_of UploadBatch, upload_batch
    assert_equal @upload_batch.id, upload_batch.id
    assert_equal @upload_batch.project_id, upload_batch.project_id
  end

  def map_objects(hash)
    hash['type'] = hash['type'].to_s
    hash
  end
end