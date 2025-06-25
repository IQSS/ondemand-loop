require 'test_helper'
require_relative '../../helpers/zenodo_helper'

class Zenodo::DepositionResponseTest < ActiveSupport::TestCase
  include ZenodoHelper

  def setup
    json = load_zenodo_fixture('deposition_response.json')
    @resp = Zenodo::DepositionResponse.new(json)
  end

  test 'parses values' do
    assert_equal 1, @resp.id
    assert_equal 'My Deposition', @resp.title
    assert_equal 'https://zenodo.org/api/files/123', @resp.bucket_url
    assert_equal 1, @resp.file_count
    assert @resp.draft?
  end
end
