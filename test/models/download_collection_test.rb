require "test_helper"

class DownloadCollectionTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    DownloadCollection.stubs(:metadata_root_directory).returns(@tmp_dir)
    DownloadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
    @valid_attributes = {
      'id' => '456-789', 'kind' => 'dataverse', 'metadata_id' => '123-456'
    }
    @download_collection = DownloadCollection.new(@valid_attributes)
    @test_filename = File.join(@tmp_dir, 'downloads', '456-789', 'metadata.yml')
    @valid_attributes2 = {
      'id' => '111-111', 'kind' => 'dataverse', 'metadata_id' => '123-456'
    }
    @download_collection2 = DownloadCollection.new(@valid_attributes2)
    @test_filename2 = File.join(@tmp_dir, 'downloads', '111-111', 'metadata.yml')
    @valid_attributes3 = {
      'id' => '222-222', 'kind' => 'dataverse', 'metadata_id' => '123-456'
    }
    @download_collection3 = DownloadCollection.new(@valid_attributes3)
    @test_filename3 = File.join(@tmp_dir, 'downloads', '222-222', 'metadata.yml')
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test "initialization should works" do
    assert_equal '456-789', @download_collection.id
    assert_equal 'dataverse', @download_collection.kind
    assert_equal '123-456', @download_collection.metadata_id
  end

  test "should be valid" do
    assert @download_collection.valid?
  end

  test "validations should fail due to invalid values" do
    assert @download_collection.valid?
    @download_collection.kind = 'invalid_kind'
    refute @download_collection.valid?
    assert_includes @download_collection.errors[:kind], 'is not included in the list'
  end

  test "validations should fail due to blank value" do
    assert @download_collection.valid?
    @download_collection.id = ''
    refute @download_collection.valid?
    assert_includes @download_collection.errors[:id], "can't be blank"
    @download_collection.metadata_id = ''
    refute @download_collection.valid?
    assert_includes @download_collection.errors[:metadata_id], "can't be blank"
    @download_collection.kind = ''
    refute @download_collection.valid?
    assert_includes @download_collection.errors[:kind], "can't be blank"
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
    @download_collection.kind = 'invalid_kind'
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
    assert_equal 'dataverse', loaded_collection.kind
    assert_equal '123-456', loaded_collection.metadata_id
  end

  test "find retrieves the correct record on multiple records" do
    assert @download_collection.save
    assert @download_collection2.save
    assert @download_collection3.save
    assert File.exist?(@test_filename), "File was not created in the file system"
    loaded_collection = DownloadCollection.find('456-789')
    assert loaded_collection
    assert_equal '456-789', loaded_collection.id
    assert_equal 'dataverse', loaded_collection.kind
    assert_equal '123-456', loaded_collection.metadata_id
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
    assert_equal found_collection.kind, first_collection.kind
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
    assert_equal @download_collection3.kind, first_collection.kind
    assert_equal @download_collection.id, last_collection.id
    assert_equal @download_collection.metadata_id, last_collection.metadata_id
    assert_equal @download_collection.kind, last_collection.kind
  end
end