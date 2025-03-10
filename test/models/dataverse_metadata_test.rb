require "test_helper"

class DataverseMetadataTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    @sample_uri = URI('https://example.com:443')
    @another_sample_uri = URI('https://another-example.com:443')
    DataverseMetadata.stubs(:metadata_root_directory).returns(@tmp_dir)
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test '#save and .find - saves a Dataverse Host to disk and retrieves it by id' do
    new_id = SecureRandom.uuid.to_s
    host = DataverseMetadata.new
    host.id = new_id
    host.hostname = 'example.com'
    host.port = 443
    host.scheme = 'https'
    host.save

    retrieved_host = DataverseMetadata.find(new_id)
    assert_not_nil retrieved_host
    assert_equal 'example.com', retrieved_host.hostname
    assert_equal 'https', retrieved_host.scheme
    assert_equal new_id, retrieved_host.id
    assert_equal 'https://example.com:443', retrieved_host.full_name
    assert File.exist?(DataverseMetadata.filename_by_id(host.id))
    assert_equal 1, Dir.glob(File.join(DataverseMetadata.metadata_directory, "*.yml")).count
    assert_equal 1, DataverseMetadata.all.count
  end

  test '#save and .find - saves a Dataverse Host and fails to find another' do
    new_id = SecureRandom.uuid.to_s
    host = DataverseMetadata.new
    host.id = new_id
    host.hostname = 'example.com'
    host.port = 443
    host.scheme = 'https'
    host.save

    retrieved_host = DataverseMetadata.find(SecureRandom.uuid.to_s)
    assert_nil retrieved_host
    assert File.exist?(DataverseMetadata.filename_by_id(host.id))
    assert_equal 1, Dir.glob(File.join(DataverseMetadata.metadata_directory, "*.yml")).count
    assert_equal 1, DataverseMetadata.all.count

  end

  test '.all - returns an empty array' do
    assert_empty DataverseMetadata.all
    assert_equal 0, Dir.glob(File.join(DataverseMetadata.metadata_directory, "*.yml")).count
  end

  test '.all - returns all saved hosts' do
    host1 = DataverseMetadata.new.tap do |h|
      h.id = SecureRandom.uuid.to_s
      h.hostname = 'host1.com'
      h.port = 80
      h.scheme = 'http'
    end
    host1.save

    host2 = DataverseMetadata.new.tap do |h|
      h.id = SecureRandom.uuid.to_s
      h.hostname = 'host2.com'
      h.port = 443
      h.scheme = 'https'
    end
    host2.save

    all_hosts = DataverseMetadata.all
    assert_equal 2, all_hosts.count
    full_names = all_hosts.map(&:full_name)
    assert_includes full_names, 'http://host1.com:80'
    assert_includes full_names, 'https://host2.com:443'
    assert_equal 2, Dir.glob(File.join(DataverseMetadata.metadata_directory, "*.yml")).count
  end

  test '.find_by_uri - finds a host by its URI' do
    host = DataverseMetadata.new.tap do |h|
      h.id = SecureRandom.uuid.to_s
      h.hostname = 'example.com'
      h.port = 443
      h.scheme = 'https'
    end
    host.save

    found_host = DataverseMetadata.find_by_uri(@sample_uri)
    assert_not_nil found_host
    assert_equal 'https://example.com:443', found_host.full_name
    assert_equal 1, Dir.glob(File.join(DataverseMetadata.metadata_directory, "*.yml")).count
  end

  test '.find_by_uri - does not find a host for another URI' do
    host = DataverseMetadata.new.tap do |h|
      h.id = SecureRandom.uuid.to_s
      h.hostname = 'example.com'
      h.port = 443
      h.scheme = 'https'
    end
    host.save

    found_host = DataverseMetadata.find_by_uri(@another_sample_uri)
    assert_nil found_host
    assert_equal 1, Dir.glob(File.join(DataverseMetadata.metadata_directory, "*.yml")).count
  end

  test '.find_or_initialize_by_uri - initializes a new host if none found' do
    new_host = DataverseMetadata.find_or_initialize_by_uri(@sample_uri)
    assert_not_nil new_host
    assert_equal 'https://example.com:443', new_host.full_name
    assert File.exist?(DataverseMetadata.filename_by_id(new_host.id))
    assert_equal 1, Dir.glob(File.join(DataverseMetadata.metadata_directory, "*.yml")).count
  end

  test '.find_or_initialize_by_uri - does not create duplicate hosts' do
    first_host = DataverseMetadata.find_or_initialize_by_uri(@sample_uri)
    second_host = DataverseMetadata.find_or_initialize_by_uri(@sample_uri)

    assert_not_nil first_host
    assert_not_nil second_host
    assert_equal first_host.full_name, second_host.full_name
    assert File.exist?(DataverseMetadata.filename_by_id(first_host.id))
    assert_equal 1, Dir.glob(File.join(DataverseMetadata.metadata_directory, "*.yml")).count
    assert_equal 1, DataverseMetadata.all.count
  end
end
