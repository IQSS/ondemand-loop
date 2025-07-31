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

  test 'IntegerMapper should return nil for nil input' do
    result = ConfigurationProperty::IntegerMapper.map_string(nil)
    assert_nil result
  end

  test 'IntegerMapper should throw exception for invalid integer string' do
    assert_raises(ArgumentError) do
      ConfigurationProperty::IntegerMapper.map_string('invalid')
    end
  end

  test 'PathMapper should create directory and return Pathname' do
    path = '/tmp/test_path_mapper_dir/test_file'
    result = ConfigurationProperty::PathMapper.map_string(path)
    assert_instance_of Pathname, result
    assert_equal Pathname(path), result
    assert File.directory?(path)
  ensure
    FileUtils.rm_rf('/tmp/test_path_mapper_dir')
  end

  test 'PathMapper should return nil for nil input' do
    assert_nil ConfigurationProperty::PathMapper.map_string(nil)
  end

  test 'FilePathMapper should create parent directory and return Pathname' do
    path = '/tmp/test_file_mapper_dir/nested/file.txt'
    result = ConfigurationProperty::FilePathMapper.map_string(path)
    assert_instance_of Pathname, result
    assert_equal Pathname(path), result
    assert File.directory?(File.dirname(path))
  ensure
    FileUtils.rm_rf('/tmp/test_file_mapper_dir')
  end

  test 'FilePathMapper should return nil for nil input' do
    assert_nil ConfigurationProperty::FilePathMapper.map_string(nil)
  end

  test 'BooleanMapper should map true-like strings' do
    %w[true 1 yes on y t].each do |val|
      assert_equal true, ConfigurationProperty::BooleanMapper.map_string(val)
    end
  end

  test 'BooleanMapper should map false-like strings' do
    %w[false 0 no off f n].each do |val|
      assert_equal false, ConfigurationProperty::BooleanMapper.map_string(val)
    end
    assert_equal false, ConfigurationProperty::BooleanMapper.map_string('')
  end

  test 'BooleanMapper should return true for unknown values' do
    assert_equal true, ConfigurationProperty::BooleanMapper.map_string('maybe')
  end

  test 'map_string delegates to mapper' do
    ConfigurationProperty::PassThroughMapper.expects(:map_string).with('default_value')
    ConfigurationProperty.new(:delegated, 'default_value', false, [], ConfigurationProperty::PassThroughMapper)
  end

  test 'FileContentMapper should read content from existing file' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'VERSION')
      File.write(path, '1.2.3')
      result = ConfigurationProperty::FileContentMapper.map_string(path)
      assert_equal '1.2.3', result
    end
  end

  test 'FileContentMapper should return nil for missing file or nil input' do
    assert_nil ConfigurationProperty::FileContentMapper.map_string('/tmp/does_not_exist')
    assert_nil ConfigurationProperty::FileContentMapper.map_string(nil)
  end

  test '.file_content should create property with file content default' do
    Dir.mktmpdir do |dir|
      version_file = File.join(dir, 'ver')
      File.write(version_file, '9.9.9')
      property = ConfigurationProperty.file_content(:foo, default: version_file)
      assert_equal :foo, property.name
      assert_equal '9.9.9', property.default
      assert_equal false, property.read_from_environment
      assert_equal [], property.environment_names
    end
  end

  test '.boolean creates a property with BooleanMapper' do
    prop = ConfigurationProperty.boolean(:feature_enabled, default: 'true')
    assert_equal true, prop.default
    assert_equal ConfigurationProperty::BooleanMapper, prop.instance_variable_get(:@mapper)
  end

  test '.integer creates a property with IntegerMapper' do
    prop = ConfigurationProperty.integer(:retries, default: '5')
    assert_equal 5, prop.default
    assert_equal ConfigurationProperty::IntegerMapper, prop.instance_variable_get(:@mapper)
  end

  test '.path creates a property with PathMapper' do
    dir = '/tmp/test_path_property'
    prop = ConfigurationProperty.path(:tmpdir, default: dir)
    assert_instance_of Pathname, prop.default
    assert File.directory?(dir)
  ensure
    FileUtils.rm_rf(dir)
  end

  test '.file_path creates a property with FilePathMapper' do
    file_path = '/tmp/test_file_path_property/file.txt'
    prop = ConfigurationProperty.file_path(:out, default: file_path)
    assert_instance_of Pathname, prop.default
    assert File.directory?(File.dirname(file_path))
  ensure
    FileUtils.rm_rf('/tmp/test_file_path_property')
  end

  test '.property creates a property with PassThroughMapper' do
    prop = ConfigurationProperty.property(:plain, default: 'abc')
    assert_equal 'abc', prop.default
    assert_equal ConfigurationProperty::PassThroughMapper, prop.instance_variable_get(:@mapper)
  end
end
