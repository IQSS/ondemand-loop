# frozen_string_literal: true
require 'test_helper'

class UrlParserTest < ActiveSupport::TestCase
  test 'should parse standard HTTPS URL' do
    url = 'https://example.com/path/to/resource?foo=bar&baz=qux'
    parser = UrlParser.parse(url)

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
    parser = UrlParser.parse(url)

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
    parser = UrlParser.parse(url)

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
    parser = UrlParser.parse(url)

    assert parser
    assert_equal '/simple/path', parser.path
    assert_equal({}, parser.params)
  end

  test 'should handle URL with only domain' do
    url = 'https://example.com'
    parser = UrlParser.parse(url)

    assert parser
    assert_equal 'https', parser.scheme
    assert_equal 'example.com', parser.domain
    assert_nil parser.port
    assert_equal '/', parser.path
    assert_equal({}, parser.params)
    assert_equal [], parser.path_segments
  end

  test 'path should default to /' do
    assert_equal '/', UrlParser.parse('https://example.com').path
    assert_equal [], UrlParser.parse('https://example.com').path_segments
    assert_equal '/', UrlParser.parse('https://example.com/').path
    assert_equal [], UrlParser.parse('https://example.com/').path_segments
    assert_equal '/', UrlParser.parse('https://example.com//').path
    assert_equal [], UrlParser.parse('https://example.com//').path_segments
  end

  test 'should normalize path with multiple slashes' do
    url = 'https://example.com//test/value//other'
    parser = UrlParser.parse(url)

    assert parser
    assert_equal '/test/value/other', parser.path
    assert_equal ['test', 'value', 'other'], parser.path_segments
  end

  test 'should return nil for nil URL' do
    assert_nil UrlParser.parse(nil)
  end

  test 'should return nil for invalid URL' do
    assert_nil UrlParser.parse('not a url')
    assert_nil UrlParser.parse('123://bad')
  end

  test 'should raise NoMethodError when calling new directly' do
    assert_raises(NoMethodError) do
      UrlParser.new('https://example.com/path')
    end
  end
end
