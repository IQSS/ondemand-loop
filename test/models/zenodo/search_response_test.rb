require 'test_helper'
require_relative '../../utils/zenodo_helper'

class Zenodo::SearchResponseTest < ActiveSupport::TestCase
  include ZenodoHelper

  test 'parses items' do
    json = load_zenodo_fixture('search_response.json')
    resp = Zenodo::SearchResponse.new(json, 1, 2)
    assert_equal 2, resp.items.size
    assert_equal 'Record One', resp.items.first.title
    first = resp.items.first
    assert_equal '1', first.id
    assert_equal 'Desc one', first.description
    assert_equal '2024-01-01', first.publication_date
    assert_equal 1, first.files.size
    assert_equal 'md5:111', first.files.first.checksum
    assert_equal 1, resp.page
    assert_equal 2, resp.per_page
    assert_equal 2, resp.total_count
    assert_equal 1, resp.total_pages
    assert resp.first_page?
    assert resp.last_page?
  end

  test 'encodes file urls' do
    data = {
      hits: {
        total: 1,
        hits: [
          {
            id: 1,
            metadata: { title: 'T' },
            files: [
              {
                id: 1,
                key: 'a b.txt',
                size: 1,
                checksum: 'md5:1',
                links: { self: 'https://zenodo.org/api/files/abc/a b.txt' }
              }
            ]
          }
        ]
      }
    }.to_json
    resp = Zenodo::SearchResponse.new(data, 1, 10)
    file = resp.items.first.files.first
    assert_equal 'https://zenodo.org/api/files/abc/a%20b.txt', file.download_url
  end

  test 'raises error on invalid file url' do
    data = {
      hits: {
        hits: [
          {
            id: 1,
            metadata: { title: 'T' },
            files: [
              {
                id: 1,
                key: 'a',
                size: 1,
                checksum: 'md5:1',
                links: { self: 'http:// zenodo.org' }
              }
            ]
          }
        ]
      }
    }.to_json
    assert_raises RuntimeError do
      Zenodo::SearchResponse.new(data, 1, 10)
    end
  end
end
