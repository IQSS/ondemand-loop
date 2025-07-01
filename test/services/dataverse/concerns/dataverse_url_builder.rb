# frozen_string_literal: true

require 'test_helper'

class DummyDataverseUrlBuilder
  include Dataverse::Concerns::DataverseUrlBuilder

  attr_accessor :dataverse_url, :collection_id, :dataset_id
end

class Dataverse::Concerns::DataverseUrlBuilderTest < ActiveSupport::TestCase
  def setup
    @builder = DummyDataverseUrlBuilder.new
    @builder.dataverse_url = 'https://demo.dataverse.org'
    @builder.collection_id = 'test-collection'
    @builder.dataset_id = 'doi:10.5072/FK2/ABC123'
  end

  test 'collection_url builds correct URL' do
    expected = 'https://demo.dataverse.org/dataverse/test-collection'
    assert_equal expected, @builder.collection_url
  end

  test 'collection_url raises when collection_id is missing' do
    @builder.collection_id = nil
    assert_raises(RuntimeError, 'collection_id is missing') do
      @builder.collection_url
    end
  end

  test 'dataset_url builds URL without version' do
    expected = 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/ABC123'
    assert_equal expected, @builder.dataset_url
  end

  test 'dataset_url builds URL with version' do
    expected = 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/ABC123&version=2.0'
    assert_equal expected, @builder.dataset_url(version: '2.0')
  end

  test 'dataset_url raises when dataset_id is missing' do
    @builder.dataset_id = nil
    assert_raises(RuntimeError, 'dataset_id (DOI) is missing') do
      @builder.dataset_url
    end
  end
end
