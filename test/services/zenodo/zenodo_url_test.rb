# frozen_string_literal: true
require 'test_helper'

class Zenodo::ZenodoUrlTest < ActiveSupport::TestCase
  test 'parses scheme, domain and port' do
    url = 'http://localhost:3000/record/1'
    zurl = Zenodo::ZenodoUrl.parse(url)

    assert zurl
    assert_equal 'http', zurl.scheme
    assert_equal 'localhost', zurl.domain
    assert_equal 3000, zurl.port
    assert_equal 'http://localhost:3000', zurl.zenodo_url
  end

  test 'parses zenodo root url' do
    url = 'https://zenodo.org/'
    zurl = Zenodo::ZenodoUrl.parse(url)

    assert zurl.zenodo?
    assert_equal 'https://zenodo.org', zurl.zenodo_url
  end

  test 'parses zenodo DOI url' do
    url = 'https://zenodo.org/doi/10.5281/zenodo.16764341'
    zurl = Zenodo::ZenodoUrl.parse(url)

    assert zurl.doi?
    assert_equal 'https://zenodo.org', zurl.zenodo_url
  end

  test 'parses record url (plural)' do
    url = 'https://zenodo.org/records/99'
    zurl = Zenodo::ZenodoUrl.parse(url)

    assert zurl.record?
    assert_equal '99', zurl.record_id
  end

  test 'parses record url (singular legacy)' do
    url = 'https://zenodo.org/record/42'
    zurl = Zenodo::ZenodoUrl.parse(url)

    assert zurl.record?
    assert_equal '42', zurl.record_id
  end

  test 'parses file url (plural)' do
    url = 'https://zenodo.org/records/99/files/data/file.txt'
    zurl = Zenodo::ZenodoUrl.parse(url)

    assert zurl.file?
    assert_equal '99', zurl.record_id
    assert_equal 'data/file.txt', zurl.file_name
  end

  test 'parses file url (singular legacy)' do
    url = 'https://zenodo.org/record/99/files/path/to/file.txt'
    zurl = Zenodo::ZenodoUrl.parse(url)

    assert zurl.file?
    assert_equal '99', zurl.record_id
    assert_equal 'path/to/file.txt', zurl.file_name
  end

  test 'parses deposition url (deposit)' do
    url = 'https://zenodo.org/deposit/123'
    zurl = Zenodo::ZenodoUrl.parse(url)

    assert zurl.deposition?
    assert_equal '123', zurl.deposition_id
  end

  test 'parses deposition url (uploads)' do
    url = 'https://zenodo.org/uploads/456'
    zurl = Zenodo::ZenodoUrl.parse(url)

    assert zurl.deposition?
    assert_equal '456', zurl.deposition_id
  end

  test 'unknown path yields unknown type' do
    url = 'https://zenodo.org/communities/my-community'
    zurl = Zenodo::ZenodoUrl.parse(url)

    assert zurl.unknown?
  end
end
