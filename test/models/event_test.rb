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

  test "to_h and from_hash preserve metadata with string conversion" do
    input_metadata = { 'foo' => 'bar', 'count' => 1 }
    expected_metadata = { 'foo' => 'bar', 'count' => '1' }  # count converted to string

    event = Event.new(project_id: 'p1',
                      entity_type: 'file',
                      entity_id: 'e1',
                      message: 'm',
                      metadata: input_metadata)

    hash = event.to_h
    assert_equal expected_metadata, hash['metadata']

    reconstructed = Event.from_hash(hash)
    assert_equal expected_metadata, reconstructed.metadata
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

  test "entity_type is normalized to downcase on creation" do
    event = Event.new(project_id: 'p1', entity_type: 'PROJECT', message: 'm')
    assert_equal 'project', event.entity_type
  end

  test "entity_type is normalized to downcase from_hash" do
    data = { 'project_id' => 'p1', 'entity_type' => 'FILE', 'message' => 'm' }
    event = Event.from_hash(data)
    assert_equal 'file', event.entity_type
  end

  test "entity_type handles symbols and converts to downcase string" do
    event = Event.new(project_id: 'p1', entity_type: :Bundle, message: 'm')
    assert_equal 'bundle', event.entity_type
  end

  test "metadata converts ConnectorType objects to strings in constructor" do
    metadata = {
      'connector_type' => ConnectorType::DATAVERSE,
      'other_connector' => ConnectorType::ZENODO,
      'normal_string' => 'test'
    }

    event = Event.new(project_id: 'p1', entity_type: 'project', message: 'm', metadata: metadata)

    assert_equal 'dataverse', event.metadata['connector_type']
    assert_equal 'zenodo', event.metadata['other_connector']
    assert_equal 'test', event.metadata['normal_string']
  end

  test "metadata converts FileStatus objects to strings in constructor" do
    metadata = {
      'file_status' => FileStatus::PENDING,
      'previous_status' => FileStatus::ERROR,
      'final_status' => FileStatus::SUCCESS,
      'count' => 42
    }

    event = Event.new(project_id: 'p1', entity_type: 'file', message: 'm', metadata: metadata)

    assert_equal 'pending', event.metadata['file_status']
    assert_equal 'error', event.metadata['previous_status']
    assert_equal 'success', event.metadata['final_status']
    assert_equal '42', event.metadata['count']
  end

  test "metadata converts mixed object types to strings in constructor" do
    metadata = {
      'connector_type' => ConnectorType::DATAVERSE,
      'file_status' => FileStatus::UPLOADING,
      'number' => 123,
      'boolean' => true,
      'symbol' => :test_symbol,
      'string' => 'already_string'
    }

    event = Event.new(project_id: 'p1', entity_type: 'bundle', message: 'm', metadata: metadata)

    assert_equal 'dataverse', event.metadata['connector_type']
    assert_equal 'uploading', event.metadata['file_status']
    assert_equal '123', event.metadata['number']
    assert_equal 'true', event.metadata['boolean']
    assert_equal 'test_symbol', event.metadata['symbol']
    assert_equal 'already_string', event.metadata['string']
  end

  test "metadata converts objects to strings when loaded from hash" do
    # Create original event with object metadata
    original_metadata = {
      'connector_type' => ConnectorType::ZENODO,
      'file_status' => FileStatus::CANCELLED,
      'count' => 99
    }

    original_event = Event.new(project_id: 'p1', entity_type: 'project', message: 'm', metadata: original_metadata)

    # Convert to hash and back
    hash = original_event.to_h
    reconstructed = Event.from_hash(hash)

    # Verify metadata objects are converted to strings
    assert_equal 'zenodo', reconstructed.metadata['connector_type']
    assert_equal 'cancelled', reconstructed.metadata['file_status']
    assert_equal '99', reconstructed.metadata['count']
  end

  test "metadata handles nil and empty values gracefully" do
    metadata = {
      'nil_value' => nil,
      'empty_string' => '',
      'connector_type' => ConnectorType::DATAVERSE
    }

    event = Event.new(project_id: 'p1', entity_type: 'file', message: 'm', metadata: metadata)

    assert_equal '', event.metadata['nil_value']
    assert_equal '', event.metadata['empty_string']
    assert_equal 'dataverse', event.metadata['connector_type']
  end

  test "from_hash with object metadata gets converted to strings" do
    # Simulate loading from hash with object values (this could happen from JSON parsing)
    hash_data = {
      'project_id' => 'p1',
      'entity_type' => 'FILE',  # Also test entity_type normalization
      'message' => 'test message',
      'metadata' => {
        'connector_type' => ConnectorType::DATAVERSE,
        'status' => FileStatus::DOWNLOADING,
        'numeric' => 456
      }
    }

    event = Event.from_hash(hash_data)

    assert_equal 'file', event.entity_type  # entity_type should be normalized
    assert_equal 'dataverse', event.metadata['connector_type']
    assert_equal 'downloading', event.metadata['status']
    assert_equal '456', event.metadata['numeric']
  end

end

