# frozen_string_literal: true

require 'ostruct'

module Dataverse
  class DataverseRestrictionsService
    attr_reader :dataverse_restrictions

    DEFAULT_RESTRICTIONS = {
      max_dataset_files: 100,
      max_file_size: 10.gigabytes
    }

    def initialize(dataverse_restrictions: nil)
      values = dataverse_restrictions || DEFAULT_RESTRICTIONS
      @dataverse_restrictions = OpenStruct.new(values.symbolize_keys)
    end

    def validate_dataset(dataset)
      response = { valid?: true, message: nil }
      if dataset.files.size > dataverse_restrictions.max_dataset_files
        response = {
          valid?: false,
          message: "Datasets with more than #{dataverse_restrictions.max_dataset_files} files are not supported"
        }
      end

      OpenStruct.new(response)
    end

    def validate_dataset_file(file)
      response = { valid?: true, message: nil }
      if file.data_file.filesize > dataverse_restrictions.max_file_size
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
