# frozen_string_literal: true
require 'test_helper'
require 'securerandom'
require 'tempfile'

class YamlStorageCommonTest < ActiveSupport::TestCase
  class DummyStorage
    include YamlStorageCommon
    attr_reader :data

    def initialize(data)
      @data = stringify_keys(data)
    end

    def to_yaml
      @data.to_yaml
    end

    private

    def stringify_keys(obj)
      case obj
      when Hash
        obj.transform_keys(&:to_s).transform_values { |v| stringify_keys(v) }
      when Array
        obj.map { |v| stringify_keys(v) }
      else
        obj
      end
    end
  end

  def with_tempfile
    file = Tempfile.new(['yaml_storage', '.yml'])
    path = file.path
    file.close! # close and unlink immediately, we'll manage manually
    yield path
  ensure
    File.delete(path) if path && File.exist?(path)
  end

  test 'can store and load a simple list' do
    with_tempfile do |file_path|
      data = ['a', 'b', 'c']
      storage = DummyStorage.new(data)
      storage.store_to_file(file_path)

      loaded = DummyStorage.load_from_file(file_path)
      assert_equal data, loaded
    end
  end

  test 'can store and load a list of objects as hashes' do
    with_tempfile do |file_path|
      objects = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }]
      storage = DummyStorage.new(objects)
      storage.store_to_file(file_path)

      loaded = DummyStorage.load_from_file(file_path)
      assert_equal [{'id' => 1, 'name' => 'Alice'}, {'id' => 2, 'name' => 'Bob'}], loaded
    end
  end

  test 'can store and load a hash with stringified keys' do
    with_tempfile do |file_path|
      hash = { symbol_key: 'value', nested: { inner: 123 } }
      storage = DummyStorage.new(hash)
      storage.store_to_file(file_path)

      loaded = DummyStorage.load_from_file(file_path)
      expected = { 'symbol_key' => 'value', 'nested' => { 'inner' => 123 } }
      assert_equal expected, loaded
    end
  end
end
