require 'test_helper'

class RepoResolverServiceTest < ActiveSupport::TestCase
  class MockResolver
    attr_reader :called

    def initialize(response: nil, error: false)
      @response = response
      @error = error
      @called = false
    end

    def resolve(context)
      @called = true

      raise StandardError, 'Resolver error' if @error

      if @response
        context.type = @response[:type]
        context.doi = @response[:doi]
        context.object_url = @response[:object_url]
      end
    end
  end

  test 'returns resolved result when a resolver succeeds' do
    resolver = MockResolver.new(response: { type: 'dataset', doi: '10.1234/abcde', object_url: 'https://example.com/object' })
    service = Repo::RepoResolverService.new([resolver])

    result = service.resolve('https://example.com/object')

    expected_result = {
      doi: '10.1234/abcde',
      object_url: 'https://example.com/object',
      type: 'dataset'
    }

    assert_equal expected_result, result
  end

  test 'returns Unknown type when all resolvers cannot resolve' do
    empty_response = MockResolver.new
    service = Repo::RepoResolverService.new([empty_response, empty_response])

    result = service.resolve('https://example.com/nonexistent')

    assert_equal({ type: 'Unknown' }, result)
  end

  test 'returns Unknown type when a resolver raises an exception' do
    resolver = MockResolver.new(error: true)
    service = Repo::RepoResolverService.new([resolver])

    assert_nothing_raised do
      result = service.resolve('https://example.com/error-case')
      assert_equal({ type: 'Unknown' }, result)
    end
  end

  test 'stops resolver chain after first successful resolve' do
    resolver1 = MockResolver.new(response: { type: 'dataset', doi: '10.1234/abcde', object_url: 'https://example.com/object' })
    resolver2 = MockResolver.new(response: { type: 'dataset', doi: '10.1234/abcde', object_url: 'https://example.com/object' })

    service = Repo::RepoResolverService.new([resolver1, resolver2])

    result = service.resolve('https://example.com/object')

    assert_equal 'dataset', result[:type]
    assert resolver1.called, 'First resolver should have been called'
    refute resolver2.called, 'Second resolver should NOT have been called after success'
  end
end
