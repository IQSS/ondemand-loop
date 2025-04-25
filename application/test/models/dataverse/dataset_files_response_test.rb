require "test_helper"

class Dataverse::DatasetFilesResponseTest < ActiveSupport::TestCase

  def setup
    valid_json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'valid_response.json'))
    @dataset_files = Dataverse::DatasetFilesResponse.new(valid_json)
  end

  def empty_json
    "{}"
  end

  def empty_string
    ""
  end

  test "valid json parses @dataset files response" do
    assert_instance_of Dataverse::DatasetFilesResponse, @dataset_files
    assert_equal "OK", @dataset_files.status
  end


  test "valid json parses @dataset files response files" do
    assert_equal 2, @dataset_files.data.size
    @dataset_files.data.each { |file| assert_instance_of Dataverse::DatasetFilesResponse::DatasetFile, file }

    file = @dataset_files.data.first
    assert_equal "screenshot.png", file.label
    refute file.restricted
    assert_instance_of Dataverse::DatasetFilesResponse::DatasetFile::DataFile, file.data_file

    data_file = file.data_file
    assert_equal 4, data_file.id
    assert_equal "screenshot.png", data_file.filename
    assert_equal "image/png", data_file.content_type
    assert_equal 272314, data_file.filesize
    assert_equal "13035cba04a51f54dd8101fe726cda5c", data_file.md5
    assert_equal "PNG Image", data_file.friendly_type
  end

  test "empty json for dataset files does not throw exception" do
    @invalid_dataset_files = Dataverse::DatasetFilesResponse.new(empty_json)
    assert_instance_of Dataverse::DatasetFilesResponse, @invalid_dataset_files
    assert_equal 0, @invalid_dataset_files.files.count
    files = @invalid_dataset_files.files_by_ids([86, 87, 88, 89, 90])
    assert_equal 0, files.size
  end

  test "empty string raises JSON::ParserError for dataset files" do
    assert_raises(JSON::ParserError) { Dataverse::DatasetFilesResponse.new(empty_string) }
  end

  test "find files matches one file in dataset files" do
    files = @dataset_files.files_by_ids([4])
    assert_equal 1, files.size
    assert_equal 4, files.first.data_file.id
    assert_equal "image/png", files.first.data_file.content_type
  end

  test "find files matches one file as string id in dataset files" do
    files = @dataset_files.files_by_ids(['4'])
    assert_equal 1, files.size
    assert_equal 4, files.first.data_file.id
    assert_equal "image/png", files.first.data_file.content_type
  end

  test "find files matches no files with wrong id in dataset files" do
    files = @dataset_files.files_by_ids([1])
    assert_equal 0, files.size
  end

  test "find files matches no files with empty array in dataset files" do
    files = @dataset_files.files_by_ids([])
    assert_equal 0, files.size
  end

  test "find files matches no files with nil in dataset files" do
    files = @dataset_files.files_by_ids(nil)
    assert_equal 0, files.size
  end

  test "find files matches no files with multiple array in dataset files" do
    files = @dataset_files.files_by_ids([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    assert_equal 2, files.size
    assert_equal 4, files.first.data_file.id
    assert_equal "image/png", files.first.data_file.content_type
  end

  test "files method in dataset files" do
    files = @dataset_files.files_by_ids([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    assert_equal files, @dataset_files.files
    assert_equal 2, files.size
  end

  test "dataset files incomplete with no data" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'incomplete_no_data.json'))
    @dataset_files_incomplete = Dataverse::DatasetFilesResponse.new(json)
    assert_instance_of Dataverse::DatasetFilesResponse, @dataset_files_incomplete
    assert_equal 0, @dataset_files_incomplete.files.count
    files = @dataset_files_incomplete.files_by_ids([86, 87, 88, 89, 90])
    assert_equal 0, files.size
  end

  test "dataset incomplete with no data_file in some files" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'incomplete_no_data_file.json'))
    @dataset_files_incomplete = Dataverse::DatasetFilesResponse.new(json)
    assert_instance_of Dataverse::DatasetFilesResponse, @dataset_files_incomplete
    assert_equal 2, @dataset_files_incomplete.files.count
    files = @dataset_files_incomplete.files_by_ids([4, 5])
    assert_equal 1, files.size
    file = @dataset_files_incomplete.files.first
    assert_equal "screenshot.png", file.label
    refute file.restricted
    assert_instance_of Dataverse::DatasetFilesResponse::DatasetFile::DataFile, file.data_file
    data_file = file.data_file
    assert_nil data_file.id
    assert_nil data_file.filename
    assert_nil data_file.publication_date
    assert_nil data_file.storage_identifier
    assert_nil data_file.content_type
    assert_nil data_file.filesize
    assert_nil data_file.md5
    assert_nil data_file.friendly_type
  end

end
