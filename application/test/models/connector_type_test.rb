# frozen_string_literal: true
require 'test_helper'

class ConnectorTypeTest < ActiveSupport::TestCase

  test 'should raise error for invalid type' do
    assert_raises(ArgumentError, 'Invalid type: invalid_type') do
      ConnectorType.new('invalid_type')
    end
  end

  test 'should initialize with a valid type' do
    connector_type = ConnectorType.new('dataverse')
    assert_equal 'dataverse', connector_type.to_s
  end

  test 'should be dataverse?' do
    connector_type = ConnectorType.new('dataverse')
    assert connector_type.dataverse?
  end

  test 'should not be case sensitive' do
    connector_type = ConnectorType.new('DATAVERSE')
    assert connector_type.dataverse?
  end
end
