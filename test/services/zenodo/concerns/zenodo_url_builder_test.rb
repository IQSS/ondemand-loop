require 'test_helper'

class DummyZenodoUrlBuilder
  include Zenodo::Concerns::ZenodoUrlBuilder

  attr_accessor :zenodo_url, :record_id, :file_name, :concept_id, :deposition_id
end

class Zenodo::Concerns::ZenodoUrlBuilderTest < ActiveSupport::TestCase
  def setup
    @builder = DummyZenodoUrlBuilder.new
    @builder.zenodo_url = 'https://zenodo.org'
    @builder.record_id = '1'
    @builder.file_name = 'file.txt'
    @builder.concept_id = '10'
    @builder.deposition_id = '20'
  end

  test 'record_url builds correct URL' do
    assert_equal 'https://zenodo.org/record/1', @builder.record_url
  end

  test 'file_url builds correct URL' do
    assert_equal 'https://zenodo.org/record/1/files/file.txt', @builder.file_url
  end

  test 'concept_url builds correct URL' do
    assert_equal 'https://zenodo.org/record/10', @builder.concept_url
  end

  test 'deposition_url builds correct URL' do
    assert_equal 'https://zenodo.org/deposit/20', @builder.deposition_url
  end

  test 'deposition_edit_url builds correct URL' do
    assert_equal 'https://zenodo.org/deposit/20#/files', @builder.deposition_edit_url
  end

  test 'user_depositions_url builds correct URL' do
    assert_equal 'https://zenodo.org/deposit', @builder.user_depositions_url
  end

  test 'record_url raises when record_id missing' do
    @builder.record_id = nil
    assert_raises(RuntimeError, 'record_id is missing') { @builder.record_url }
  end

  test 'deposition_url raises when deposition_id missing' do
    @builder.deposition_id = nil
    assert_raises(RuntimeError, 'deposition_id is missing') { @builder.deposition_url }
  end
end
