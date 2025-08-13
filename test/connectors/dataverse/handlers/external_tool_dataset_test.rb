require 'test_helper'

class Dataverse::Handlers::ExternalToolDatasetTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  def setup
    @handler = Dataverse::Handlers::ExternalToolDataset.new
  end

  test 'returns error when dataverse_url is missing or invalid' do
    result = @handler.show({ dataset_id: '123' })
    refute result.success?
    assert_equal I18n.t('connectors.dataverse.external_tool_dataset.show.invalid_request_error'), result.message[:alert]
  end

  test 'returns error when dataset_id is missing' do
    result = @handler.show({ dataverse_url: 'https://demo.dataverse.org' })
    refute result.success?
    assert_equal I18n.t('connectors.dataverse.external_tool_dataset.show.invalid_request_error'), result.message[:alert]
  end

  test 'redirects to dataset view with parsed dataverse_url' do
    result = @handler.show({
      dataverse_url: 'https://demo.dataverse.org:443',
      dataset_id: 'abc-123',
      version: '1.0',
      locale: 'en'
    })

    expected = explore_path(
      connector_type: ConnectorType::DATAVERSE.to_s,
      server_domain: 'demo.dataverse.org',
      object_type: 'datasets',
      object_id: 'abc-123',
      version: '1.0'
    )
    assert result.success?
    assert_equal expected, result.redirect_url
  end

  test 'redirects to dataset view with overrides' do
    result = @handler.show({
      dataverse_url: 'http://demo.dataverse.org:8080',
      dataset_id: 'abc-123',
      version: '1.0',
      locale: 'en'
    })

    expected = explore_path(
      connector_type: ConnectorType::DATAVERSE.to_s,
      server_domain: 'demo.dataverse.org',
      server_scheme: 'http',
      server_port: '8080',
      object_type: 'datasets',
      object_id: 'abc-123',
      version: '1.0'
    )
    assert result.success?
    assert_equal expected, result.redirect_url
  end
end
