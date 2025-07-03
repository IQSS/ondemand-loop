# frozen_string_literal: true
require 'test_helper'

class Dataverse::ExternalToolControllerTest < ActionDispatch::IntegrationTest
  test 'should redirect with alert if dataverse_url is missing or invalid' do
    get integrations_dataverse_external_tool_dataset_path, params: { dataset_id: '123' }

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.external_tool.dataset.invalid_request_error'), flash[:alert]
  end

  test 'should redirect with alert if dataset_id is missing' do
    get integrations_dataverse_external_tool_dataset_path, params: { dataverse_url: 'https://demo.dataverse.org' }

    assert_redirected_to root_path
    assert_equal I18n.t('dataverse.external_tool.dataset.invalid_request_error'), flash[:alert]
  end

  test 'should redirect to dataset view with parsed dataverse_url' do
    get integrations_dataverse_external_tool_dataset_path, params: {
      dataverse_url: 'https://demo.dataverse.org:443',
      dataset_id: 'abc-123',
      version: '1.0',
      locale: 'en'
    }

    assert_redirected_to view_dataverse_dataset_path('demo.dataverse.org', 'abc-123')
  end

  test 'should redirect to dataset view with overrides' do
    get integrations_dataverse_external_tool_dataset_path, params: {
      dataverse_url: 'http://demo.dataverse.org:8080',
      dataset_id: 'abc-123',
      version: '1.0',
      locale: 'en'
    }

    assert_redirected_to view_dataverse_dataset_path('demo.dataverse.org', 'abc-123', dv_scheme: 'http', dv_port: '8080')
  end
end
