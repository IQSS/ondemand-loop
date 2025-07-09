module Dataverse
  class UploadFileResponse
    attr_reader :status, :data

    def initialize(json)
      parsed = JSON.parse(json, symbolize_names: true)
      @status = parsed[:status]
      @data = Data.new(parsed[:data])
    end

    class Data
      attr_reader :files

      def initialize(data)
        data ||= {}
        @files = (data[:files] || []).map { |file| UploadedFile.new(file) }
      end
    end

    class UploadedFile
      attr_reader :description, :label, :restricted, :version,
                  :dataset_version_id, :data_file

      def initialize(file)
        file ||= {}
        @description = file[:description]
        @label = file[:label]
        @restricted = file[:restricted]
        @version = file[:version]
        @dataset_version_id = file[:datasetVersionId]
        @data_file = DataFile.new(file[:dataFile])
      end
    end

    class DataFile
      attr_reader :id, :persistent_id, :pid_url, :filename, :content_type,
                  :friendly_type, :filesize, :description, :storage_identifier,
                  :root_data_file_id, :md5, :checksum, :tabular_data,
                  :creation_date, :file_access_request

      def initialize(data_file)
        data_file ||= {}
        @id = data_file[:id]
        @persistent_id = data_file[:persistentId]
        @pid_url = data_file[:pidURL]
        @filename = data_file[:filename]
        @content_type = data_file[:contentType]
        @friendly_type = data_file[:friendlyType]
        @filesize = data_file[:filesize]
        @description = data_file[:description]
        @storage_identifier = data_file[:storageIdentifier]
        @root_data_file_id = data_file[:rootDataFileId]
        @md5 = data_file[:md5]
        @checksum = data_file[:checksum]
        @tabular_data = data_file[:tabularData]
        @creation_date = data_file[:creationDate]
        @file_access_request = data_file[:fileAccessRequest]
      end
    end
  end
end
