# frozen_string_literal: true
require "test_helper"

class Dataverse::ConnectorMetadataTest < ActiveSupport::TestCase

  test "should create read/write methods for any hash field names" do
    metadata = {
      id: '12345',
      status: 'RUNNING',
      location: '/some/location',
      test: 'anything value',
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::ConnectorMetadata.new(file)
    assert_equal '12345', target.id
    assert_equal 'RUNNING', target.status
    assert_equal '/some/location', target.location
    assert_equal 'anything value', target.test

    target.id = 'updated'
    target.status = 'updated'
    target.location = 'updated'
    target.test = 'updated'

    assert_equal 'updated', target.id = 'updated'
    assert_equal 'updated', target.status
    assert_equal 'updated', target.location
    assert_equal 'updated', target.test
  end

  test "should not throw error when calling invalid methods" do
    metadata = {
      id: '12345'
    }
    file = DownloadFile.new
    file.metadata = metadata

    target = Dataverse::ConnectorMetadata.new(file)
    assert_equal '12345', target.id
    assert_nil target.other
    assert_nil target.missing
    assert_nil target.name
  end

  test "to_h should hash with string keys" do
    metadata = {
      id: '12345',
      status: 'RUNNING',
    }
    file = DownloadFile.new
    file.metadata = metadata

    result = Dataverse::ConnectorMetadata.new(file).to_h
    assert_equal({'id' => '12345', 'status' => 'RUNNING'}, result)
  end
end
