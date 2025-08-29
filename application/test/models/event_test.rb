require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)
    @project = Project.new(id: 'proj1', name: 'Proj', download_dir: '/tmp/proj')
    @project.save
    @event = Event.new(project_id: @project.id, entity_id: @project.id, entity_type: 'project', message: 'project has been created', metadata: { 'foo' => 'bar' }, creation_date: DateTimeCommon.now)
    @events_file = Project.events_file(@project.id)
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir)
  end

  test 'save appends event to file' do
    @event.save
    assert File.exist?(@events_file), 'events file not created'
    data = YAML.safe_load(File.read(@events_file))
    assert_equal 1, data.size
    assert_equal @project.id, data.last['entity_id']
  end

  test 'for_project returns stored events' do
    @event.save
    events = Event.for_project(@project.id)
    assert_equal 1, events.size
    assert_equal @project.id, events.last.entity_id
    assert_equal 'project has been created', events.last.message
  end

end
