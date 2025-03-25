require "test_helper"

class DownloadCollectionTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    DownloadCollection.stubs(:metadata_root_directory).returns(@tmp_dir)
    DownloadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
    Dataverse::DataverseMetadata.stubs(:metadata_root_directory).returns(@tmp_dir)
    @valid_attributes = {
      'id' => '456-789', 'type' => 'dataverse', 'metadata_id' => '123-456',
      'name' => 'Dataverse dataset selection from doi:10.5072/FK2/GCN7US'
    }
    @download_collection = DownloadCollection.new(@valid_attributes)
    @test_filename = File.join(@tmp_dir, 'downloads', '456-789', 'metadata.yml')
    @valid_attributes2 = {
      'id' => '111-111', 'type' => 'dataverse', 'metadata_id' => '123-456',
      'name' => 'Dataverse dataset selection from doi:10.5072/FK2/GCN7US'
    }
    @download_collection2 = DownloadCollection.new(@valid_attributes2)
    @test_filename2 = File.join(@tmp_dir, 'downloads', '111-111', 'metadata.yml')
    @valid_attributes3 = {
      'id' => '222-222', 'type' => 'dataverse', 'metadata_id' => '123-456',
      'name' => 'Dataverse dataset selection from doi:10.5072/FK2/GCN7US'
    }
    @download_collection3 = DownloadCollection.new(@valid_attributes3)
    @test_filename3 = File.join(@tmp_dir, 'downloads', '222-222', 'metadata.yml')
    @file_attributes = {
      'id' => '123-321', 'collection_id' => '456-789', 'type' => 'dataverse',
      'metadata_id' => '123-456', 'external_id' => '789', 'filename' => 'test.png',
      'status' => 'new', 'size' => 1024, 'checksum' => 'abc123', 'content_type' => 'image/png'
    }
    @download_file = DownloadFile.new(@file_attributes)
    @file_filename = File.join(@tmp_dir, 'downloads', '456-789', 'files', '123-321.yml')

    @file_attributes2 = {
      'id' => '111-123', 'collection_id' => '456-789', 'type' => 'dataverse',
      'metadata_id' => '123-456', 'external_id' => '790', 'filename' => 'test.png',
      'status' => 'new', 'size' => 1024, 'checksum' => 'abc123', 'content_type' => 'image/png'
    }
    @download_file2 = DownloadFile.new(@file_attributes2)
    @file_filename2 = File.join(@tmp_dir, 'downloads', '456-789', 'files', '111-123.yml')

    @file_attributes3 = {
      'id' => '123-456', 'collection_id' => '111-111', 'type' => 'dataverse',
      'metadata_id' => '123-456', 'external_id' => '791', 'filename' => 'test.png',
      'status' => 'new', 'size' => 1024, 'checksum' => 'abc123', 'content_type' => 'image/png'
    }
    @download_file3 = DownloadFile.new(@file_attributes3)
    @file_filename3 = File.join(@tmp_dir, 'downloads', '111-111', 'files', '123-456.yml')
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test "initialization should works" do
    assert_equal '456-789', @download_collection.id
    assert_equal 'dataverse', @download_collection.type
    assert_equal '123-456', @download_collection.metadata_id
    assert_equal 'Dataverse dataset selection from doi:10.5072/FK2/GCN7US', @download_collection.name
  end

  test "should be valid" do
    assert @download_collection.valid?
  end

  test "validations should fail due to invalid values" do
    assert @download_collection.valid?
    @download_collection.type = 'invalid_type'
    refute @download_collection.valid?
    assert_includes @download_collection.errors[:type], 'is not included in the list'
  end

  test "validations should fail due to blank value" do
    assert @download_collection.valid?
    @download_collection.id = ''
    refute @download_collection.valid?
    assert_includes @download_collection.errors[:id], "can't be blank"
    @download_collection.metadata_id = ''
    refute @download_collection.valid?
    assert_includes @download_collection.errors[:metadata_id], "can't be blank"
    @download_collection.type = ''
    refute @download_collection.valid?
    assert_includes @download_collection.errors[:type], "can't be blank"
  end

  test "to_hash" do
    expected_hash = @valid_attributes
    assert_equal expected_hash, @download_collection.to_hash
  end

  test "to_json" do
    expected_json = @valid_attributes.to_json
    assert_equal expected_json, @download_collection.to_json
  end

  test "to_yaml" do
    expected_yaml = @valid_attributes.to_yaml
    assert_equal expected_yaml, @download_collection.to_yaml
  end

  test "save with valid attributes" do
    assert @download_collection.save
    assert File.exist?(@test_filename), "File was not created in the file system"
  end

  test "save twice only creates one file" do
    directory = File.join(@tmp_dir, 'downloads', '456-789')
    assert @download_collection.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    assert_equal 1, Dir.glob(directory).count
    assert @download_collection.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    assert_equal 1, Dir.glob(directory).count
  end

  test "save stopped due to invalid attributes" do
    @download_collection.type = 'invalid_type'
    refute @download_collection.save
    refute File.exist?(@test_filename), "File was not created in the file system"
  end

  test "find does not find the record if it was not saved" do
    refute DownloadCollection.find('456-789')
  end

  test "find retrieves the record if it was saved" do
    assert @download_collection.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    assert DownloadCollection.find('456-789')
  end

  test "find retrieves the record with the same stored values" do
    assert @download_collection.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    loaded_collection = DownloadCollection.find('456-789')
    assert loaded_collection
    assert_equal '456-789', loaded_collection.id
    assert_equal 'dataverse', loaded_collection.type
    assert_equal '123-456', loaded_collection.metadata_id
    assert_equal 'Dataverse dataset selection from doi:10.5072/FK2/GCN7US', loaded_collection.name
  end

  test "find retrieves the correct record on multiple records" do
    assert @download_collection.save
    assert @download_collection2.save
    assert @download_collection3.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    loaded_collection = DownloadCollection.find('456-789')
    assert loaded_collection
    assert_equal '456-789', loaded_collection.id
    assert_equal 'dataverse', loaded_collection.type
    assert_equal '123-456', loaded_collection.metadata_id
    assert_equal 'Dataverse dataset selection from doi:10.5072/FK2/GCN7US', loaded_collection.name
  end

  test "find retrieves the record only if id matches" do
    assert @download_collection.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    assert DownloadCollection.find('456-789')
    refute DownloadCollection.find('456-780')
  end

  test "all returns empty array if no records stored" do
    assert DownloadCollection.all.empty?
  end

  test "all returns an array with one entry if there is one stored record" do
    assert @download_collection.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    assert DownloadCollection.find('456-789')
    assert_equal 1, DownloadCollection.all.count
  end

  test "all returns an array with the saved entry" do
    assert @download_collection.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    found_collection = DownloadCollection.find('456-789')
    first_collection = DownloadCollection.all.first
    assert_equal found_collection.id, first_collection.id
    assert_equal found_collection.metadata_id, first_collection.metadata_id
    assert_equal found_collection.type, first_collection.type
    assert_equal found_collection.name, first_collection.name
  end

  test "all returns an array with multiple entries sorted by newest first" do
    assert @download_collection.save
    assert @download_collection2.save
    assert @download_collection3.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    assert File.exist?(@test_filename2), "File was not created in the file system"
    assert File.exist?(@test_filename3), "File was not created in the file system"
    assert DownloadCollection.find('456-789')
    assert DownloadCollection.find('111-111')
    assert DownloadCollection.find('222-222')
    assert_equal 3, DownloadCollection.all.count
    first_collection = DownloadCollection.all.first
    last_collection = DownloadCollection.all.last
    assert_equal @download_collection3.id, first_collection.id
    assert_equal @download_collection3.metadata_id, first_collection.metadata_id
    assert_equal @download_collection3.type, first_collection.type
    assert_equal @download_collection.id, last_collection.id
    assert_equal @download_collection.metadata_id, last_collection.metadata_id
    assert_equal @download_collection.type, last_collection.type
    assert_equal @download_collection.name, last_collection.name
  end

  test "an new download collection has no files" do
    assert @download_collection.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    loaded_collection = DownloadCollection.find('456-789')
    assert loaded_collection
    assert loaded_collection.files.empty?
  end

  test "a download collection has one file" do
    assert @download_collection.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    assert @download_file.save
    assert File.exist?(@file_filename), "File was not created in the file system"
    loaded_collection = DownloadCollection.find('456-789')
    assert loaded_collection
    assert_equal 1, loaded_collection.files.count
    loaded_file = DownloadFile.find("456-789", "123-321")
    assert loaded_file
    first_file = loaded_collection.files.first
    assert_equal '123-321', first_file.id
    assert_equal '456-789', first_file.collection_id
    assert_equal 'dataverse', first_file.type
    assert_equal '123-456', first_file.metadata_id
    assert_equal '789', first_file.external_id
    assert_equal 'test.png', first_file.filename
    assert_equal 'new', first_file.status
    assert_equal 1024, first_file.size
    assert_equal 'abc123', first_file.checksum
  end

  test "download collection has multiple files listed in order" do
    assert @download_collection.save
    assert @download_collection2.save
    assert @download_collection3.save
    assert @download_file.save
    assert @download_file2.save
    assert @download_file3.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    assert File.exist?(@test_filename2), "File was not created in the file system"
    assert File.exist?(@test_filename3), "File was not created in the file system"
    assert_equal 3, DownloadCollection.all.count
    assert_equal 2, @download_collection.files.count
    assert_equal "123-321", @download_collection.files.first.id
    assert_equal "111-123", @download_collection.files.last.id
    assert_equal 1, @download_collection2.files.count
    assert_equal "123-456", @download_collection2.files.first.id
    assert_equal 0, @download_collection3.files.count
  end

  test "new from dataverse" do
    dataverse_metadata = Dataverse::DataverseMetadata.find_or_initialize_by_uri(URI.parse("http://localhost:3000"))
    assert dataverse_metadata
    collection = DownloadCollection.new_from_dataverse(dataverse_metadata)
    assert_equal "dataverse", collection.type
    assert_equal dataverse_metadata.id, collection.metadata_id
    assert collection.id
    collection.name = 'new name'
    assert collection.save
  end
end