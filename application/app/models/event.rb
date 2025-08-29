# frozen_string_literal: true

class Event
  include ActiveModel::Model
  include YamlStorageCommon

  ENTITY_TYPES = %w[project download_file upload_bundle upload_file].freeze
  ATTRIBUTES = %w[id project_id message entity_type entity_id creation_date metadata].freeze

  attr_accessor(*ATTRIBUTES)

  validates_presence_of :id, :project_id, :message, :entity_type, :creation_date

  def initialize(attributes = {})
    super
    self.id = SecureRandom.uuid.to_s
    self.creation_date = DateTimeCommon.now
    self.metadata ||= {}
  end

  def self.for_project(project_id)
    path = Project.events_file(project_id)
    data = load_from_file(path) || []
    data.select { |attrs| attrs.is_a?(Hash) }.map { |attrs| load_from_hash(attrs) }
  rescue => e
    LoggingCommon.log_error("Cannot load events", { file: path }, e)
    []
  end

  def save
    return false unless valid?

    events = self.class.for_project(project_id)
    events << self
    LoggingCommon.log_info("Event to be saved", events: events)
    self.class.store_events(project_id, events)
  end

  def to_h
    h = {}
    ATTRIBUTES.each do |attr|
      h[attr.to_s] = send(attr)
    end
    h
  end

  private

  def self.load_from_hash(data)
    new.tap do |instance|
      ATTRIBUTES.each do |attr|
        value = data[attr.to_s]
        instance.public_send("#{attr}=", value)
      end
    end
  end

  def self.store_events(project_id, events)
    path = Project.events_file(project_id)
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') { |f| f.write(events.map(&:to_h).to_yaml) }
    true
  rescue => e
    LoggingCommon.log_error("Cannot store events", { file: path }, e)
    false
  end
end
