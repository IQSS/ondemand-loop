# frozen_string_literal: true

module Dataverse
  class UploadConnectorMetadata < UploadBatchConnectorMetadata
    def initialize(upload_file)
      super(upload_file.upload_batch)
    end
  end
end
