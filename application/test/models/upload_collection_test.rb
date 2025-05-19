require 'test_helper'

class UploadCollectionTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    UploadCollection.stubs(:metadata_root_directory).returns(@tmp_dir)
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
    @upload_collection = UploadCollection.new(@valid_attributes)
    @expected_filename = File.join(Project.upload_collections_directory('456-789'), '123-321', 'metadata.yml')
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'should initialize with valid attributes' do
    assert_equal '123-321', @upload_collection.id
    assert_equal '456-789', @upload_collection.project_id
    assert_equal ConnectorType::DATAVERSE, @upload_collection.type
  end

  test 'should be valid' do
    assert @upload_collection.valid?
  end

  test 'should be invalid because of invalid values' do
    assert @upload_collection.valid?
    @upload_collection.id = nil
    refute @upload_collection.valid?
    assert_includes @upload_collection.errors[:id], "can't be blank"
  end

  test 'to_hash' do
    expected_hash = map_objects(@valid_attributes)
    assert_equal expected_hash, @upload_collection.to_hash
  end

  test 'to_json' do
    expected_json = map_objects(@valid_attributes).to_json
    assert_equal expected_json, @upload_collection.to_json
  end

  test 'to_yaml' do
    expected_yaml = map_objects(@valid_attributes).to_yaml
    assert_equal expected_yaml, @upload_collection.to_yaml
  end

  test 'save with valid attributes' do
    assert @upload_collection.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'save twice only creates one file' do
    files_directory = Pathname.new(Project.upload_collections_directory('456-789'))
    assert @upload_collection.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, files_directory.children.count
    assert @upload_collection.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, files_directory.children.count
  end

  test 'save stopped due to invalid attributes' do
    @upload_collection.id = nil
    refute @upload_collection.save
    refute File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'destroy removes the file from the filesystem' do
    assert @upload_collection.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'

    assert @upload_collection.destroy, 'Destroy did not return true'
    refute File.exist?(@expected_filename), 'File was not deleted from the file system'

    refute UploadCollection.find('456-789', '123-321'), 'Collection should not be found after destroy'
  end


  test 'find does not find the record if it was not saved' do
    refute UploadCollection.find('456-789', '123-321')
  end

  test 'find retrieves the record if it was saved' do
    assert @upload_collection.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert UploadCollection.find('456-789', '123-321')
  end

  test 'find retrieves the record with the same stored values' do
    assert @upload_collection.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    loaded_file = UploadCollection.find('456-789', '123-321')
    assert loaded_file
    assert_equal '123-321', loaded_file.id
    assert_equal '456-789', loaded_file.project_id
    assert_equal ConnectorType::DATAVERSE, loaded_file.type
  end

  test 'find retrieves the record only if both ids match' do
    assert @upload_collection.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert UploadCollection.find('456-789', '123-321')
    refute UploadCollection.find('456-780', '123-321')
    refute UploadCollection.find('456-789', '123-322')
  end

  test 'project upload collections methods returns empty list' do
    assert_empty @project.upload_collections
  end

  test 'project upload collections methods returns list with the collection' do
    assert @upload_collection.save
    assert_equal 1, @project.upload_collections.count
    collection = @project.upload_collections.first
    assert_instance_of UploadCollection, collection
    assert_equal @upload_collection.id, collection.id
    assert_equal @upload_collection.project_id, collection.project_id
  end

  def map_objects(hash)
    hash['type'] = hash['type'].to_s
    hash
  end
end