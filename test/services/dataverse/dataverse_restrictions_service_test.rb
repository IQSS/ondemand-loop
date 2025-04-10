# frozen_string_literal: true

require 'test_helper'

class Dataverse::DataverseRestrictionsServiceTest < ActiveSupport::TestCase
  def setup
    # No specific setup needed for now, we initialize defaults in the tests themselves
  end

  test 'should validate dataset within max_files constraint' do
    # Create a mock dataset with valid number of files
    dataset = mock('dataset')
    dataset.stubs(:files).returns(Array.new(99)) # Less than max_dataset_files

    validation_service = Dataverse::DataverseRestrictionsService.new
    response = validation_service.validate_dataset(dataset)

    assert response.valid?, 'Dataset should be valid when file count is within the limit'
    assert_nil response.message, 'There should be no error message for valid dataset'
  end

  test 'should return invalid dataset for exceeding max_files constraint' do
    # Create a mock dataset with files exceeding the limit
    dataset = mock('dataset')
    dataset.stubs(:files).returns(Array.new(101)) # More than max_dataset_files

    validation_service = Dataverse::DataverseRestrictionsService.new
    response = validation_service.validate_dataset(dataset)

    assert_not response.valid?, 'Dataset should be invalid when file count exceeds the limit'
    assert_equal response.message, 'Datasets with more than 100 files are not supported', 'Message should indicate the file limit exceeded'
  end

  test 'should validate file within max_size constraint' do
    # Create a mock file with valid file size
    file = mock('file')
    data_file = mock('data_file')
    file.stubs(:data_file).returns(data_file)
    data_file.stubs(:filesize).returns(9.gigabytes) # Less than max_file_size

    validation_service = Dataverse::DataverseRestrictionsService.new
    response = validation_service.validate_dataset_file(file)

    assert response.valid?, 'File should be valid when size is within the limit'
    assert_nil response.message, 'There should be no error message for valid file'
  end

  test 'should return invalid file for exceeding max_size constraint' do
    # Create a mock file with size exceeding the limit
    file = mock('file')
    data_file = mock('data_file')
    file.stubs(:data_file).returns(data_file)
    data_file.stubs(:filesize).returns(11.gigabytes) # More than max_file_size

    validation_service = Dataverse::DataverseRestrictionsService.new
    response = validation_service.validate_dataset_file(file)

    assert_not response.valid?, 'File should be invalid when size exceeds the limit'
    assert_equal response.message, 'Files bigger than 10 GB are not supported', 'Message should indicate the file size limit exceeded'
  end

  test 'should validate file size constraint with custom restrictions' do
    # Test with custom restrictions for max file size
    custom_restrictions = {
      max_dataset_files: 100,
      max_file_size: 5.gigabytes
    }

    file = mock('file')
    data_file = mock('data_file')
    file.stubs(:data_file).returns(data_file)
    data_file.stubs(:filesize).returns(6.gigabytes) # More than 5 GB

    validation_service = Dataverse::DataverseRestrictionsService.new(dataverse_restrictions: custom_restrictions)
    response = validation_service.validate_dataset_file(file)

    assert_not response.valid?, 'File should be invalid when size exceeds the custom max file size'
    assert_equal response.message, 'Files bigger than 5 GB are not supported', 'Message should indicate the custom file size limit exceeded'
  end

  test 'should handle empty file list in dataset' do
    # Create a mock dataset with no files
    dataset = mock('dataset')
    dataset.stubs(:files).returns([]) # No files

    validation_service = Dataverse::DataverseRestrictionsService.new
    response = validation_service.validate_dataset(dataset)

    assert response.valid?, 'Dataset should be valid with no files'
    assert_nil response.message, 'There should be no error message for empty dataset'
  end
end
