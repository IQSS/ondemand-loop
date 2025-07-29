require 'test_helper'

class Dataverse::DatasetVersionsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @domain = 'demo.dataverse.org'
    @persistent_id = 'doi:10.5072/FK2/GCN7US'

    # Mock RepoResolverService for valid dataverse URLs
    resolver = mock('resolver')
    resolver.stubs(:resolve).returns(OpenStruct.new(type: ConnectorType::DATAVERSE))
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    # Mock RepoRegistry for service initialization
    repo_info = mock('repo_info')
    metadata = mock('metadata')
    metadata.stubs(:auth_key).returns('test_api_key')
    repo_info.stubs(:metadata).returns(metadata)
    RepoRegistry.stubs(:repo_db).returns(mock('repo_db').tap { |db| db.stubs(:get).returns(repo_info) })
  end

  def versions_valid_json
    {
      "status": "OK",
      "data": [
        {
          "id": 1,
          "datasetId": 123,
          "datasetPersistentId": "doi:10.5072/FK2/GCN7US",
          "storageIdentifier": "file://123",
          "versionNumber": 1,
          "versionMinorNumber": 0,
          "versionState": "RELEASED",
          "lastUpdateTime": "2023-01-15T10:30:00Z",
          "releaseTime": "2023-01-15T10:30:00Z",
          "createTime": "2023-01-10T09:00:00Z"
        },
        {
          "id": 2,
          "datasetId": 123,
          "datasetPersistentId": "doi:10.5072/FK2/GCN7US",
          "storageIdentifier": "file://123",
          "versionNumber": 2,
          "versionMinorNumber": 0,
          "versionState": "RELEASED",
          "lastUpdateTime": "2023-02-20T14:45:00Z",
          "releaseTime": "2023-02-20T14:45:00Z",
          "createTime": "2023-02-15T11:30:00Z"
        }
      ]
    }.to_json
  end

  # URL validation tests
  test 'should return bad request if dataverse url is not supported' do
    resolver = mock('resolver')
    resolver.stubs(:resolve).returns(OpenStruct.new(type: nil))
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    get view_dataverse_dataset_versions_path('invalid.host', @persistent_id)

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal I18n.t('dataverse.datasets.versions.url_not_supported', dataverse_url: 'https://invalid.host'), json_response['error']
  end

  test 'should handle custom scheme and port parameters' do
    versions_response = mock('versions_response')
    versions_response.stubs(:versions).returns([])
    Dataverse::DatasetService.any_instance.stubs(:dataset_versions_by_persistent_id).returns(versions_response)

    get view_dataverse_dataset_versions_path(@domain, @persistent_id), params: {
      dv_scheme: 'http',
      dv_port: '8080'
    }

    assert_response :success
  end

  # Service error tests
  test 'should return internal server error when service raises exception' do
    Dataverse::DatasetService.any_instance.stubs(:dataset_versions_by_persistent_id).raises(StandardError.new('Service error'))

    get view_dataverse_dataset_versions_path(@domain, @persistent_id)

    assert_response :internal_server_error
    json_response = JSON.parse(response.body)
    expected_error = I18n.t('dataverse.datasets.versions.dataverse_service_error',
                            dataverse_url: "https://#{@domain}",
                            persistent_id: @persistent_id,
                            version: nil)
    assert_equal expected_error, json_response['error']
  end

  test 'should return internal server error when service raises unauthorized exception' do
    Dataverse::DatasetService.any_instance.stubs(:dataset_versions_by_persistent_id).raises(Dataverse::ApiService::UnauthorizedException)

    get view_dataverse_dataset_versions_path(@domain, @persistent_id)

    assert_response :internal_server_error
    json_response = JSON.parse(response.body)
    expected_error = I18n.t('dataverse.datasets.versions.dataverse_service_error',
                            dataverse_url: "https://#{@domain}",
                            persistent_id: @persistent_id,
                            version: nil)
    assert_equal expected_error, json_response['error']
  end

  # Successful response tests
  test 'should render versions partial when service returns valid response' do
    versions_response = mock('versions_response')
    mock_versions = [
      OpenStruct.new(id: 1, versionNumber: 1, versionMinorNumber: 0, versionState: 'RELEASED'),
      OpenStruct.new(id: 2, versionNumber: 2, versionMinorNumber: 0, versionState: 'RELEASED')
    ]
    versions_response.stubs(:versions).returns(mock_versions)
    Dataverse::DatasetService.any_instance.stubs(:dataset_versions_by_persistent_id).returns(versions_response)

    get view_dataverse_dataset_versions_path(@domain, @persistent_id)

    assert_response :success
  end

  test 'should handle empty versions response' do
    versions_response = mock('versions_response')
    versions_response.stubs(:versions).returns([])
    Dataverse::DatasetService.any_instance.stubs(:dataset_versions_by_persistent_id).returns(versions_response)

    get view_dataverse_dataset_versions_path(@domain, @persistent_id)

    assert_response :success
  end

  test 'should handle nil versions response' do
    Dataverse::DatasetService.any_instance.stubs(:dataset_versions_by_persistent_id).returns(nil)

    get view_dataverse_dataset_versions_path(@domain, @persistent_id)

    assert_response :success
  end

  test 'should handle versions response with nil versions' do
    versions_response = mock('versions_response')
    versions_response.stubs(:versions).returns(nil)
    Dataverse::DatasetService.any_instance.stubs(:dataset_versions_by_persistent_id).returns(versions_response)

    get view_dataverse_dataset_versions_path(@domain, @persistent_id)

    assert_response :success
  end

  # Dataset URL building tests
  test 'should build dataset URL with default https scheme and port 443' do
    versions_response = mock('versions_response')
    versions_response.stubs(:versions).returns([])
    Dataverse::DatasetService.any_instance.stubs(:dataset_versions_by_persistent_id).returns(versions_response)

    get view_dataverse_dataset_versions_path(@domain, @persistent_id)

    assert_response :success
  end

  test 'should build dataset URL with custom scheme and port' do
    versions_response = mock('versions_response')
    versions_response.stubs(:versions).returns([])
    Dataverse::DatasetService.any_instance.stubs(:dataset_versions_by_persistent_id).returns(versions_response)

    get view_dataverse_dataset_versions_path(@domain, @persistent_id), params: {
      dv_scheme: 'http',
      dv_port: '8080'
    }

    assert_response :success
  end

  # Service initialization tests
  test 'should initialize service with correct parameters' do
    versions_response = mock('versions_response')
    versions_response.stubs(:versions).returns([])

    service_mock = mock('service')
    service_mock.expects(:dataset_versions_by_persistent_id).with(@persistent_id).returns(versions_response)
    Dataverse::DatasetService.expects(:new).with("https://#{@domain}", api_key: 'test_api_key').returns(service_mock)

    get view_dataverse_dataset_versions_path(@domain, @persistent_id)

    assert_response :success
  end

  test 'should handle missing repo info gracefully' do
    RepoRegistry.stubs(:repo_db).returns(mock('repo_db').tap { |db| db.stubs(:get).returns(nil) })

    versions_response = mock('versions_response')
    versions_response.stubs(:versions).returns([])

    service_mock = mock('service')
    service_mock.expects(:dataset_versions_by_persistent_id).with(@persistent_id).returns(versions_response)
    Dataverse::DatasetService.expects(:new).with("https://#{@domain}", api_key: nil).returns(service_mock)

    get view_dataverse_dataset_versions_path(@domain, @persistent_id)

    assert_response :success
  end

end
