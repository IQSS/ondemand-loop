# frozen_string_literal: true
module Download
  # Returns a download service based on the files to download.
  # This is used to select the appropriate connector service
  class DownloadFactory

    def self.download_connector(file)
      if file.type == 'dataverse'
        return Download::DataverseDownload.new
      end

      raise ConnectorNotImplemented, "File type not supported: #{file.type}"
    end

  end

  class ConnectorNotImplemented < StandardError
    def initialize(msg)
      super
    end
  end
end
