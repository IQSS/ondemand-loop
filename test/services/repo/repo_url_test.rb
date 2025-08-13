# frozen_string_literal: true
require 'test_helper'

class Repo::RepoUrlTest < ActiveSupport::TestCase
  test 'should parse standard HTTPS URL' do
    url = 'https://example.com/path/to/resource?foo=bar&baz=qux'
    parser = Repo::RepoUrl.parse(url)

    assert parser
    assert parser.https?
    assert_equal 'https', parser.scheme
    assert_equal 'example.com', parser.domain
    assert_nil parser.port
    assert_equal '/path/to/resource', parser.path
    assert_equal({ foo: 'bar', baz: 'qux' }, parser.params)
    assert_equal ['path', 'to', 'resource'], parser.path_segments
  end

  test 'should parse standard HTTP URL' do
    url = 'http://example.org/foo/bar?x=1&y=2'
    parser = Repo::RepoUrl.parse(url)

    assert parser
    refute parser.https?
    assert_equal 'http', parser.scheme
    assert_equal 'example.org', parser.domain
    assert_nil parser.port
    assert_equal '/foo/bar', parser.path
    assert_equal({ x: '1', y: '2' }, parser.params)
    assert_equal ['foo', 'bar'], parser.path_segments
  end

  test 'should parse HTTP URL with custom port' do
    url = 'http://localhost:3001/custom/path?one=1'
    parser = Repo::RepoUrl.parse(url)

    assert parser
    refute parser.https?
    assert_equal 'http', parser.scheme
    assert_equal 'localhost', parser.domain
    assert_equal 3001, parser.port
    assert_equal '/custom/path', parser.path
    assert_equal({ one: '1' }, parser.params)
    assert_equal ['custom', 'path'], parser.path_segments
  end

  test 'should handle URL with no query params' do
    url = 'https://example.com/simple/path'
    parser = Repo::RepoUrl.parse(url)

    assert parser
    assert_equal '/simple/path', parser.path
    assert_equal({}, parser.params)
  end

  test 'should handle URL with no path' do
    url = 'https://example.com'
    parser = Repo::RepoUrl.parse(url)

    assert parser
    assert_equal 'https', parser.scheme
    assert_equal 'example.com', parser.domain
    assert_nil parser.port
    assert_equal '/', parser.path
    assert_equal({}, parser.params)
    assert_equal [], parser.path_segments
  end



  test 'path should default to /' do
    assert_equal '/', Repo::RepoUrl.parse('https://example.com').path
    assert_equal [], Repo::RepoUrl.parse('https://example.com').path_segments
    assert_equal '/', Repo::RepoUrl.parse('https://example.com/').path
    assert_equal [], Repo::RepoUrl.parse('https://example.com/').path_segments
    assert_equal '/', Repo::RepoUrl.parse('https://example.com//').path
    assert_equal [], Repo::RepoUrl.parse('https://example.com//').path_segments
  end

  test 'should normalize path with multiple slashes' do
    url = 'https://example.com//test/value//other'
    parser = Repo::RepoUrl.parse(url)

    assert parser
    assert_equal '/test/value/other', parser.path
    assert_equal ['test', 'value', 'other'], parser.path_segments
  end

  test 'should return nil for nil URL' do
    assert_nil Repo::RepoUrl.parse(nil)
  end

  test 'should return nil for invalid or unsupported URLs' do
    invalid_urls = [
      'not a url',
      '123://bad',
      'www.server.com',
      'doi:10.1234/DVTest',
      'ftp://server.com',
      'hdl:11272.1/AB2/NXRVP9',
      'localhost:8080'
    ]

    invalid_urls.each do |url|
      assert_nil Repo::RepoUrl.parse(url), "Expected nil for #{url}"
    end
  end

  test 'build should default to https scheme' do
    parser = Repo::RepoUrl.build('example.org')

    assert parser
    assert_equal 'https', parser.scheme
    assert_equal 'example.org', parser.domain
    assert_nil parser.port
  end

  test 'build should accept custom scheme and port' do
    parser = Repo::RepoUrl.build('localhost', scheme: 'http', port: 8080)

    assert parser
    assert_equal 'http', parser.scheme
    assert_equal 'localhost', parser.domain
    assert_equal 8080, parser.port
  end

  test 'build should return nil when domain is blank' do
    assert_nil Repo::RepoUrl.build(nil)
    assert_nil Repo::RepoUrl.build('')
  end

  test 'scheme_override returns nil for https and scheme for others' do
    https_parser = Repo::RepoUrl.parse('https://example.com')
    http_parser = Repo::RepoUrl.parse('http://example.com')

    assert_nil https_parser.scheme_override
    assert_equal 'http', http_parser.scheme_override
  end

  test 'port_override returns nil for default ports and value for non-standard ports' do
    https_default = Repo::RepoUrl.parse('https://example.com')
    http_default = Repo::RepoUrl.parse('http://example.com:80')
    http_custom = Repo::RepoUrl.parse('http://example.com:8080')

    assert_nil https_default.port_override
    assert_nil http_default.port_override
    assert_equal 8080, http_custom.port_override
  end

  test 'should raise NoMethodError when calling new directly' do
    assert_raises(NoMethodError) do
      Repo::RepoUrl.new('https://example.com/path')
    end
  end
end
