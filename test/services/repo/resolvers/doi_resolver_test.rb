require 'test_helper'

class Repo::Resolvers::DoiResolverTest < ActiveSupport::TestCase
  include LoggingCommonMock

  def setup
    @client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'), status_code:302, headers:{'location'=>'https://target'})
    @context = Repo::RepoResolverContext.new('doi:10.123/abc', http_client: @client)
    @resolver = Repo::Resolvers::DoiResolver.new(api_url: 'https://doi.org')
  end

  test 'priority is high' do
    assert_equal 99000, @resolver.priority
  end

  test 'resolve sets object_url on redirect' do
    @client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'), status_code:302, headers:{'location'=>'https://example.com'})
    @context = Repo::RepoResolverContext.new('doi:10.123/abc', http_client: @client)
    @resolver.resolve(@context)
    assert_equal 'https://example.com', @context.object_url
  end

  test 'resolve logs when cannot resolve' do
    http = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'))
    @resolver = Repo::Resolvers::DoiResolver.new(api_url: 'https://doi.org')
    context = Repo::RepoResolverContext.new('doi:10.123/abc', http_client: http)
    @resolver.resolve(context)
    assert_nil context.object_url
  end

  test 'resolve handles doi.org urls directly' do
    client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'),
                                status_code: 302,
                                headers: { 'location' => 'https://example.com' })
    context = Repo::RepoResolverContext.new('https://doi.org/10.123/abc', http_client: client)
    @resolver.resolve(context)
    assert_equal 'https://example.com', context.object_url
    assert_equal 'https://doi.org/10.123/abc', client.called_path
  end

  test 'resolve sets object_url to input for non doi urls' do
    client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'))
    url = 'https://example.org/resource'
    context = Repo::RepoResolverContext.new(url, http_client: client)
    @resolver.resolve(context)
    assert_equal url, context.object_url
    refute client.called?
  end

  test 'resolve normalizes URL with trailing slash' do
    client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'))
    input_url = 'https://dataverse.org/'
    expected_url = 'https://dataverse.org'
    context = Repo::RepoResolverContext.new(input_url, http_client: client)
    @resolver.resolve(context)
    assert_equal expected_url, context.object_url
    refute client.called?
  end

  test 'resolve normalizes URL when parsed input exists' do
    client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'))
    input_url = 'https://zenodo.org/records/123/'
    expected_url = 'https://zenodo.org/records/123'
    context = Repo::RepoResolverContext.new(input_url, http_client: client)
    @resolver.resolve(context)
    assert_equal expected_url, context.object_url
    refute client.called?
  end

  test 'resolve handles parsed input with server url containing doi.org' do
    client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'),
                                status_code: 302,
                                headers: { 'location' => 'https://resolved.example.com' })
    
    # Create a context where parsed_input.server_url includes doi.org
    input_url = 'https://doi.org/10.123/redirected'
    context = Repo::RepoResolverContext.new(input_url, http_client: client)
    @resolver.resolve(context)
    
    assert_equal 'https://resolved.example.com', context.object_url
    assert_equal input_url, client.called_path
  end
end
