# frozen_string_literal: true
module Download
  # Returns a download service based on the files to download.
  # This is used to select the appropriate connector service
  class DownloadFactory

    def self.download_connector(file)
      Download::DataverseDownload.new
    end

  end
end
