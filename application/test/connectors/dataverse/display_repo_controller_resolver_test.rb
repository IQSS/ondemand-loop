require 'test_helper'

class Dataverse::DisplayRepoControllerResolverTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  def setup
    @resolver = Dataverse::DisplayRepoControllerResolver.new
  end

  # Test initialization
  test 'should initialize with url_helper' do
    resolver = Dataverse::DisplayRepoControllerResolver.new
    assert_not_nil resolver.instance_variable_get(:@url_helper)
  end

  test 'should initialize with object parameter' do
    test_object = { test: 'value' }
    resolver = Dataverse::DisplayRepoControllerResolver.new(test_object)
    assert_not_nil resolver.instance_variable_get(:@url_helper)
  end

  # Test dataverse root URL handling
  test 'should generate redirect URL for dataverse root' do
    result = @resolver.get_controller_url('https://demo.dataverse.org')
    expected_url = view_dataverse_path('demo.dataverse.org', ':root', dv_scheme: nil, dv_port: nil)

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should generate redirect URL for dataverse root with HTTP' do
    result = @resolver.get_controller_url('http://localhost:8080')
    expected_url = view_dataverse_path('localhost', ':root', dv_scheme: 'http', dv_port: 8080)

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should generate redirect URL for dataverse root with custom port' do
    result = @resolver.get_controller_url('https://demo.dataverse.org:8443')
    expected_url = view_dataverse_path('demo.dataverse.org', ':root', dv_scheme: nil, dv_port: 8443)

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  # Test collection URL handling
  test 'should generate redirect URL for collection' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataverse/social-science')
    expected_url = view_dataverse_path('demo.dataverse.org', 'social-science', dv_scheme: nil, dv_port: nil)

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle collection with special characters' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataverse/social-science_test-collection')
    expected_url = view_dataverse_path('demo.dataverse.org', 'social-science_test-collection', dv_scheme: nil, dv_port: nil)

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle collection with dashes and numbers' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataverse/test-collection-123')
    expected_url = view_dataverse_path('demo.dataverse.org', 'test-collection-123', dv_scheme: nil, dv_port: nil)

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  # Test dataset URL handling
  test 'should generate redirect URL for dataset with dataset.xhtml' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/GCN7US')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      dv_scheme: nil,
      dv_port: nil,
      version: nil
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should generate redirect URL for dataset with version' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/GCN7US&version=2.0')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      dv_scheme: nil,
      dv_port: nil,
      version: '2.0'
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle dataset with draft version' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/GCN7US&version=draft')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      dv_scheme: nil,
      dv_port: nil,
      version: ':draft'
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle dataset with latest version' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/GCN7US&version=latest')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      dv_scheme: nil,
      dv_port: nil,
      version: ':latest'
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle dataset with latest-published version' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/GCN7US&version=latest-published')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      dv_scheme: nil,
      dv_port: nil,
      version: ':latest-published'
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should generate redirect URL for citation' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/citation?persistentId=doi:10.5072/FK2/GCN7US')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      dv_scheme: nil,
      dv_port: nil,
      version: nil
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should generate redirect URL for citation.xhtml' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/citation.xhtml?persistentId=doi:10.5072/FK2/GCN7US')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      dv_scheme: nil,
      dv_port: nil,
      version: nil
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  # Test file URL handling
  test 'should generate redirect URL for file with dataset_id' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/file.xhtml?persistentId=doi:10.5072/FK2/GCN7US&fileId=123')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      dv_scheme: nil,
      dv_port: nil,
      version: nil
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should generate redirect URL for file with version' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/file.xhtml?persistentId=doi:10.5072/FK2/GCN7US&fileId=123&version=1.0')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      dv_scheme: nil,
      dv_port: nil,
      version: '1.0'
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should redirect file without dataset_id to dataverse root' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/file.xhtml?fileId=123')
    expected_url = view_dataverse_path('demo.dataverse.org', ':root', dv_scheme: nil, dv_port: nil)

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle file with persistent_id containing file path' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/file.xhtml?persistentId=doi:10.5072/FK2/GCN7US/file123')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US/file123',
      dv_scheme: nil,
      dv_port: nil,
      version: nil
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  # Test different persistent ID formats
  test 'should handle different DOI formats' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.7910/DVN/EXAMPLE')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.7910/DVN/EXAMPLE',
      dv_scheme: nil,
      dv_port: nil,
      version: nil
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle handle format persistent IDs' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataset.xhtml?persistentId=hdl:1902.1/12345')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'hdl:1902.1/12345',
      dv_scheme: nil,
      dv_port: nil,
      version: nil
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  # Test unknown URL patterns
  test 'should return landing path for unknown URL patterns' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/unknown/path')
    expected_url = view_dataverse_landing_path

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should return landing path for api endpoints' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/api/datasets/123')
    expected_url = view_dataverse_landing_path

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should return landing path for other paths' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/admin/settings')
    expected_url = view_dataverse_landing_path

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  # Test edge cases
  test 'should handle URLs with fragments' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/GCN7US#fragment')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      dv_scheme: nil,
      dv_port: nil,
      version: nil
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle URLs with extra parameters' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.5072/FK2/GCN7US&extra=param&another=value')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'demo.dataverse.org',
      persistent_id: 'doi:10.5072/FK2/GCN7US',
      dv_scheme: nil,
      dv_port: nil,
      version: nil
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle dataset without persistent ID' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataset.xhtml')

    assert result.success?
    assert_equal '/view/dataverse', result.redirect_url
  end

  # Test different domain formats
  test 'should handle subdomain dataverse' do
    result = @resolver.get_controller_url('https://harvard.dataverse.org')
    expected_url = view_dataverse_path('harvard.dataverse.org', ':root', dv_scheme: nil, dv_port: nil)

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle localhost development' do
    result = @resolver.get_controller_url('http://localhost:8080/dataverse/test')
    expected_url = view_dataverse_path('localhost', 'test', dv_scheme: 'http', dv_port: 8080)

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle IP address' do
    result = @resolver.get_controller_url('http://192.168.1.100:8080')
    expected_url = view_dataverse_path('192.168.1.100', ':root', dv_scheme: 'http', dv_port: 8080)

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  # Test ConnectorResult structure
  test 'should always return ConnectorResult with success true' do
    result = @resolver.get_controller_url('https://demo.dataverse.org')

    assert_kind_of ConnectorResult, result
    assert result.success?
    assert_kind_of Hash, result.data
    assert_equal true, result.data[:success]
  end

  test 'should provide access to all ConnectorResult methods' do
    result = @resolver.get_controller_url('https://demo.dataverse.org')

    # Test all accessor methods exist and work
    assert_respond_to result, :success?
    assert_respond_to result, :redirect_url
    assert_respond_to result, :data
    assert_respond_to result, :message
    assert_respond_to result, :resource
    assert_respond_to result, :partial
    assert_respond_to result, :locals
    assert_respond_to result, :to_h

    # Test default values
    assert_kind_of Hash, result.message
    assert_nil result.resource
    assert_nil result.partial
    assert_kind_of Hash, result.locals
    assert_equal result.data, result.to_h
  end

  # Test URL parsing integration
  test 'should handle malformed URLs gracefully' do
    # Note: This depends on how UrlParser handles malformed URLs
    # If it returns nil, the resolver should handle it gracefully
    assert_nothing_raised do
      @resolver.get_controller_url('not-a-valid-url')
    end
  end

  test 'should handle empty string URL' do
    result = @resolver.get_controller_url('')
    expected_url = view_dataverse_landing_path

    assert_nothing_raised do
      assert result.success?
      assert_equal expected_url, result.redirect_url
    end
  end

  test 'should handle nil URL' do
    result = @resolver.get_controller_url(nil)
    expected_url = view_dataverse_landing_path

    assert_nothing_raised do
      assert result.success?
      assert_equal expected_url, result.redirect_url
    end
  end

  # Test specific URL patterns that should work
  test 'should handle complex dataset URLs' do
    complex_url = 'https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/EXAMPLE&version=1.2&tab=files'
    result = @resolver.get_controller_url(complex_url)
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'dataverse.harvard.edu',
      persistent_id: 'doi:10.7910/DVN/EXAMPLE',
      dv_scheme: nil,
      dv_port: nil,
      version: '1.2'
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should handle collection URLs with query parameters' do
    result = @resolver.get_controller_url('https://demo.dataverse.org/dataverse/social-science?q=test')
    expected_url = view_dataverse_path('demo.dataverse.org', 'social-science', dv_scheme: nil, dv_port: nil)

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  test 'should preserve scheme and port information correctly' do
    result = @resolver.get_controller_url('http://test.dataverse.org:9000/dataset.xhtml?persistentId=doi:test')
    expected_url = view_dataverse_dataset_path(
      dv_hostname: 'test.dataverse.org',
      persistent_id: 'doi:test',
      dv_scheme: 'http',
      dv_port: 9000,
      version: nil
    )

    assert result.success?
    assert_equal expected_url, result.redirect_url
  end

  # Test URL helper integration
  test 'should be able to use view_dataverse_landing_path helper' do
    landing_path = view_dataverse_landing_path
    assert_not_nil landing_path
    assert_kind_of String, landing_path
  end

  test 'should generate URLs that could redirect back to landing page' do
    result = @resolver.get_controller_url('https://demo.dataverse.org')
    landing_path = view_dataverse_landing_path

    assert result.success?
    assert_not_nil result.redirect_url
    assert_not_nil landing_path
    # Both should be valid path strings
    assert result.redirect_url.start_with?('/')
    assert landing_path.start_with?('/')
  end

end
