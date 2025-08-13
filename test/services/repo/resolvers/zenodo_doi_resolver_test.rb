require 'test_helper'

class Repo::Resolvers::ZenodoDoiResolverTest < ActiveSupport::TestCase
  include LoggingCommonMock

  test 'resolve updates object_url on redirect' do
    client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'),
                                 status_code: 302,
                                 headers: { 'location' => 'https://zenodo.org/records/16764341' })
    context = Repo::RepoResolverContext.new('https://zenodo.org/doi/10.5281/zenodo.16764341', http_client: client)
    context.object_url = 'https://zenodo.org/doi/10.5281/zenodo.16764341'
    context.type = ConnectorType::ZENODO

    resolver = Repo::Resolvers::ZenodoDoiResolver.new
    resolver.resolve(context)

    assert client.called?
    assert_equal 'https://zenodo.org/records/16764341', context.object_url
  end

  test 'resolve leaves object_url when DOI has no redirect' do
    client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'))
    context = Repo::RepoResolverContext.new('https://zenodo.org/doi/10.5281/zenodo.16764341', http_client: client)
    context.object_url = 'https://zenodo.org/doi/10.5281/zenodo.16764341'
    context.type = ConnectorType::ZENODO

    resolver = Repo::Resolvers::ZenodoDoiResolver.new
    resolver.resolve(context)

    assert client.called?
    assert_equal 'https://zenodo.org/doi/10.5281/zenodo.16764341', context.object_url
  end

  test 'resolve is no-op when object_url is not a DOI' do
    client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'))
    context = Repo::RepoResolverContext.new('https://zenodo.org/records/16764341', http_client: client)
    context.object_url = 'https://zenodo.org/records/16764341'
    context.type = ConnectorType::ZENODO

    resolver = Repo::Resolvers::ZenodoDoiResolver.new
    resolver.resolve(context)

    assert_not client.called?
    assert_equal 'https://zenodo.org/records/16764341', context.object_url
  end

  test 'resolve is no-op when type is not Zenodo' do
    client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'))
    context = Repo::RepoResolverContext.new('https://zenodo.org/doi/10.5281/zenodo.16764341', http_client: client)
    context.object_url = 'https://zenodo.org/doi/10.5281/zenodo.16764341'
    context.type = ConnectorType::DATAVERSE

    resolver = Repo::Resolvers::ZenodoDoiResolver.new
    resolver.resolve(context)

    assert_not client.called?
    assert_equal 'https://zenodo.org/doi/10.5281/zenodo.16764341', context.object_url
  end

  test 'resolve is no-op when object_url is nil' do
    client = HttpClientMock.new(file_path: fixture_path('downloads/basic_http/sample_utf8.txt'))
    context = Repo::RepoResolverContext.new('https://zenodo.org/doi/10.5281/zenodo.16764341', http_client: client)
    context.type = ConnectorType::ZENODO

    resolver = Repo::Resolvers::ZenodoDoiResolver.new
    resolver.resolve(context)

    assert_not client.called?
    assert_nil context.object_url
  end
end
