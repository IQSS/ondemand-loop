require 'test_helper'

class Command::ResponseTest < ActiveSupport::TestCase
  test 'initialize with default values' do
    response = Command::Response.new
    assert_equal 200, response.status
    assert_equal({}, response.headers)
    assert_kind_of OpenStruct, response.body
  end

  test 'initialize with custom values' do
    response = Command::Response.new(
      status: 404,
      headers: { 'Content-Type' => 'application/json' },
      body: { message: 'Not found' }
    )
    assert_equal 404, response.status
    assert_equal({ 'Content-Type' => 'application/json' }, response.headers)
    assert_equal 'Not found', response.body.message
  end

  test 'initialize converts string status to integer' do
    response = Command::Response.new(status: '500')
    assert_equal 500, response.status
    assert_kind_of Integer, response.status
  end

  test 'success? returns true for 200 status' do
    response = Command::Response.new(status: 200)
    assert response.success?
  end

  test 'success? returns false for non-200 status' do
    response = Command::Response.new(status: 404)
    refute response.success?
  end

  test 'error? returns false for 200 status' do
    response = Command::Response.new(status: 200)
    refute response.error?
  end

  test 'error? returns true for non-200 status' do
    response = Command::Response.new(status: 500)
    assert response.error?
  end

  test 'to_h returns hash representation' do
    response = Command::Response.new(
      status: 201,
      headers: { 'Location' => '/api/resource/1' },
      body: { id: 1, name: 'test' }
    )
    expected = {
      status: 201,
      headers: { 'Location' => '/api/resource/1' },
      body: { id: 1, name: 'test' }
    }
    assert_equal expected, response.to_h
  end

  test 'to_json returns json string' do
    response = Command::Response.new(body: { message: 'success' })
    json_string = response.to_json
    parsed = JSON.parse(json_string)
    assert_equal 200, parsed['status']
    assert_equal 'success', parsed['body']['message']
  end

  test 'from_json creates response from json string' do
    json = '{"status":201,"headers":{"Content-Type":"application/json"},"body":{"id":1}}'
    response = Command::Response.from_json(json)
    assert_equal 201, response.status
    assert_equal 'application/json', response.headers['Content-Type'.to_sym]
    assert_equal 1, response.body.id
  end

  test 'error creates error response' do
    response = Command::Response.error(status: 400, message: 'Bad request')
    assert_equal 400, response.status
    assert_equal 'Bad request', response.body.message
    assert response.error?
  end

  test 'error creates error response with handler' do
    handler = Object.new
    response = Command::Response.error(status: 500, message: 'Internal error', handler: handler)
    assert_equal 500, response.status
    assert_equal 'Internal error', response.body.message
    assert_equal 'Object', response.headers[:handler]
  end

  test 'ok creates success response' do
    response = Command::Response.ok(body: { result: 'success' })
    assert_equal 200, response.status
    assert_equal 'success', response.body.result
    assert response.success?
  end

  test 'ok creates success response with handler' do
    handler = Object.new
    response = Command::Response.ok(body: { data: 'test' }, handler: handler)
    assert_equal 200, response.status
    assert_equal 'test', response.body.data
    assert_equal 'Object', response.headers[:handler]
  end

  test 'handles nil headers gracefully' do
    response = Command::Response.new(headers: nil)
    assert_equal({}, response.headers)
  end

  test 'handles nil body gracefully' do
    response = Command::Response.new(body: nil)
    assert_kind_of OpenStruct, response.body
  end
end