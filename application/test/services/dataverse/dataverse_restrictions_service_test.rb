# frozen_string_literal: true

require 'test_helper'

class Dataverse::DataverseRestrictionsServiceTest < ActiveSupport::TestCase
  def setup
    # No specific setup needed for now, we initialize defaults in the tests themselves
  end

  test 'should validate dataset always as valid since there is no limit on the file count' do
    # Create a mock dataset
    dataset = mock('dataset')
    validation_service = Dataverse::DataverseRestrictionsService.new
    response = validation_service.validate_dataset(dataset)

    assert response.valid?, 'Dataset should be always valid'
    assert_nil response.message, 'There should be no error message for valid dataset'
  end

  test 'should return invalid file for being restricted' do
    file = mock('file')
    data_file = mock('data_file')
    file.stubs(:restricted).returns(true)
    file.stubs(:data_file).returns(data_file)

    validation_service = Dataverse::DataverseRestrictionsService.new
    response = validation_service.validate_dataset_file(file)

    assert_not response.valid?, 'File should be invalid when restricted'
    assert_equal "File is restricted. Restricted files not supported", response.message
  end

  test 'should validate file within max_size constraint' do
    # Create a mock file with valid file size
    file = mock('file')
    data_file = mock('data_file')
    file.stubs(:restricted).returns(false)
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
    file.stubs(:restricted).returns(false)
    file.stubs(:data_file).returns(data_file)
    data_file.stubs(:filesize).returns(11.gigabytes) # More than max_file_size

    validation_service = Dataverse::DataverseRestrictionsService.new
    response = validation_service.validate_dataset_file(file)

    assert_not response.valid?, 'File should be invalid when size exceeds the limit'
    assert_equal 'Files bigger than 10 GB are not supported', response.message, 'Message should indicate the file size limit exceeded'
  end

  test 'should validate file size constraint with custom restrictions' do
    # Test with custom restrictions for max file size
    custom_restrictions = {
      max_file_size: 5.gigabytes
    }

    file = mock('file')
    data_file = mock('data_file')
    file.stubs(:restricted).returns(false)
    file.stubs(:data_file).returns(data_file)
    data_file.stubs(:filesize).returns(6.gigabytes) # More than 5 GB

    validation_service = Dataverse::DataverseRestrictionsService.new(dataverse_restrictions: custom_restrictions)
    response = validation_service.validate_dataset_file(file)

    assert_not response.valid?, 'File should be invalid when size exceeds the custom max file size'
    assert_equal 'Files bigger than 5 GB are not supported', response.message, 'Message should indicate the custom file size limit exceeded'
  end

end
