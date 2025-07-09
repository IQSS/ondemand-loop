# frozen_string_literal: true
require 'test_helper'

class FluentUrlTest < ActiveSupport::TestCase
  test 'to_s should return base URL when no path or params are added' do
    url = FluentUrl.new('https://example.com')
    assert_equal 'https://example.com', url.to_s
  end

  test 'add_path should append segments to the URL path' do
    url = FluentUrl.new('https://example.com')
                   .add_path('api')
                   .add_path('v1')
                   .add_path('users')
    assert_equal 'https://example.com/api/v1/users', url.to_s
  end

  test 'add_path should skip blank segments' do
    url = FluentUrl.new('https://example.com')
                   .add_path('api')
                   .add_path('')
                   .add_path(nil)
                   .add_path('data')
    assert_equal 'https://example.com/api/data', url.to_s
  end

  test 'add_param should append query parameters to URL' do
    url = FluentUrl.new('https://example.com')
                   .add_param(:page, 2)
                   .add_param('per_page', 10)
    assert_equal 'https://example.com?page=2&per_page=10', url.to_s
  end

  test 'add_param should overwrite duplicate keys' do
    url = FluentUrl.new('https://example.com')
                   .add_param(:page, 2)
                   .add_param(:page, 5)
    assert_equal 'https://example.com?page=5', url.to_s
  end

  test 'add_param should support array of values' do
    url = FluentUrl.new('https://example.com')
                   .add_param('role_ids', [1, 3, 5, 7])
    assert_equal 'https://example.com?role_ids=1&role_ids=3&role_ids=5&role_ids=7', url.to_s
  end

  test 'to_s should encode special characters in query parameters' do
    url = FluentUrl.new('https://example.com')
                   .add_param('q', 'name:John Doe')
                   .add_param('redirect', 'https://other.com/path?x=1&y=2')
    uri = Addressable::URI.parse(url.to_s)
    query = uri.query_values
    assert_equal 'name:John Doe', query['q']
    assert_equal 'https://other.com/path?x=1&y=2', query['redirect']
  end

  test 'to_s should combine path and encoded query parameters' do
    url = FluentUrl.new('https://example.com')
                   .add_path('search')
                   .add_param('q', 'ruby & rails')
    expected_url = 'https://example.com/search?q=ruby%20%26%20rails'
    assert_equal expected_url, url.to_s
  end

  test 'to_s should preserve existing path in base URL' do
    url = FluentUrl.new('https://example.com/api/v1')
    assert_equal 'https://example.com/api/v1', url.to_s
  end

  test 'add_path should append to existing path from base URL' do
    url = FluentUrl.new('https://example.com/api/v1')
                   .add_path('users')
                   .add_path('42')
    assert_equal 'https://example.com/api/v1/users/42', url.to_s
  end

  test 'add_path should normalize slashes in base and new segments' do
    url = FluentUrl.new('https://example.com/api/v1/')
                   .add_path('/projects/')
                   .add_path('/123/')
    assert_equal 'https://example.com/api/v1/projects/123', url.to_s
  end

  test 'to_s should work with existing path and query params' do
    url = FluentUrl.new('https://example.com/api/v1/resource')
                   .add_param('token', 'abc123')
    assert_equal 'https://example.com/api/v1/resource?token=abc123', url.to_s
  end

  test 'add_path should work when base path is a single segment' do
    url = FluentUrl.new('https://example.com/files')
                   .add_path('abc')
                   .add_path('xyz')
    assert_equal 'https://example.com/files/abc/xyz', url.to_s
  end
end
