module Dataverse
  class DataverseService

    def initialize(dataverse_metadata)
      @dataverse_metadata = dataverse_metadata
    end

    def find_dataset_by_id(id)
      url = @dataverse_metadata.full_hostname + "/api/datasets/#{id}"
      url = URI.parse(url)
      response = Net::HTTP.get_response(url)
      response.is_a?(Net::HTTPSuccess) ? DatasetResponse.new(response.body) : nil
    end

  end
end