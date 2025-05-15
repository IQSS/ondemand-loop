# frozen_string_literal: true

module Dataverse
  class UploadConnectorMetadata < UploadCollectionConnectorMetadata
    def initialize(upload_file)
      super(upload_file.upload_collection)
    end
  end
end
