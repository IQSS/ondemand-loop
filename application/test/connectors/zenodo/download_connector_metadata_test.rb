require 'test_helper'

class Zenodo::DownloadConnectorMetadataTest < ActiveSupport::TestCase
  def setup
    file = DownloadFile.new
    file.metadata = {type: 'records', type_id: 1, zenodo_url: 'https://zenodo_server.com'}
    @meta = Zenodo::DownloadConnectorMetadata.new(file)
  end

  test 'repo_name is Zenodo' do
    assert_equal 'Zenodo', @meta.repo_name
  end

  test 'files_url uses type and id' do
    assert_equal '/explore/zenodo/zenodo_server.com/records/1', @meta.files_url
  end

  test 'to_h and missing methods' do
    assert_nil @meta.unknown
    assert_equal({'type'=>'records', 'type_id'=>1, "zenodo_url"=>"https://zenodo_server.com"}, @meta.to_h)
  end
end
