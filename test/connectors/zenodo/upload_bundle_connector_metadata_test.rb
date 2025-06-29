require 'test_helper'

class Zenodo::UploadBundleConnectorMetadataTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project
    @bundle = create_upload_bundle(@project)
    @bundle.metadata = { zenodo_url: 'https://zenodo.org', title: 't', draft: true, auth_key: 'key' }
    @meta = Zenodo::UploadBundleConnectorMetadata.new(@bundle)
  end

  test 'api_key present' do
    assert @meta.api_key?
  end

  test 'to_h returns string keys' do
    assert_equal 't', @meta.to_h['title']
  end

  test 'helpers around draft and api key' do
    assert @meta.display_title?
    assert @meta.draft?
    assert_not @meta.fetch_deposition?
    refute @meta.api_key_required?
  end
end
