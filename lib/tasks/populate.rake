# lib/tasks/load_fixtures.rake

namespace :dev do
  desc "Populates the application folder with data to use the application as a developer"
  task populate: :environment do
    FIXTURE_PATH = File.expand_path("../../../test/fixtures", __FILE__)

    def load_file_fixture(name)
      path = File.join(FIXTURE_PATH, name)
      File.read(path)
    end

    parsed_url = URI.parse("http://localhost:3000")
    dataverse_metadata = Dataverse::DataverseMetadata.find_or_initialize_by_uri(parsed_url)

    valid_json = load_file_fixture(File.join('dataverse', 'dataset_response', 'valid_response.json'))
    dataset = Dataverse::DatasetResponse.new(valid_json)
    file_ids = [7]
    files = dataset.files_by_ids(file_ids)

    download_collection = DownloadCollection.new_from_dataverse(dataverse_metadata)
    download_collection.name = "#{dataverse_metadata.full_hostname} Dataverse selection from #{dataset.data.identifier}"
    download_collection.save

    files.each do |file|
      download_file = DownloadFile.new_from_dataverse_file(download_collection, file)
      download_file.save

      download_file2 = DownloadFile.new_from_dataverse_file(download_collection, file)
      download_file2.status = 'downloading'
      download_file2.filename = "another_file_being_downloaded.png"
      download_file2.save

      download_file3 = DownloadFile.new_from_dataverse_file(download_collection, file)
      download_file3.status = 'success'
      download_file3.filename = "yet_another_file_downloaded.png"
      download_file3.save

      download_file4 = DownloadFile.new_from_dataverse_file(download_collection, file)
      download_file4.status = 'error'
      download_file4.filename = "a_file_with_error.png"
      download_file4.save
    end
  end
end
