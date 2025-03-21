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
    download_collection.save

    files.each do |file|
      download_file = DownloadFile.new_from_dataverse_file(download_collection, file)
      puts download_file.errors.inspect unless download_file.save
    end
  end
end
