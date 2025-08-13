require 'test_helper'

class ZenodoRecordsHelperTest < ActionView::TestCase
  include Zenodo::RecordsHelper

  test 'external_record_url uses default base url' do
    assert_equal 'https://zenodo.org/records/123', external_record_url(123)
  end

  test 'external_record_url uses custom base url' do
    assert_equal 'https://sandbox.zenodo.org/records/1', external_record_url(1, 'https://sandbox.zenodo.org')
  end
end
