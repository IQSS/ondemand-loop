module ModelHelper

  def create_project
    Project.new(id: random_id, name: 'test_project')
  end
  def download_project(type: ConnectorType::DATAVERSE, files:)
    create_project.tap do |project|
      download_files = Array.new(files) { create_download_file(project, type: type) }
      project.stubs(:download_files).returns(download_files)
    end
  end

  def create_download_file(project, id: nil, type: ConnectorType::DATAVERSE)
    DownloadFile.new.tap do |file|
      file.id = id || random_id
      file.project_id = project.id
      file.type = type
      file.filename = "#{random_id}.txt"
      file.status = FileStatus::PENDING
      file.size = 200
      file.metadata = {test: 'test'}
    end
  end

  def upload_project(type: ConnectorType::DATAVERSE, files:)
    create_project.tap do |project|
      upload_batch = create_upload_batch(project, type: type)
      upload_files = Array.new(files) { create_upload_file(project, upload_batch, type: type) }
      upload_batch.stubs(:files).returns(upload_files)
      project.stubs(:upload_batches).returns([upload_batch])
    end
  end

  def create_upload_batch(project, id: random_id, type: ConnectorType::DATAVERSE, files: [])
    UploadBatch.new.tap do |upload_batch|
      upload_batch.project_id = project.id
      upload_batch.id = id
      upload_batch.name = "sample name"
      upload_batch.type = type
      upload_batch.metadata = {test: 'test'}
      upload_batch.stubs(:files).returns(files)
    end
  end

  def create_upload_file(project, upload_batch, type: ConnectorType::DATAVERSE)
    UploadFile.new.tap do |file|
      file.id = random_id
      file.project_id = project.id
      file.upload_batch_id = upload_batch.id
      file.type = type
      file.filename = "#{random_id}.txt"
      file.status = FileStatus::PENDING
      file.size = 200
      file.stubs(:upload_batch).returns(upload_batch)
    end
  end
  def random_id
    SecureRandom.uuid.to_s
  end

  def file_now
    Time.now.strftime('%Y-%m-%dT%H:%M:%S')
  end
end
