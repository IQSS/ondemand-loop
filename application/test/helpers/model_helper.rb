module ModelHelper

  def download_project(type: ConnectorType::DATAVERSE, files:)
    Project.new(id: random_id, name: 'test_project').tap do |project|
      download_files = Array.new(files) { create_download_file(project, type: type) }
      project.stubs(:files).returns(download_files)
    end
  end

  def create_download_project
    Project.new(id: random_id, name: 'test_project')
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

  def create_upload_project
    Project.new(id: random_id, name: 'test_project')
  end

  def create_upload_file(project, type: ConnectorType::DATAVERSE)
    UploadFile.new.tap do |file|
      file.id = random_id
      file.project_id = project.id
      file.type = type
      file.filename = "#{random_id}.txt"
      file.status = FileStatus::PENDING
      file.size = 200
      file.metadata = {test: 'test'}
    end
  end
  def random_id
    SecureRandom.uuid.to_s
  end

  def file_now
    Time.now.strftime('%Y-%m-%dT%H:%M:%S')
  end
end
