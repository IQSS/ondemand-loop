require "test_helper"

class EventTest < ActiveSupport::TestCase

  test "initializes defaults" do
    event = Event.new(project_id: 'p1',
                      entity_type: 'project',
                      entity_id: nil,
                      message: 'message')
    assert event.id.present?
    assert event.creation_date.present?
    assert_equal({}, event.metadata)
  end

  test "to_h and from_hash preserve metadata" do
    metadata = { 'foo' => 'bar', 'count' => 1 }
    event = Event.new(project_id: 'p1',
                      entity_type: 'file',
                      entity_id: 'e1',
                      message: 'm',
                      metadata: metadata)

    hash = event.to_h
    assert_equal metadata, hash['metadata']

    reconstructed = Event.from_hash(hash)
    assert_equal metadata, reconstructed.metadata
    assert_equal event.message, reconstructed.message
    assert_equal event.entity_id, reconstructed.entity_id
  end

  test "attributes are read-only" do
    event = Event.new(project_id: 'p1', entity_type: 'project', message: 'm')
    assert_raises(NoMethodError) { event.id = 'new-id' }
    assert_raises(NoMethodError) { event.project_id = 'other' }
    assert_raises(NoMethodError) { event.metadata = {} }
  end

  test "constructor accepts optional id parameter" do
    custom_id = 'custom-uuid-123'
    event = Event.new(project_id: 'p1',
                      entity_type: 'project',
                      message: 'message',
                      id: custom_id)
    
    assert_equal custom_id, event.id
    assert event.creation_date.present?
  end

  test "constructor accepts optional creation_date parameter" do
    custom_date = '2023-01-15 10:30:00'
    event = Event.new(project_id: 'p1',
                      entity_type: 'project', 
                      message: 'message',
                      creation_date: custom_date)
    
    assert event.id.present?
    assert_equal custom_date, event.creation_date
  end

  test "constructor accepts both optional id and creation_date parameters" do
    custom_id = 'custom-uuid-456'
    custom_date = '2023-02-20 15:45:30'
    
    event = Event.new(project_id: 'p1',
                      entity_type: 'file',
                      entity_id: 'e1',
                      message: 'test message',
                      metadata: { 'key' => 'value' },
                      id: custom_id,
                      creation_date: custom_date)
    
    assert_equal custom_id, event.id
    assert_equal custom_date, event.creation_date
    assert_equal 'p1', event.project_id
    assert_equal 'file', event.entity_type
    assert_equal 'e1', event.entity_id
    assert_equal 'test message', event.message
    assert_equal({ 'key' => 'value' }, event.metadata)
  end

  test "from_hash uses constructor with id and creation_date" do
    original_event = Event.new(project_id: 'p1',
                               entity_type: 'project',
                               entity_id: 'e1',
                               message: 'original message',
                               metadata: { 'foo' => 'bar' })
    
    hash = original_event.to_h
    reconstructed = Event.from_hash(hash)
    
    # Verify all attributes match exactly
    assert_equal original_event.id, reconstructed.id
    assert_equal original_event.creation_date, reconstructed.creation_date
    assert_equal original_event.project_id, reconstructed.project_id
    assert_equal original_event.entity_type, reconstructed.entity_type
    assert_equal original_event.entity_id, reconstructed.entity_id
    assert_equal original_event.message, reconstructed.message
    assert_equal original_event.metadata, reconstructed.metadata
  end

end

