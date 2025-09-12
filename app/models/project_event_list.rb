# frozen_string_literal: true

class ProjectEventList
  include YamlStorageCommon

  def initialize(project_id:)
    @project_id = project_id
    @events = load_events
  end

  def all
    @events
  end

  def all_by_entity_type_and_id(entity_type:, entity_id:)
    all.select { |event| event.entity_type == entity_type && event.entity_id == entity_id }
  end

  def add(event)
    return false unless event.valid? && event.project_id == @project_id

    @events << event
    store
    event
  end

  def events_file
    File.join(Project.project_metadata_dir(@project_id), 'events.yml')
  end

  private

  def load_events
    data = self.class.load_from_file(events_file) || []
    data.select { |attrs| attrs.is_a?(Hash) }.map { |attrs| Event.from_hash(attrs) }
  rescue => e
    LoggingCommon.log_error('Cannot load events', { file: path }, e)
    []
  end

  def to_yaml
    @events.map { |e| e.to_h.deep_stringify_keys }.to_yaml
  end

  def store
    store_to_file(events_file)
  end
end
