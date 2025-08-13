# frozen_string_literal: true
require 'test_helper'
require 'cgi'

class DataverseDatasetsHelperTest < ActionView::TestCase
  include Dataverse::DatasetsHelper
  include ExploreHelper

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
    repo_url = Repo::RepoUrl.parse('https://dv.example')
    html = link_to_dataset_prev_page(repo_url, 'id', '1.0', page, {})
    expected_prev = link_to_explore(ConnectorType::DATAVERSE, repo_url,
                                    type: 'datasets', id: 'id', version: '1.0', page: 1)
    assert_includes html, "href=\"#{CGI.escapeHTML(expected_prev)}\""

    page = Page.new((1..30).to_a, 2, 10)
    html = link_to_dataset_next_page(repo_url, 'id', '1.0', page, {})
    expected_next = link_to_explore(ConnectorType::DATAVERSE, repo_url,
                                    type: 'datasets', id: 'id', version: '1.0', page: 3)
    assert_includes html, "href=\"#{CGI.escapeHTML(expected_next)}\""
  end

  test 'storage_identifier parses identifier' do
    assert_equal 's3://bucket', storage_identifier('s3://bucket:12345')
    assert_nil storage_identifier(nil)
  end

  test 'external_dataset_url builds correct link' do
    url = external_dataset_url('http://dv.example', 'pid', '1.0')
    assert_equal 'http://dv.example/dataset.xhtml?persistentId=pid&version=1.0', url
  end

  test 'sort_by_draft orders drafts first' do
    list = [OpenStruct.new(version: '1'), OpenStruct.new(version: ':draft'), OpenStruct.new(version: '2')]
    sorted = sort_by_draft(list)
    assert_equal ':draft', sorted.first.version
  end
end
