require 'test_helper'

class Dataverse::DatasetServiceTest < ActiveSupport::TestCase
  include DataverseHelper

  test 'create_dataset posts data and returns response object' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/create_dataset_response/valid_response.json'))
    target = Dataverse::DatasetService.new('https://example.com', http_client: client, api_key: 'KEY')
    dataset = Dataverse::CreateDatasetRequest.new(
      title: 't',
      description: 'd',
      author: 'a',
      contact_email: 'e@example.com',
      subjects: ['Other']
    )
    res = target.create_dataset('dv1', dataset)
    assert_kind_of Dataverse::CreateDatasetResponse, res
    assert_equal 'OK', res.status
  end

  test 'find_dataset_version_by_persistent_id raises unauthorized' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_version_response/valid_response.json'), status_code: 401)
    target = Dataverse::DatasetService.new('https://example.com', http_client: client)
    assert_raises(Dataverse::DatasetService::UnauthorizedException) do
      target.find_dataset_version_by_persistent_id('doi:1')
    end
  end

  test 'search_dataset_files_by_persistent_id parses list' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_files_response/valid_response.json'))
    target = Dataverse::DatasetService.new('https://example.com', http_client: client)
    res = target.search_dataset_files_by_persistent_id('doi:1', page: 1, per_page: 2)
    assert_kind_of Dataverse::DatasetFilesResponse, res
    assert_equal 2, res.files.size
  end

  test 'search_dataset_files_by_persistent_id uses version in url' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_files_response/valid_response.json'))
    target = Dataverse::DatasetService.new('https://example.com', http_client: client)
    target.search_dataset_files_by_persistent_id('doi:1', version: '2.0')
    assert_includes client.called_path, '/versions/2.0/files'
  end

  test 'find_dataset_version_by_persistent_id uses version in url' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_version_response/valid_response.json'))
    target = Dataverse::DatasetService.new('https://example.com', http_client: client)
    target.find_dataset_version_by_persistent_id('doi:1', version: '2.0')
    assert_includes client.called_path, '/versions/2.0'
  end

  test 'dataset_versions_by_persistent_id parses response and requires key' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_versions_response/valid_response.json'))
    target = Dataverse::DatasetService.new('https://example.com', http_client: client, api_key: 'KEY')
    res = target.dataset_versions_by_persistent_id('doi:1')
    assert_instance_of Dataverse::DatasetVersionsResponse, res
    assert_equal 2, res.versions.size
    assert_equal 'doi:10.70122/FK2/O9JYAO', res.versions.first.persistent_id
    assert_equal ':draft', res.versions.first.version
    assert_includes client.called_path, 'excludeMetadataBlocks=true'
  end

  test 'find_dataset_version_by_persistent_id uses default version for nil' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_version_response/valid_response.json'))
    target = Dataverse::DatasetService.new('https://example.com', http_client: client, api_key: 'KEY')
    target.find_dataset_version_by_persistent_id('doi:1', version: nil)
    assert_includes client.called_path, '/versions/:latest-published'
  end

  test 'find_dataset_version_by_persistent_id uses default version for empty string' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_version_response/valid_response.json'))
    target = Dataverse::DatasetService.new('https://example.com', http_client: client, api_key: 'KEY')
    target.find_dataset_version_by_persistent_id('doi:1', version: '')
    assert_includes client.called_path, '/versions/:latest-published'
  end

  test 'find_dataset_version_by_persistent_id uses default version for whitespace' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_version_response/valid_response.json'))
    target = Dataverse::DatasetService.new('https://example.com', http_client: client, api_key: 'KEY')
    target.find_dataset_version_by_persistent_id('doi:1', version: '  ')
    assert_includes client.called_path, '/versions/:latest-published'
  end

  test 'search_dataset_files_by_persistent_id uses default version for nil' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_files_response/valid_response.json'))
    target = Dataverse::DatasetService.new('https://example.com', http_client: client, api_key: 'KEY')
    target.search_dataset_files_by_persistent_id('doi:1', version: nil)
    assert_includes client.called_path, '/versions/:latest-published/files'
  end

  test 'search_dataset_files_by_persistent_id uses default version for empty string' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_files_response/valid_response.json'))
    target = Dataverse::DatasetService.new('https://example.com', http_client: client, api_key: 'KEY')
    target.search_dataset_files_by_persistent_id('doi:1', version: '')
    assert_includes client.called_path, '/versions/:latest-published/files'
  end

  test 'search_dataset_files_by_persistent_id uses default version for whitespace' do
    client = HttpClientMock.new(file_path: fixture_path('dataverse/dataset_files_response/valid_response.json'))
    target = Dataverse::DatasetService.new('https://example.com', http_client: client, api_key: 'KEY')
    target.search_dataset_files_by_persistent_id('doi:1', version: '  ')
    assert_includes client.called_path, '/versions/:latest-published/files'
  end

end
