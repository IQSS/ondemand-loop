require "test_helper"

class Dataverse::DataverseMetadataTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    @sample_uri = URI('https://example.com:443')
    @another_sample_uri = URI('https://another-example.com:443')
    Dataverse::DataverseMetadata.stubs(:metadata_root_directory).returns(@tmp_dir)
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test '#save and .find - saves a Dataverse dataverse_metadata to disk and retrieves it by id' do
    new_id = SecureRandom.uuid.to_s
    dataverse_metadata = Dataverse::DataverseMetadata.new
    dataverse_metadata.id = new_id
    dataverse_metadata.hostname = 'example.com'
    dataverse_metadata.port = 443
    dataverse_metadata.scheme = 'https'
    dataverse_metadata.save

    retrieved_dataverse_metadata = Dataverse::DataverseMetadata.find(new_id)
    assert_not_nil retrieved_dataverse_metadata
    assert_equal 'example.com', retrieved_dataverse_metadata.hostname
    assert_equal 'https', retrieved_dataverse_metadata.scheme
    assert_equal new_id, retrieved_dataverse_metadata.id
    assert_equal 'https://example.com:443', retrieved_dataverse_metadata.full_hostname
    assert File.exist?(Dataverse::DataverseMetadata.filename_by_id(dataverse_metadata.id))
    assert_equal 1, Dir.glob(File.join(Dataverse::DataverseMetadata.metadata_directory, "*.yml")).count
    assert_equal 1, Dataverse::DataverseMetadata.all.count
  end

  test '#save and .find - saves a Dataverse dataverse_metadata and fails to find another' do
    new_id = SecureRandom.uuid.to_s
    dataverse_metadata = Dataverse::DataverseMetadata.new
    dataverse_metadata.id = new_id
    dataverse_metadata.hostname = 'example.com'
    dataverse_metadata.port = 443
    dataverse_metadata.scheme = 'https'
    dataverse_metadata.save

    retrieved_dataverse_metadata = Dataverse::DataverseMetadata.find(SecureRandom.uuid.to_s)
    assert_nil retrieved_dataverse_metadata
    assert File.exist?(Dataverse::DataverseMetadata.filename_by_id(dataverse_metadata.id))
    assert_equal 1, Dir.glob(File.join(Dataverse::DataverseMetadata.metadata_directory, "*.yml")).count
    assert_equal 1, Dataverse::DataverseMetadata.all.count

  end

  test '.all - returns an empty array' do
    assert_empty Dataverse::DataverseMetadata.all
    assert_equal 0, Dir.glob(File.join(Dataverse::DataverseMetadata.metadata_directory, "*.yml")).count
  end

  test '.all - returns all saved dataverse_metadatas' do
    dataverse_metadata1 = Dataverse::DataverseMetadata.new.tap do |h|
      h.id = SecureRandom.uuid.to_s
      h.hostname = 'dataverse_metadata1.com'
      h.port = 80
      h.scheme = 'http'
    end
    dataverse_metadata1.save

    dataverse_metadata2 = Dataverse::DataverseMetadata.new.tap do |h|
      h.id = SecureRandom.uuid.to_s
      h.hostname = 'dataverse_metadata2.com'
      h.port = 443
      h.scheme = 'https'
    end
    dataverse_metadata2.save

    all_dataverse_metadatas = Dataverse::DataverseMetadata.all
    assert_equal 2, all_dataverse_metadatas.count
    full_names = all_dataverse_metadatas.map(&:full_hostname)
    assert_includes full_names, 'http://dataverse_metadata1.com:80'
    assert_includes full_names, 'https://dataverse_metadata2.com:443'
    assert_equal 2, Dir.glob(File.join(Dataverse::DataverseMetadata.metadata_directory, "*.yml")).count
  end

  test '.find_by_uri - finds a dataverse_metadata by its URI' do
    dataverse_metadata = Dataverse::DataverseMetadata.new.tap do |h|
      h.id = SecureRandom.uuid.to_s
      h.hostname = 'example.com'
      h.port = 443
      h.scheme = 'https'
    end
    dataverse_metadata.save

    found_dataverse_metadata = Dataverse::DataverseMetadata.find_by_uri(@sample_uri)
    assert_not_nil found_dataverse_metadata
    assert_equal 'https://example.com:443', found_dataverse_metadata.full_hostname
    assert_equal 1, Dir.glob(File.join(Dataverse::DataverseMetadata.metadata_directory, "*.yml")).count
  end

  test '.find_by_uri - does not find a dataverse_metadata for another URI' do
    dataverse_metadata = Dataverse::DataverseMetadata.new.tap do |h|
      h.id = SecureRandom.uuid.to_s
      h.hostname = 'example.com'
      h.port = 443
      h.scheme = 'https'
    end
    dataverse_metadata.save

    found_dataverse_metadata = Dataverse::DataverseMetadata.find_by_uri(@another_sample_uri)
    assert_nil found_dataverse_metadata
    assert_equal 1, Dir.glob(File.join(Dataverse::DataverseMetadata.metadata_directory, "*.yml")).count
  end

  test '.find_or_initialize_by_uri - initializes a new dataverse_metadata if none found' do
    new_dataverse_metadata = Dataverse::DataverseMetadata.find_or_initialize_by_uri(@sample_uri)
    assert_not_nil new_dataverse_metadata
    assert_equal 'https://example.com:443', new_dataverse_metadata.full_hostname
    assert File.exist?(Dataverse::DataverseMetadata.filename_by_id(new_dataverse_metadata.id))
    assert_equal 1, Dir.glob(File.join(Dataverse::DataverseMetadata.metadata_directory, "*.yml")).count
  end

  test '.find_or_initialize_by_uri - does not create duplicate dataverse_metadatas' do
    first_dataverse_metadata = Dataverse::DataverseMetadata.find_or_initialize_by_uri(@sample_uri)
    second_dataverse_metadata = Dataverse::DataverseMetadata.find_or_initialize_by_uri(@sample_uri)

    assert_not_nil first_dataverse_metadata
    assert_not_nil second_dataverse_metadata
    assert_equal first_dataverse_metadata.full_hostname, second_dataverse_metadata.full_hostname
    assert File.exist?(Dataverse::DataverseMetadata.filename_by_id(first_dataverse_metadata.id))
    assert_equal 1, Dir.glob(File.join(Dataverse::DataverseMetadata.metadata_directory, "*.yml")).count
    assert_equal 1, Dataverse::DataverseMetadata.all.count
  end
end
