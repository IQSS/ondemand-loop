require "test_helper"

class DownloadCollectionTest < ActiveSupport::TestCase

  test "initialization should works" do
    target = DownloadCollection.new(id: 'ab12345', name: 'test_collection', download_dir: '/tmp/test_collection')
    assert_equal 'ab12345', target.id
    assert_equal 'test_collection', target.name
    assert_equal '/tmp/test_collection', target.download_dir
  end

  test "should be valid when all fields are populated" do
    target = create_valid_collection
    assert target.valid?
  end

  test "validations should fail due to blank value" do
    target = create_valid_collection
    assert target.valid?

    target.id = ''
    refute target.valid?
    assert_includes target.errors[:id], "can't be blank"

    target.name = ''
    refute target.valid?
    assert_includes target.errors[:name], "can't be blank"

    target.download_dir = ''
    refute target.valid?
    assert_includes target.errors[:download_dir], "can't be blank"
  end

  test "to_hash" do
    target = create_valid_collection
    expected_hash = {id: target.id, name: target.name, download_dir: target.download_dir}.stringify_keys
    assert_equal expected_hash, target.to_hash
  end

  test "to_json" do
    target = create_valid_collection
    expected_json = {id: target.id, name: target.name, download_dir: target.download_dir}.to_json
    assert_equal expected_json, target.to_json
  end

  test "to_yaml" do
    target = create_valid_collection
    expected_yaml = {id: target.id, name: target.name, download_dir: target.download_dir}.stringify_keys.to_yaml
    assert_equal expected_yaml, target.to_yaml
  end

  test "save with valid attributes" do
    in_temp_directory do |dir|
      target = create_valid_collection
      assert target.save
      expected_file = File.join(dir, 'collections', target.id, 'metadata.yml')
      assert File.exist?(expected_file), "DownloadCollection file was not created in the file system"
    end
  end

  test "save twice only creates one file" do
    in_temp_directory do |dir|
      target = create_valid_collection
      assert target.save
      expected_directory = File.join(dir, 'collections', target.id)
      expected_file = File.join(expected_directory, 'metadata.yml')
      assert File.exist?(expected_file), "DownloadCollection file was not created in the file system"
      assert_equal 1, Dir.glob(expected_directory).count

      assert target.save
      assert File.exist?(expected_file), "DownloadCollection file was not created in the file system"
      assert_equal 1, Dir.glob(expected_directory).count
    end
  end

  test "save stopped due to invalid attributes" do
    in_temp_directory do |dir|
      target = create_valid_collection
      target.id = ''
      refute target.save
      expected_file = File.join(dir, 'collections', target.id, 'metadata.yml')
      refute File.exist?(expected_file), "DownloadCollection file was created in the file system"
    end
  end

  test "find does not find the record if it was not saved" do
    refute DownloadCollection.find('456-789')
  end

  test "find retrieves the record if it was saved" do
    in_temp_directory do |dir|
      target = create_valid_collection
      target.save
      assert DownloadCollection.find(target.id)
    end
  end

  test "find retrieves the record with the same stored values" do
    in_temp_directory do |dir|
      target = create_valid_collection
      assert target.save
      saved_collection = DownloadCollection.find(target.id)
      assert saved_collection
      assert_equal 'ab12345', saved_collection.id
      assert_equal 'test_collection', saved_collection.name
      assert_equal '/tmp/test_collection', saved_collection.download_dir
    end
  end

  test "find retrieves the correct record on multiple records" do
    in_temp_directory do |dir|
      target1 = create_valid_collection(id: random_id, name: random_id)
      assert target1.save

      target2 = create_valid_collection(id: random_id, name: random_id)
      assert target2.save

      target3 = create_valid_collection(id: random_id, name: random_id)
      assert target3.save

      saved_collection = DownloadCollection.find(target2.id)
      assert saved_collection
      assert_equal target2.id, saved_collection.id
      assert_equal target2.name, saved_collection.name
      assert_equal target2.download_dir, saved_collection.download_dir
    end
  end

  test "all returns empty array if no records stored" do
    in_temp_directory do
      assert DownloadCollection.all.empty?
    end
  end

  test "all returns an array with the saved entry" do
    in_temp_directory do |dir|
      target = create_valid_collection
      assert target.save
      assert_equal 1, DownloadCollection.all.size
      saved_collection = DownloadCollection.all.first
      assert saved_collection
      assert_equal 'ab12345', saved_collection.id
      assert_equal 'test_collection', saved_collection.name
      assert_equal '/tmp/test_collection', saved_collection.download_dir
    end
  end

  test "all returns an array with multiple entries sorted by creation date descendant" do
    in_temp_directory do |dir|
      target1 = create_valid_collection(id: random_id, name: random_id)
      assert target1.save
      sleep(0.1)# SLEEP TO HAVE DIFFERENT CREATION DATE

      target2 = create_valid_collection(id: random_id, name: random_id)
      assert target2.save
      sleep(0.1)# SLEEP TO HAVE DIFFERENT CREATION DATE
      target3 = create_valid_collection(id: random_id, name: random_id)
      assert target3.save

      collections = DownloadCollection.all
      assert 3, collections.size
      assert_equal target3.id, collections[0].id
      assert_equal target2.id, collections[1].id
      assert_equal target1.id, collections[2].id
    end
  end

  test "files default value is empty array" do
    in_temp_directory do
      target = create_valid_collection
      assert target.save
      saved_collection = DownloadCollection.find(target.id)
      assert saved_collection.files.empty?
    end
  end

  test "files handle a single file" do
    in_temp_directory do |dir|
      target = create_valid_collection
      assert target.save
      file = create_download_file(target)
      assert file.save, file
      expected_file = File.join(dir, 'collections', target.id, 'files', "#{file.id}.yml")
      assert File.exist?(expected_file)

      saved_collection = DownloadCollection.find(target.id)
      collection_files = saved_collection.files
      assert_equal 1, collection_files.count
      saved_file = collection_files.first
      assert_equal file.id, saved_file.id
    end
  end

  test "files handle multiple files sorted by creation date ascendant" do
    in_temp_directory do
      target = create_valid_collection
      target.save
      file1 = create_download_file(target)
      assert file1.save
      sleep(0.1)# SLEEP TO HAVE DIFFERENT CREATION DATE
      file2 = create_download_file(target)
      assert file2.save
      sleep(0.1)# SLEEP TO HAVE DIFFERENT CREATION DATE
      file3 = create_download_file(target)
      assert file3.save

      saved_collection = DownloadCollection.find(target.id)
      collection_files = saved_collection.files
      assert_equal 3, collection_files.count
      assert_equal file1.id, collection_files[0].id
      assert_equal file2.id, collection_files[1].id
      assert_equal file3.id, collection_files[2].id
    end
  end

  private

  def create_valid_collection(id: 'ab12345', name: 'test_collection', download_dir: '/tmp/test_collection')
    DownloadCollection.new(id: id, name: name, download_dir: download_dir)
  end

  def in_temp_directory
    Dir.mktmpdir do |dir|
      DownloadCollection.stubs(:metadata_root_directory).returns(dir)
      DownloadFile.stubs(:metadata_root_directory).returns(dir)

      yield dir
    end
  end

end