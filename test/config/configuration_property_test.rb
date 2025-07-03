# frozen_string_literal: true
require 'test_helper'

class ConfigurationPropertyTest < ActiveSupport::TestCase

  test 'should initialize with correct attributes' do
    property = ConfigurationProperty.new(:example, 'default_value', true, ['CUSTOM_ENV'], ConfigurationProperty::PassThroughMapper)
    assert_equal :example, property.name
    assert_equal 'default_value', property.default
    assert_equal true, property.read_from_environment
    assert_equal ['CUSTOM_ENV'], property.environment_names
  end

  test 'should default environment name if none provided' do
    property = ConfigurationProperty.new(:sample, nil, true, nil, ConfigurationProperty::PassThroughMapper)
    assert_equal ['OOD_LOOP_SAMPLE'], property.environment_names
  end

  test 'should not set environment names if read_from_env is false' do
    property = ConfigurationProperty.new(:sample, nil, false, nil, ConfigurationProperty::PassThroughMapper)
    assert_equal [], property.environment_names
  end

  test 'PassThroughMapper should return string as-is' do
    result = ConfigurationProperty::PassThroughMapper.map_string('test_value')
    assert_equal 'test_value', result
  end

  test 'IntegerMapper should parse valid integer string' do
    result = ConfigurationProperty::IntegerMapper.map_string('42')
    assert_equal 42, result
  end

  test 'IntegerMapper should throw exception for invalid integer string' do
    assert_raises(ArgumentError) do
      ConfigurationProperty::IntegerMapper.map_string('invalid')
    end
  end

  test 'PathMapper should create directory and return Pathname' do
    path = '/tmp/test_directory/test_file.txt'
    result = ConfigurationProperty::PathMapper.map_string(path)
    assert_instance_of Pathname, result
    assert_equal Pathname(path), result
    assert File.directory?(File.dirname(path))
  ensure
    FileUtils.rm_rf('/tmp/test_directory')
  end

  test 'PathMapper should return nil for nil input' do
    result = ConfigurationProperty::PathMapper.map_string(nil)
    assert_nil result
  end

  test 'BooleanMapper should map true-like strings' do
    assert_equal true, ConfigurationProperty::BooleanMapper.map_string('true')
    assert_equal true, ConfigurationProperty::BooleanMapper.map_string('1')
    assert_equal true, ConfigurationProperty::BooleanMapper.map_string('yes')
    assert_equal true, ConfigurationProperty::BooleanMapper.map_string('on')
  end

  test 'BooleanMapper should map false-like strings' do
    assert_equal false, ConfigurationProperty::BooleanMapper.map_string('false')
    assert_equal false, ConfigurationProperty::BooleanMapper.map_string('0')
    assert_equal false, ConfigurationProperty::BooleanMapper.map_string('no')
    assert_equal false, ConfigurationProperty::BooleanMapper.map_string('')
  end

  test 'BooleanMapper should return true for unknown values' do
    assert_equal true, ConfigurationProperty::BooleanMapper.map_string('maybe')
  end

  test 'map_string delegates to mapper' do
    ConfigurationProperty::PassThroughMapper.expects(:map_string).with('default_value')
    property = ConfigurationProperty.new(:delegated, 'default_value', false, [], ConfigurationProperty::PassThroughMapper)
  end
end
