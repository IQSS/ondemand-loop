require "test_helper"

class ApplicationDiskRecordTest < ActiveSupport::TestCase

  class DummyDiskRecord < ApplicationDiskRecord
    attr_accessor :name, :value

    def initialize(name = nil, value = nil)
      @name = name
      @value = value
    end

    def save
      @saved = true
    end

    def saved?
      @saved
    end
  end

  test "metadata_root_directory returns configuration root" do
    Configuration.stubs(:metadata_root).returns("/tmp/root")
    assert_equal "/tmp/root", ApplicationDiskRecord.metadata_root_directory
  end

  test "generate_id returns a UUID string" do
    uuid = ApplicationDiskRecord.generate_id
    assert_match /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/, uuid
  end

  test "generate_code returns alphanumeric string of given length" do
    code = ApplicationDiskRecord.generate_code(6)
    assert_match /\A[a-zA-Z0-9]{6}\z/, code
  end

  test "save method raises NotImplementedError in base class" do
    record = ApplicationDiskRecord.new
    assert_raises(NotImplementedError) { record.save }
  end

  test "update updates attributes and calls save" do
    record = DummyDiskRecord.new
    refute record.saved?

    record.update(name: "TestName", value: 42)
    assert_equal "TestName", record.name
    assert_equal 42, record.value
    assert record.saved?
  end

  test "update skips attributes without setters" do
    record = DummyDiskRecord.new
    record.update(nonexistent: "value", name: "UpdatedName")
    assert_equal "UpdatedName", record.name
    assert_raises(NoMethodError) { record.nonexistent }
    # Ensure nonexistent attribute did not raise error
  end
end
