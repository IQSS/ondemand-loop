# frozen_string_literal: true

module Dataverse
  class ConnectorStatus

    attr_reader :file, :connector_metadata

    def initialize(file)
      @file = file
      @connector_metadata = file.connector_metadata
    end

    def download_progress
      download_location = connector_metadata.temp_location
      file_size = file.size
      return 0 unless File.exist?(download_location) && file_size.to_i.positive?

      downloaded_size = File.size(download_location)
      [(downloaded_size.to_f / file_size * 100).to_i, 100].min
    end

  end
end
