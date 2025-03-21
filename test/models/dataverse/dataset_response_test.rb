require "test_helper"

class Dataverse::DatasetResponseTest < ActiveSupport::TestCase
  def valid_json_body
    load_file_fixture(File.join('dataverse', 'dataset_response', 'valid_response.json'))
  end

  def empty_json
    "{}"
  end

  def empty_string
    ""
  end

  def incomplete_json_body
    load_file_fixture(File.join('dataverse', 'dataset_response', 'incomplete_response.json'))
  end

  test "valid json parses dataset response" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    assert_instance_of Dataverse::DatasetResponse, dataset
    assert_equal "OK", dataset.status
    assert_instance_of Dataverse::DatasetResponse::Data, dataset.data
  end

  test "valid json parses dataset response data" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    data = dataset.data
    assert_equal 6, data.id
    assert_equal "FK2/GCN7US", data.identifier
    assert_equal "https://doi.org/10.5072/FK2/GCN7US", data.persistent_url
    assert_equal "Root", data.publisher
    assert_equal "2025-01-23", data.publication_date
    assert_equal "dataset", data.dataset_type
  end

  test "valid json parses dataset response latest version" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    version = dataset.data.latest_version
    assert_instance_of Dataverse::DatasetResponse::Data::Version, version
    assert_equal 3, version.id
    assert_equal 1, version.version_number
    assert_equal "RELEASED", version.version_state
  end

  test "valid json parses dataset response license" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    license = dataset.data.latest_version.license
    assert_instance_of Dataverse::DatasetResponse::Data::Version::License, license
    assert_equal "CC0 1.0", license.name
    assert_equal "http://creativecommons.org/publicdomain/zero/1.0", license.uri
    assert_equal "https://licensebuttons.net/p/zero/1.0/88x31.png", license.icon_uri
  end

  test "valid json parses dataset response files" do
    dataset = Dataverse::DatasetResponse.new(valid_json_body)
    version = dataset.data.latest_version

    assert_equal 1, version.files.size
    version.files.each { |file| assert_instance_of Dataverse::DatasetResponse::Data::Version::DatasetFile, file }

    file = version.files.first
    assert_equal "screenshot.png", file.label
    refute file.restricted
    assert_instance_of Dataverse::DatasetResponse::Data::Version::DatasetFile::DataFile, file.data_file

    data_file = file.data_file
    assert_equal 7, data_file.id
    assert_equal "screenshot.png", data_file.filename
    assert_equal "image/png", data_file.content_type
    assert_equal 272314, data_file.filesize
    assert_equal "13035cba04a51f54dd8101fe726cda5c", data_file.md5
  end

  test "empty json raises error" do
    assert_raises(NoMethodError) { Dataverse::DatasetResponse.new(empty_json) }
  end

  test "empty string raises JSON::ParserError" do
    assert_raises(JSON::ParserError) { Dataverse::DatasetResponse.new(empty_string) }
  end

  test "incomplete json raises NoMethodError when accessing missing data" do
    assert_raises(NoMethodError) { Dataverse::DatasetResponse.new(incomplete_json_body) }
  end
end
