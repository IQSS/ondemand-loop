# frozen_string_literal: true
require 'test_helper'

class Repo::RepoUrlParserTest < ActiveSupport::TestCase
  test 'should parse dataset URL with DOI and version' do
    url = 'https://demo.dataverse.org/dataset.xhtml?persistentId=doi:10.70122/FK2/OO7VX1&version=DRAFT'
    parser = Repo::RepoUrlParser.parse(url)

    assert parser
    assert_equal 'https', parser.scheme
    assert_equal 'demo.dataverse.org', parser.domain
    assert_nil parser.port
    assert_equal 'dataset', parser.type
    assert_equal 'doi:10.70122/FK2/OO7VX1', parser.doi
    assert_equal 'DRAFT', parser.version
    assert_nil parser.code
  end

  test 'should parse file URL with DOI and version' do
    url = 'https://demo.dataverse.org/file.xhtml?persistentId=doi:10.70122/FK2/OO7VX1/8QTLVC&version=1.0'
    parser = Repo::RepoUrlParser.parse(url)

    assert parser
    assert_equal 'file', parser.type
    assert_equal 'doi:10.70122/FK2/OO7VX1/8QTLVC', parser.doi
    assert_equal '1.0', parser.version
    assert_nil parser.code
  end

  test 'should parse collection URL with code' do
    url = 'https://demo.dataverse.org/dataverse/hdcrepo'
    parser = Repo::RepoUrlParser.parse(url)

    assert parser
    assert_equal 'collection', parser.type
    assert_equal 'hdcrepo', parser.code
    assert_nil parser.doi
    assert_nil parser.version
  end

  test 'should handle custom port' do
    url = 'http://localhost:3000/dataset.xhtml?persistentId=doi:10.1234/XYZ&version=2.0'
    parser = Repo::RepoUrlParser.parse(url)

    assert parser
    assert_equal 'http', parser.scheme
    assert_equal 'localhost', parser.domain
    assert_equal 3000, parser.port
  end

  test 'should default to unknown type if path is unrecognized' do
    url = 'https://example.org/unknown/path'
    parser = Repo::RepoUrlParser.parse(url)

    assert parser
    assert_equal 'unknown', parser.type
    assert_nil parser.doi
    assert_nil parser.version
    assert_nil parser.code
  end

  test 'should handle URL without query params' do
    url = 'https://demo.dataverse.org/dataset.xhtml'
    parser = Repo::RepoUrlParser.parse(url)

    assert parser
    assert_equal 'dataset', parser.type
    assert_nil parser.doi
    assert_nil parser.version
  end

  test 'should return base repo URL with and without custom port' do
    parser = Repo::RepoUrlParser.parse("https://demo.dataverse.org/dataverse/foo")
    assert_equal "https://demo.dataverse.org", parser.repo_url

    parser = Repo::RepoUrlParser.parse("http://localhost:3000/dataset.xhtml?persistentId=doi:10.1234/XYZ")
    assert_equal "http://localhost:3000", parser.repo_url
  end

  test 'should return nil for invalid URL input' do
    assert_nil Repo::RepoUrlParser.parse("not a url")
    assert_nil Repo::RepoUrlParser.parse("hello world")
    assert_nil Repo::RepoUrlParser.parse("123://invalid")
  end

  test 'should raise NoMethodError when calling new directly' do
    assert_raises(NoMethodError) do
      Repo::RepoUrlParser.new('https://demo.dataverse.org/dataset.xhtml')
    end
  end
end
