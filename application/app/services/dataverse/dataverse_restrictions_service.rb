# frozen_string_literal: true


module Dataverse
  class DataverseRestrictionsService
    attr_reader :dataverse_restrictions

    DEFAULT_RESTRICTIONS = {
      max_file_size: 10.gigabytes
    }

    def initialize(dataverse_restrictions: nil)
      values = dataverse_restrictions || DEFAULT_RESTRICTIONS
      @dataverse_restrictions = OpenStruct.new(values.symbolize_keys)
    end

    def validate_dataset(dataset)
      response = { valid?: true, message: nil }
      OpenStruct.new(response)
    end

    def validate_dataset_file(file)
      response = { valid?: true, message: nil }
      if file.data_file.nil?
        response = {
          valid?: false,
          message: "File data is not present"
        }
      end

      if file&.data_file&.filesize and file.data_file.filesize > dataverse_restrictions.max_file_size
        helpers = ActionController::Base.helpers
        response = {
          valid?: false,
          message: "Files bigger than #{helpers.number_to_human_size(dataverse_restrictions.max_file_size)} are not supported"
        }
      end

      OpenStruct.new(response)
    end
  end
end
