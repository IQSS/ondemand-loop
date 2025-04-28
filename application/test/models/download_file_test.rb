require 'test_helper'

# TODO: Review validation with David
class DownloadFileTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    DownloadFile.stubs(:metadata_root_directory).returns(@tmp_dir)
    DownloadCollection.stubs(:metadata_root_directory).returns(@tmp_dir)
    @valid_attributes = {
      'id' => '123-321', 'collection_id' => '456-789', 'type' => 'dataverse', 'filename' => 'test.png',
      'status' => FileStatus::READY, 'size' => 1024,
      'creation_date' => nil,
      'start_date' => nil,
      'end_date' => nil,
      'metadata' => {
        'id' => '',
        'filename' => '',
        'size' => '',
        'content_type' => '',
      }
    }
    @download_file = DownloadFile.new(@valid_attributes)
    @expected_filename = File.join(@tmp_dir, 'collections', '456-789', 'files', '123-321.yml')
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'should initialize with valid attributes' do
    assert_equal '123-321', @download_file.id
    assert_equal '456-789', @download_file.collection_id
    assert_equal 'dataverse', @download_file.type
    assert_equal 'test.png', @download_file.filename
    assert_equal FileStatus::READY, @download_file.status
    assert_equal 1024, @download_file.size
  end

  test 'should be valid' do
    assert @download_file.valid?
  end

  test 'should be invalid because of invalid values' do
    assert @download_file.valid?
    @download_file.type = 'invalid_type'
    refute @download_file.valid?
    assert_includes @download_file.errors[:type], 'invalid_type is not a valid type'
    @download_file.size = -1
    refute @download_file.valid?
    assert_includes @download_file.errors[:size], 'must be greater than or equal to 0'
  end

  test 'to_hash' do
    expected_hash = @valid_attributes.tap{|h| h['status'] = h['status'].to_s}
    assert_equal expected_hash, @download_file.to_hash
  end

  test 'to_json' do
    expected_json = @valid_attributes.tap{|h| h['status'] = h['status'].to_s}.to_json
    assert_equal expected_json, @download_file.to_json
  end

  test 'to_yaml' do
    expected_yaml = @valid_attributes.tap{|h| h['status'] = h['status'].to_s}.to_yaml
    assert_equal expected_yaml, @download_file.to_yaml
  end

  test 'save with valid attributes' do
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'save twice only creates one file' do
    directory = File.join(@tmp_dir, 'collections', '456-789')
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, Dir.glob(directory).reject { |f| f == 'metadata.yml' }.count
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert_equal 1, Dir.glob(directory).reject { |f| f == 'metadata.yml' }.count
  end

  test 'save stopped due to invalid attributes' do
    @download_file.type = 'invalid_type'
    refute @download_file.save
    refute File.exist?(@expected_filename), 'File was not created in the file system'
  end

  test 'find does not find the record if it was not saved' do
    refute DownloadFile.find('456-789', '123-321')
  end

  test 'find retrieves the record if it was saved' do
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert DownloadFile.find('456-789', '123-321')
  end

  test 'find retrieves the record with the same stored values' do
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    loaded_file = DownloadFile.find('456-789', '123-321')
    assert loaded_file
    assert_equal '123-321', loaded_file.id
    assert_equal '456-789', loaded_file.collection_id
    assert_equal 'dataverse', loaded_file.type
    assert_equal 'test.png', loaded_file.filename
    assert_equal FileStatus::READY, loaded_file.status
    assert_equal 1024, loaded_file.size
  end

  test 'find retrieves the record only if both ids match' do
    assert @download_file.save
    assert File.exist?(@expected_filename), 'File was not created in the file system'
    assert DownloadFile.find('456-789', '123-321')
    refute DownloadFile.find('456-780', '123-321')
    refute DownloadFile.find('456-789', '123-322')
  end

  test 'update' do
    collection = create_download_collection
    target = create_download_file(collection)
    target.update(status: FileStatus::CANCELLED)
    assert_equal FileStatus::CANCELLED, target.status
  end
end