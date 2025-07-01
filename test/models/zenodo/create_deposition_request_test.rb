require 'test_helper'

class Zenodo::CreateDepositionRequestTest < ActiveSupport::TestCase
  test 'to_h returns compacted attributes' do
    req = Zenodo::CreateDepositionRequest.new(title: 't', upload_type: 'software', description: 'd', creators: [{name: 'me'}], keywords: ['k'], publication_date: '2024-01-01')
    h = req.to_h
    assert_equal 't', h[:title]
    assert_equal 'software', h[:upload_type]
    assert_equal ['k'], h[:keywords]
  end
end
