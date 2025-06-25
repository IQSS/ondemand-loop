# frozen_string_literal: true
require 'test_helper'

class DataverseDatasetsHelperTest < ActionView::TestCase
  include Dataverse::DatasetsHelper

  test 'file_thumbnail uses dataverse preview for images' do
    json = load_dataverse_fixture('dataset_files_response', 'valid_response.json')
    file = Dataverse::DatasetFilesResponse.new(json).files.first
    html = file_thumbnail('https://dv.example', file)
    assert_includes html, 'src="https://dv.example/api/access/datafile/'
  end

  test 'file_thumbnail uses placeholder for other types' do
    file_hash = { label: 'a', dataFile: { id: 1, filename: 'a.txt', contentType: 'text/plain' } }
    file = Dataverse::DatasetFilesResponse::DatasetFile.new(file_hash)
    html = file_thumbnail('https://dv.example', file)
    assert_includes html, 'file_thumbnail.png'
  end

  test 'verify methods delegate to service' do
    service = mock('svc')
    service.expects(:validate_dataset).with(:d).returns(:ok)
    service.expects(:validate_dataset_file).with(:f).returns(:ok2)
    stubs(:retrictions_service).returns(service)
    assert_equal :ok, verify_dataset(:d)
    assert_equal :ok2, verify_file(:f)
  end

  test 'link_to_dataset_prev_page and next_page' do
    page = Page.new((1..30).to_a, 2, 10)
    stubs(:view_dataverse_dataset_path).returns('/prev')
    html = link_to_dataset_prev_page('https://dv.example', 'id', page, {})
    assert_includes html, '/prev'

    page = Page.new((1..30).to_a, 2, 10)
    stubs(:view_dataverse_dataset_path).returns('/next')
    html = link_to_dataset_next_page('https://dv.example', 'id', page, {})
    assert_includes html, '/next'
  end

  test 'storage_identifier parses identifier' do
    assert_equal 's3://bucket', storage_identifier('s3://bucket:12345')
    assert_nil storage_identifier(nil)
  end
end
