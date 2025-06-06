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
    service = Dataverse::CollectionService.new(parsed_url.to_s)

    valid_json = load_file_fixture(File.join('dataverse', 'dataset_response', 'valid_response.json'))
    dataset = Dataverse::DatasetResponse.new(valid_json)
    file_ids = [7]

    download_collection = service.initialize_download_collection(dataset)
    download_collection.save

    files = service.initialize_download_files(download_collection, dataset, file_ids)
    files.each do |download_file|
      download_file.save
    end

    files = service.initialize_download_files(download_collection, dataset, file_ids)
    files.each do |download_file2|
      download_file2.status = 'downloading'
      download_file2.filename = "another_file_being_downloaded.png"
      download_file2.save
    end

    files = service.initialize_download_files(download_collection, dataset, file_ids)
    files.each do |download_file3|
      download_file3.status = 'success'
      download_file3.filename = "yet_another_file_downloaded.png"
      download_file3.save
    end

    files = service.initialize_download_files(download_collection, dataset, file_ids)
    files.each do |download_file4|
      download_file4.status = 'error'
      download_file4.filename = "a_file_with_error.png"
      download_file4.save
    end
  end
end
