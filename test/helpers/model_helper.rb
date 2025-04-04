module ModelHelper

  def download_collection(type: 'dataverse', files:)
    DownloadCollection.new(id: random_id, name: 'test_collection').tap do |collection|
      download_files = Array.new(files) { create_download_file(collection, type: type) }
      collection.stubs(:files).returns(download_files)
    end
  end

  def create_download_collection
    DownloadCollection.new(id: random_id, name: 'test_collection')
  end

  def create_download_file(collection, type: 'dataverse')
    DownloadFile.new.tap do |file|
      file.id = random_id
      file.collection_id = collection.id
      file.type = type
      file.filename = "#{random_id}.txt"
      file.status = 'ready'
      file.status = 200
      file.metadata = {}
    end
  end

  def fixture_path(partial_path)
    File.join(__dir__, "..", "fixtures", partial_path)
  end

  def random_id
    SecureRandom.uuid.to_s
  end
end
