# frozen_string_literal: true
require 'test_helper'

class DataverseCommonHelperTest < ActionView::TestCase
  include Dataverse::CommonHelper

  test 'current_dataverse_url from param dataverse_url' do
    @controller.params = { dataverse_url: 'https://host:8443' }
    assert_equal 'https://host:8443', current_dataverse_url
  end

  test 'current_dataverse_url from hostname params' do
    @controller.params = { dv_hostname: 'host', dv_scheme: 'http', dv_port: 81 }
    assert_equal 'http://host:81', current_dataverse_url
  end

  test 'current_dataverse_url returns nil when missing' do
    @controller.params = {}
    self.expects(:redirect_to).with(root_path)
    assert_nil current_dataverse_url
  end
end
