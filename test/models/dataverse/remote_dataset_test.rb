require 'test_helper'

class Dataverse::RemoteDatasetTest < ActiveSupport::TestCase
  test 'valid? and to_h' do
    ds = Dataverse::RemoteDataset.new(url: 'http://example.com', api_key: '123', dataset_name: 'name', doi: 'doi')
    assert ds.valid?
    h = ds.to_h
    assert_equal 'Dataverse', h[:type]
    assert_equal 'name', h[:dataset_name]
  end

  test 'invalid when missing url' do
    ds = Dataverse::RemoteDataset.new(api_key: '123')
    refute ds.valid?
  end
end
