# frozen_string_literal: true

module EventLogger

  def log_project_event(project, message:, metadata: {})
    unless project.is_a?(Project)
      raise ArgumentError, "Expected Project model, got #{project.class}"
    end

    log_event(
      project_id: project.id,
      entity_type: 'Project',
      entity_id: project.id,
      message: message,
      metadata: metadata
    )
  end

  def log_download_file_event(file, message:, metadata: {})
    unless file.is_a?(DownloadFile)
      raise ArgumentError, "Expected DownloadFile model, got #{file.class}"
    end

    log_event(
      project_id: file.project_id,
      entity_type: 'download_file',
      entity_id: file.id,
      message: message,
      metadata: { filename: file.filename, status: file.status.to_s }.merge(metadata)
    )
  end

  def log_upload_file_event(file, message:, metadata: {})
    unless file.is_a?(UploadFile)
      raise ArgumentError, "Expected UploadFile model, got #{file.class}"
    end

    log_event(
      project_id: file.project_id,
      entity_type: 'upload_file',
      entity_id: file.id,
      message: message,
      metadata: { filename: file.filename, status: file.status.to_s }.merge(metadata)
    )
  end

  def log_event(project_id:, entity_type:, entity_id:, message:, metadata:)
    attributes = {
      project_id: project_id,
      entity_type: entity_type,
      entity_id: entity_id,
      message: message,
      metadata: metadata
    }

    list = ProjectEventList.new(project_id: project_id)
    event = Event.new(**attributes)
    event_saved = list.add(event)
    if event_saved
      LoggingCommon.log_info('Event saved', event_saved.to_h)
      true
    else
      LoggingCommon.log_error('Cannot log event', { event: attributes })
      false
    end
  rescue => e
    LoggingCommon.log_error('Cannot log event', attributes, e)
    false
  end

  module_function :log_project_event, :log_event
end
