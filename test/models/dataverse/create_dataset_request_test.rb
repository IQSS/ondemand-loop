require 'test_helper'

class Dataverse::CreateDatasetRequestTest < ActiveSupport::TestCase
  test 'to_body contains provided fields' do
    req = Dataverse::CreateDatasetRequest.new(title: 'Title', description: 'Desc', author: 'Me', contact_email: 'me@example.com', subjects: ['Bio'])
    body = JSON.parse(req.to_body)
    citation = body['datasetVersion']['metadataBlocks']['citation']['fields']
    title_field = citation.find { |f| f['typeName'] == 'title' }
    assert_equal 'Title', title_field['value']
  end
end
