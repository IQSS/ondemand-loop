require 'test_helper'
require_relative '../../utils/zenodo_helper'

class Zenodo::DepositionResponseTest < ActiveSupport::TestCase
  include ZenodoHelper

  def setup
    json = load_zenodo_fixture('deposition_response.json')
    @resp = Zenodo::DepositionResponse.new(json)
  end

  test 'parses values' do
    assert_equal '1', @resp.id
    assert_equal 'My Deposition', @resp.title
    assert_equal 'Deposition description', @resp.description
    assert_equal '2025-06-18T22:25:16.278906+00:00', @resp.publication_date
    assert_equal 'https://zenodo.org/api/files/123', @resp.bucket_url
    assert_equal 1, @resp.file_count
    assert_equal 1, @resp.files.size
    file = @resp.files.first
    assert_equal '10', file.id
    assert_equal 'file.txt', file.filename
    assert_equal 1234, file.filesize
    assert_equal 'md5:abc', file.checksum
    assert_equal 'https://zenodo.org/api/files/123/file.txt', file.download_link
    assert_equal 'https://zenodo.org/api/files/123/file.txt', file.download_url
    assert @resp.draft?
  end
end
