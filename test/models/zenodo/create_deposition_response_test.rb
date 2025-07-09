require 'test_helper'
require_relative '../../utils/zenodo_helper'

class Zenodo::CreateDepositionResponseTest < ActiveSupport::TestCase
  include ZenodoHelper

  def setup
    json = load_zenodo_fixture('create_deposition_response.json')
    @resp = Zenodo::CreateDepositionResponse.new(json)
  end

  test 'parses attributes' do
    assert_equal 1, @resp.id
    assert_equal '10.1234/zenodo.1', @resp.doi
    assert_equal 'https://zenodo.org/api/files/123', @resp.bucket_url
    assert_equal 'https://zenodo.org/deposit/1', @resp.html_url
    assert @resp.editable?
  end
end
