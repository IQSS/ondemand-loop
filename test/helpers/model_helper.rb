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
      upload_bundle = create_upload_bundle(project, type: type)
      upload_files = Array.new(files) { create_upload_file(project, upload_bundle) }
      upload_bundle.stubs(:files).returns(upload_files)
      project.stubs(:upload_bundles).returns([upload_bundle])
    end
  end

  def create_upload_bundle(project, id: random_id, type: ConnectorType::DATAVERSE, files: [])
    UploadBundle.new.tap do |upload_bundle|
      upload_bundle.project_id = project.id
      upload_bundle.id = id
      upload_bundle.name = "sample name"
      upload_bundle.type = type
      upload_bundle.metadata = {test: 'test'}
      upload_bundle.stubs(:files).returns(files)
    end
  end

  def create_upload_file(project, upload_bundle)
    UploadFile.new.tap do |file|
      file.id = random_id
      file.project_id = project.id
      file.upload_bundle_id = upload_bundle.id
      file.filename = "#{random_id}.txt"
      file.status = FileStatus::PENDING
      file.size = 200
      file.stubs(:upload_bundle).returns(upload_bundle)
    end
  end
  def random_id
    SecureRandom.uuid.to_s
  end

  def file_now
    Time.now.strftime('%Y-%m-%dT%H:%M:%S')
  end
end
