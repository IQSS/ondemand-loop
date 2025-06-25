require "test_helper"

class DummyYaml
  include YamlStorage
  ATTRIBUTES = [:id, :type, :status]
  attr_accessor(*ATTRIBUTES)
end

class YamlStorageTest < ActiveSupport::TestCase
  test "store and load object" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "obj.yml")
      obj = DummyYaml.new
      obj.id = "abc"
      obj.type = ConnectorType::DATAVERSE
      obj.status = FileStatus::SUCCESS
      assert obj.store_to_file(path)
      loaded = DummyYaml.load_from_file(path)
      assert_equal obj.id, loaded.id
      assert_equal obj.type.to_s, loaded.type.to_s
      assert_equal obj.status.to_s, loaded.status.to_s
    end
  end
end
