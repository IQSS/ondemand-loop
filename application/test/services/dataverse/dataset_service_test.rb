require 'test_helper'

class Dataverse::DatasetServiceTest < ActiveSupport::TestCase
  include DataverseHelper

  def setup
    @client = HttpClientMock.new(file_path: fixture_path('dataverse/create_dataset_response/valid_response.json'))
    @service = Dataverse::DatasetService.new('https://example.com', http_client: @client, api_key: 'KEY')
  end

  test 'create_dataset posts data and returns response object' do
    dataset = Dataverse::CreateDatasetRequest.new(
      title: 't',
      description: 'd',
      author: 'a',
      contact_email: 'e@example.com',
      subjects: ['Other']
    )
    res = @service.create_dataset('dv1', dataset)
    assert_kind_of Dataverse::CreateDatasetResponse, res
    assert_equal 'OK', res.status
  end

  test 'find_dataset_version_by_persistent_id raises unauthorized' do
    unauthorized_client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_version_response/valid_response.json'), status_code: 401)
    service = Dataverse::DatasetService.new('https://example.com', http_client: unauthorized_client)
    assert_raises(Dataverse::DatasetService::UnauthorizedException) do
      service.find_dataset_version_by_persistent_id('doi:1')
    end
  end

  test 'search_dataset_files_by_persistent_id parses list' do
    @client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_files_response/valid_response.json'))
    @service = Dataverse::DatasetService.new('https://example.com', http_client: @client)
    res = @service.search_dataset_files_by_persistent_id('doi:1', page: 1, per_page: 2)
    assert_kind_of Dataverse::DatasetFilesResponse, res
    assert_equal 2, res.files.size
  end

  test 'search_dataset_files_by_persistent_id uses version in url' do
    @client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_files_response/valid_response.json'))
    @service = Dataverse::DatasetService.new('https://example.com', http_client: @client)
    @service.search_dataset_files_by_persistent_id('doi:1', version: '2.0')
    assert_includes @client.called_path, '/versions/2.0/files'
  end

  test 'find_dataset_version_by_persistent_id uses version in url' do
    @client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_version_response/valid_response.json'))
    @service = Dataverse::DatasetService.new('https://example.com', http_client: @client)
    @service.find_dataset_version_by_persistent_id('doi:1', version: '2.0')
    assert_includes @client.called_path, '/versions/2.0'
  end

  test 'dataset_versions_by_persistent_id parses response and requires key' do
    @client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_versions_response/valid_response.json'))
    service = Dataverse::DatasetService.new('https://example.com', http_client: @client, api_key: 'KEY')
    res = service.dataset_versions_by_persistent_id('doi:1')
    assert_instance_of Dataverse::DatasetVersionsResponse, res
    assert_equal 2, res.versions.size
    assert_equal 'doi:10.70122/FK2/O9JYAO', res.versions.first.persistent_id
    assert_equal ':draft', res.versions.first.version
    assert_includes @client.called_path, 'excludeMetadataBlocks=true'
  end

end
