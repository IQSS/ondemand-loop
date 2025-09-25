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
    assert_equal "/screenshot.png", file.full_filename
    refute file.restricted
    assert_instance_of Dataverse::DatasetFilesResponse::DatasetFile::DataFile, file.data_file

    data_file = file.data_file
    assert_equal 4, data_file.id
    assert_equal "screenshot.png", data_file.filename
    assert_equal "image/png", data_file.content_type
    assert_equal 272314, data_file.filesize
    assert_equal "13035cba04a51f54dd8101fe726cda5c", data_file.md5
    assert_equal "PNG Image", data_file.friendly_type
    assert_nil data_file.embargo
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

  test "dataset files with no pagination is supported" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'valid_response_no_pagination.json'))
    @target = Dataverse::DatasetFilesResponse.new(json, page: 1, per_page: 1, dataset_total: 2)
    assert_instance_of Dataverse::DatasetFilesResponse, @target
    assert_equal 1, @target.files.count
    assert_equal 2, @target.total_count
    assert_equal 2, @target.next_page
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

  test "embargo metadata is parsed" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'valid_response_embargo.json'))
    dataset_files = Dataverse::DatasetFilesResponse.new(json)
    file = dataset_files.files.first
    assert file.data_file.embargo
    assert_equal "2099-09-05", file.data_file.embargo.date_available
    assert_equal "Testing Loop", file.data_file.embargo.reason
  end

  test "public? respects restricted flag" do
    file_hash = { label: 'a', restricted: true, dataFile: { id: 1 } }
    file = Dataverse::DatasetFilesResponse::DatasetFile.new(file_hash)
    refute file.public?
  end

  test "public? returns false when embargo active" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'valid_response_embargo.json'))
    dataset_files = Dataverse::DatasetFilesResponse.new(json)
    file = dataset_files.files.first
    refute file.public?
  end

  # Simplified pagination logic tests

  test "totalCount in response takes precedence" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'valid_response.json'))
    target = Dataverse::DatasetFilesResponse.new(json, page: 1, per_page: 10, dataset_total: 999)

    assert_instance_of Dataverse::DatasetFilesResponse, target
    assert_equal 2, target.total_count  # From totalCount in JSON, ignores dataset_total
    assert_equal 2, target.files.count  # All data returned as-is
  end

  test "dataset_total used when no totalCount in response" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'pagination_supported_no_total_count.json'))
    target = Dataverse::DatasetFilesResponse.new(json, page: 1, per_page: 2, dataset_total: 5)

    assert_instance_of Dataverse::DatasetFilesResponse, target
    assert_equal 5, target.total_count   # From dataset_total parameter
    assert_equal 2, target.files.count   # All data returned as-is (server-side pagination)
  end

  test "manual pagination when all_data.size equals total_count" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'no_pagination_all_data.json'))
    target = Dataverse::DatasetFilesResponse.new(json, page: 2, per_page: 2, dataset_total: 3)

    assert_instance_of Dataverse::DatasetFilesResponse, target
    assert_equal 3, target.total_count   # From dataset_total parameter
    assert_equal 1, target.files.count   # Manual pagination: page 2 with per_page 2 = 1 file
    assert_equal 22, target.files.first.data_file.id  # Third file (offset 2)
  end

  test "fallback to all_data.size when no other total available" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'fallback_scenario.json'))
    target = Dataverse::DatasetFilesResponse.new(json, page: 1, per_page: 10)

    assert_instance_of Dataverse::DatasetFilesResponse, target
    assert_equal 1, target.total_count   # From all_data.size
    assert_equal 1, target.files.count   # All data returned as-is
  end

  test "manual pagination works correctly across multiple pages" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'no_pagination_all_data.json'))

    # Page 1, per_page 2 - should return first 2 files
    target_page1 = Dataverse::DatasetFilesResponse.new(json, page: 1, per_page: 2, dataset_total: 3)
    assert_equal 2, target_page1.files.count
    assert_equal [20, 21], target_page1.files.map { |f| f.data_file.id }

    # Page 2, per_page 2 - should return last 1 file
    target_page2 = Dataverse::DatasetFilesResponse.new(json, page: 2, per_page: 2, dataset_total: 3)
    assert_equal 1, target_page2.files.count
    assert_equal 22, target_page2.files.first.data_file.id
  end

  test "manual pagination returns empty array when page beyond data" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'no_pagination_all_data.json'))
    target = Dataverse::DatasetFilesResponse.new(json, page: 5, per_page: 2, dataset_total: 3)

    assert_equal 3, target.total_count
    assert_equal 0, target.files.count   # No files on page 5
  end

  test "backward compatibility - no dataset_total provided" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'valid_response_no_pagination.json'))
    target = Dataverse::DatasetFilesResponse.new(json, page: 1, per_page: 1)

    # Should fall back to all_data.size since no dataset_total provided
    assert_instance_of Dataverse::DatasetFilesResponse, target
    assert_equal 2, target.total_count   # all_data.size
    assert_equal 1, target.files.count   # Manual pagination applied: all_data.size (2) == total_count (2)
  end

  test "server-side pagination detected when all_data.size is different from total_count" do
    json = load_file_fixture(File.join('dataverse', 'dataset_files_response', 'pagination_supported_no_total_count.json'))
    target = Dataverse::DatasetFilesResponse.new(json, page: 1, per_page: 2, dataset_total: 10)

    # all_data.size (2) != total_count (10), so server is handling pagination
    assert_equal 10, target.total_count
    assert_equal 2, target.files.count   # Return all data from server as-is
  end

end
