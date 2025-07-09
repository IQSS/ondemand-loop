require "test_helper"

class Dataverse::UploadFileResponseTest < ActiveSupport::TestCase
  def setup
    json = load_file_fixture(File.join('dataverse', 'upload_file_response', 'valid_response.json'))
    @response = Dataverse::UploadFileResponse.new(json)
  end

  test "parses upload file response" do
    assert_equal 'OK', @response.status
    assert_equal 1, @response.data.files.size
    file = @response.data.files.first
    assert_equal 'bolide-01_02-Nov-1960_1.tar', file.label
    assert_equal 2657799, file.data_file.id
    assert_equal 265678336, file.data_file.filesize
    assert_equal '5f02321dba2a37355a9f1f810565c1c8', file.data_file.md5
  end
end
