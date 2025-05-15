require 'test_helper'

class Repo::RepoResolverContextTest < ActiveSupport::TestCase
  class MockHttpClient; end

  test 'initializes with input and parses input' do
    input = 'https://example.com/repo/object'
    parsed_result = { repo: 'example', id: 'object' }

    context = Repo::RepoResolverContext.new(input, http_client: MockHttpClient.new)

    assert_equal input, context.input
    assert_instance_of MockHttpClient, context.http_client
    assert_equal 'https', context.parsed_input.scheme
    assert_equal 'example.com', context.parsed_input.domain
  end

  test 'result returns nil when type is not set' do
    context = Repo::RepoResolverContext.new('dummy')
    assert_nil context.result
  end

  test 'result returns hash when type is set' do
    context = Repo::RepoResolverContext.new('dummy')
    context.doi = '10.1234/abcde'
    context.object_url = 'https://example.com/object'
    context.type = 'dataset'

    expected_result = {
      doi: '10.1234/abcde',
      object_url: 'https://example.com/object',
      type: 'dataset'
    }

    assert_equal expected_result, context.result
  end
end
