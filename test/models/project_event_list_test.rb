require "test_helper"

class ProjectEventListTest < ActiveSupport::TestCase

  test "add persists events with metadata" do
    in_temp_directory do |dir|
      project_id = 'p123'
      list = ProjectEventList.new(project_id: project_id)

      event = Event.new(project_id: project_id,
                        entity_type: 'project',
                        entity_id: project_id,
                        message: 'created',
                        metadata: { 'foo' => 'bar' })

      list.add(event)

      reloaded = ProjectEventList.new(project_id: project_id)
      assert_equal 1, reloaded.all.count
      assert_equal({ 'foo' => 'bar' }, reloaded.all.first.metadata)

      expected_file = File.join(dir, 'projects', project_id, 'events.yml')
      assert File.exist?(expected_file)
    end
  end

  test "all_by_entity_type_and_id filters events" do
    in_temp_directory do
      project_id = 'p456'
      list = ProjectEventList.new(project_id: project_id)

      e1 = Event.new(project_id: project_id,
                     entity_type: 'file',
                     entity_id: '1',
                     message: 'm1')
      e2 = Event.new(project_id: project_id,
                     entity_type: 'file',
                     entity_id: '2',
                     message: 'm2')
      list.add(e1)
      list.add(e2)

      results = list.all_by_entity_type_and_id(entity_type: 'file', entity_id: '1')
      assert_equal 1, results.count
      assert_equal e1.id, results.first.id
    end
  end

  private

  def in_temp_directory
    Dir.mktmpdir do |dir|
      Project.stubs(:metadata_root_directory).returns(dir)
      yield dir
    end
  end
end

