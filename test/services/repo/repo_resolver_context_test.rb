# frozen_string_literal: true
require 'test_helper'

class Repo::RepoResolverContextTest < ActiveSupport::TestCase
  test 'should initialize with valid input' do
    input = 'https://demo.repo.org/dataset.xhtml?persistentId=doi:10.1234/XYZ'
    context = Repo::RepoResolverContext.new(input)

    assert_equal input, context.input
    assert context.parsed_input
    assert_instance_of Repo::RepoUrl, context.parsed_input
    assert_instance_of Common::HttpClient, context.http_client
    assert context.repo_db
  end

  test 'should return a RepoResolverResponse with object_url and type' do
    context = Repo::RepoResolverContext.new('https://demo.repo.org/file.xhtml')
    context.object_url = 'https://demo.repo.org/file.xhtml?persistentId=doi:10.1234/XYZ/ABC&fileId=123'
    context.type = :dataverse

    result = context.result

    assert_instance_of Repo::RepoResolverResponse, result
    assert_equal context.object_url, result.object_url
    assert_equal :dataverse, result.type
    assert result.resolved?
    refute result.unknown?
  end

  test 'should return unknown result when type is nil' do
    context = Repo::RepoResolverContext.new('https://demo.repo.org/file.xhtml')
    context.object_url = 'https://demo.repo.org/file.xhtml?persistentId=doi:10.1234/XYZ/ABC&fileId=123'
    context.type = nil

    result = context.result

    assert result.unknown?
    refute result.resolved?
  end

  test 'should return nil parsed_input for invalid URL' do
    context = Repo::RepoResolverContext.new('not a url')

    assert_nil context.parsed_input
  end
end
