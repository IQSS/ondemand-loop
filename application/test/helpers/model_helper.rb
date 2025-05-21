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
      upload_collection = create_upload_collection(project, type: type)
      upload_files = Array.new(files) { create_upload_file(project, upload_collection, type: type) }
      upload_collection.stubs(:files).returns(upload_files)
      project.stubs(:upload_collections).returns([upload_collection])
    end
  end

  def create_upload_collection(project, id: random_id, type: ConnectorType::DATAVERSE, files: [])
    UploadCollection.new.tap do |collection|
      collection.project_id = project.id
      collection.id = id
      collection.name = "sample name"
      collection.type = type
      collection.metadata = {test: 'test'}
      collection.stubs(:files).returns(files)
    end
  end

  def create_upload_file(project, collection, type: ConnectorType::DATAVERSE)
    UploadFile.new.tap do |file|
      file.id = random_id
      file.project_id = project.id
      file.collection_id = collection.id
      file.type = type
      file.filename = "#{random_id}.txt"
      file.status = FileStatus::PENDING
      file.size = 200
      file.stubs(:upload_collection).returns(collection)
    end
  end
  def random_id
    SecureRandom.uuid.to_s
  end

  def file_now
    Time.now.strftime('%Y-%m-%dT%H:%M:%S')
  end
end
