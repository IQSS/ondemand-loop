# frozen_string_literal: true

module Dataverse
  class UploadConnectorMetadata < UploadBundleConnectorMetadata
    def initialize(upload_file)
      super(upload_file.upload_bundle)
    end
  end
end
