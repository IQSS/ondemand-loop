require "test_helper"

class Dataverse::DatasetsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    @sample_uri = URI('https://example.com:443')
    @another_sample_uri = URI('https://another-example.com:443')
    Dataverse::DataverseMetadata.stubs(:metadata_root_directory).returns(@tmp_dir)
    @new_id = SecureRandom.uuid.to_s
    dataverse_metadata = Dataverse::DataverseMetadata.new
    dataverse_metadata.id = @new_id
    dataverse_metadata.hostname = 'example.com'
    dataverse_metadata.port = 443
    dataverse_metadata.scheme = 'https'
    dataverse_metadata.save
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test "should redirect to root path after not finding a dataverse_metadata" do
    get view_dataverse_dataset_url("random","random_id")
    assert_redirected_to root_path
    assert_equal "Dataverse host metadata not found", flash[:error]
  end
end
