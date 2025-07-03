# frozen_string_literal: true
require 'test_helper'

class Repo::RepoResolverServiceTest < ActiveSupport::TestCase
  DummyResolver = Struct.new(:should_resolve, :raise_error) do
    def resolve(context)
      raise raise_error if raise_error

      if should_resolve
        context.object_url = context.input
        context.type = ConnectorType::DATAVERSE
      end
    end
  end

  test 'should return unknown result when URL is blank' do
    service = Repo::RepoResolverService.new([DummyResolver.new(true)])
    result = service.resolve('')

    assert result.unknown?
    assert_nil result.type
  end

  test 'should resolve when first resolver succeeds' do
    resolvers = [DummyResolver.new(true)]
    service = Repo::RepoResolverService.new(resolvers)

    result = service.resolve('https://demo.dataverse.org')

    assert result.resolved?
    assert_equal ConnectorType::DATAVERSE, result.type
    assert_equal 'https://demo.dataverse.org', result.object_url
  end

  test 'should skip first resolver and resolve with second' do
    resolvers = [
      DummyResolver.new(false),
      DummyResolver.new(true)
    ]
    service = Repo::RepoResolverService.new(resolvers)

    result = service.resolve('https://demo.dataverse.org/dataset.xhtml')

    assert result.resolved?
    assert_equal ConnectorType::DATAVERSE, result.type
  end

  test 'should stop on error and return unknown' do
    resolvers = [
      DummyResolver.new(false, RuntimeError.new('Unexpected failure'))
    ]
    service = Repo::RepoResolverService.new(resolvers)

    result = service.resolve('https://demo.dataverse.org/failure')

    assert result.unknown?
  end

  test 'should ignore non-resolving resolvers and return unknown if none succeed' do
    resolvers = [
      DummyResolver.new(false),
      DummyResolver.new(false)
    ]
    service = Repo::RepoResolverService.new(resolvers)

    result = service.resolve('https://demo.dataverse.org/nothing')

    assert result.unknown?
  end
end
