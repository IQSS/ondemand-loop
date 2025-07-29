# frozen_string_literal: true
require 'test_helper'

class Dataverse::DataverseUrlTest < ActiveSupport::TestCase
  test 'should expose scheme, domain and port' do
    url = 'http://localhost:3001/dataverse/mycollection'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert dataverse_url
    assert_equal 'http', dataverse_url.scheme
    assert_equal 'localhost', dataverse_url.domain
    assert_equal 3001, dataverse_url.port
    assert_equal 'http://localhost:3001', dataverse_url.dataverse_url
  end

  test 'should omit port if using default for https' do
    url = 'https://demo.dataverse.org/dataverse/mycollection'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert dataverse_url
    assert_equal 'https', dataverse_url.scheme
    assert_equal 'demo.dataverse.org', dataverse_url.domain
    assert_nil dataverse_url.port
    assert_equal 'https://demo.dataverse.org', dataverse_url.dataverse_url
  end

  test 'should parse dataverse root URL' do
    url = 'https://demo.dataverse.org/'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert dataverse_url
    assert dataverse_url.dataverse?
    assert_equal 'https://demo.dataverse.org', dataverse_url.dataverse_url
  end

  test 'should parse collection URL' do
    url = 'https://demo.dataverse.org/dataverse/mycollection'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert dataverse_url
    assert dataverse_url.collection?
    assert_equal 'mycollection', dataverse_url.collection_id
    assert_equal 'https://demo.dataverse.org', dataverse_url.dataverse_url
    assert_equal 'https://demo.dataverse.org/dataverse/mycollection', dataverse_url.collection_url
  end

  test 'should parse dataset URL' do
    url = 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.1234/XYZ&version=1.0'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert dataverse_url
    assert dataverse_url.dataset?
    assert_equal 'doi:10.1234/XYZ', dataverse_url.dataset_id
    assert_equal '1.0', dataverse_url.version

    assert_equal 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi%3A10.1234%2FXYZ', dataverse_url.dataset_url
    assert_equal 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi%3A10.1234%2FXYZ&version=1.0', dataverse_url.dataset_url(version: '1.0')
  end

  test 'should parse dataset citation URL' do
    url = 'https://demo.dataverse.org/citation?persistentId=doi:10.7939/DVN/10979'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert dataverse_url
    assert dataverse_url.dataset?
    assert_equal 'doi:10.7939/DVN/10979', dataverse_url.dataset_id
    assert_nil dataverse_url.version
  end

  test 'should parse dataset citation.xhtml URL' do
    url = 'https://demo.dataverse.org/citation.xhtml?persistentId=doi:10.7939/DVN/10979'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert dataverse_url
    assert dataverse_url.dataset?
    assert_equal 'doi:10.7939/DVN/10979', dataverse_url.dataset_id
    assert_nil dataverse_url.version
  end

  test 'should parse file URL with persistentId and fileId' do
    url = 'https://demo.dataverse.org/file.xhtml?persistentId=doi:10.1234/XYZ/ABC&fileId=123&version=1.0'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert dataverse_url
    assert dataverse_url.file?
    assert_equal 'doi:10.1234/XYZ/ABC', dataverse_url.dataset_id
    assert_equal '123', dataverse_url.file_id
    assert_equal '1.0', dataverse_url.version
  end

  test 'should map draft version values' do
    url = 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.1234/XYZ&version=DRAFT'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert_equal ':draft', dataverse_url.version
  end

  test 'should map latest version values' do
    url = 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.1234/XYZ&version=latest'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert_equal ':latest', dataverse_url.version
  end

  test 'should map latest-published version values' do
    url = 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.1234/XYZ&version=LATEST-PUBLISHED'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert_equal ':latest-published', dataverse_url.version
  end

  test 'should raise when constructing collection_url without collection_id' do
    url = 'https://demo.dataverse.org/'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert_raises(RuntimeError, 'collection_id is missing') do
      dataverse_url.collection_url
    end
  end

  test 'should raise when constructing dataset_url without dataset_id' do
    url = 'https://demo.dataverse.org/dataset.xhtml'
    dataverse_url = Dataverse::DataverseUrl.parse(url)

    assert_raises(RuntimeError, 'dataset_id (DOI) is missing') do
      dataverse_url.dataset_url
    end
  end
end
