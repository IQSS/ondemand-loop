class Event
  include ActiveModel::Model

  ATTRIBUTES = %w[id project_id message entity_type entity_id creation_date metadata].freeze

  attr_reader(*ATTRIBUTES)

  validates_presence_of :id, :project_id, :message, :entity_type, :creation_date

  def initialize(project_id:, entity_type:, entity_id: nil, message:, metadata: {}, id: nil, creation_date: nil)
    @id = id || SecureRandom.uuid.to_s
    @project_id = project_id
    @entity_type = entity_type.to_s.downcase
    @entity_id = entity_id
    @message = message
    @creation_date = creation_date || DateTimeCommon.now
    @metadata = metadata || {}
  end

  def to_h
    ATTRIBUTES.each_with_object({}) do |attr, hash|
      hash[attr.to_s] = public_send(attr)
    end
  end

  def self.from_hash(data)
    new(project_id: data['project_id'],
        entity_type: data['entity_type'].to_s.downcase,
        entity_id: data['entity_id'],
        message: data['message'],
        metadata: data['metadata'],
        id: data['id'],
        creation_date: data['creation_date'])
  end
end
