# frozen_string_literal: true

module Dataverse
  class DownloadConnectorStatus

    attr_reader :file, :connector_metadata

    def initialize(file)
      @file = file
      @connector_metadata = file.connector_metadata
    end

    def download_progress
      return 0 if FileStatus.new_statuses.include?(file.status)
      return 100 if FileStatus.completed_statuses.include?(file.status)

      return 100 if File.exist?(file.download_location)

      temp_location = connector_metadata.temp_location
      file_size = file.size
      return 0 unless File.exist?(temp_location) && file_size.to_i.positive?

      downloaded_size = File.size(temp_location)
      [(downloaded_size.to_f / file_size * 100).to_i, 100].min
    end

  end
end
