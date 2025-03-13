class Dataverse::DatasetController < ApplicationController
  def show
    @dataverse_metadata = Dataverse::DataverseMetadata.find(params[:metadata_id])
    service = Dataverse::DataverseService.new(@dataverse_metadata)
    @dataset = service.find_dataset_by_id(params[:id])
    @files = @dataset.data.latest_version.files
  end
end
