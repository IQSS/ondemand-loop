# frozen_string_literal: true
require 'test_helper'

class ConnectorHelperTest < ActionView::TestCase
  include ConnectorHelper

  test 'info and actions bar paths use connector type' do
    project = create_project
    bundle = create_upload_bundle(project, type: ConnectorType::ZENODO)
    assert_equal '/connectors/zenodo/upload_bundle_info_bar', upload_bundle_connector_info_bar(bundle)
    assert_equal '/connectors/zenodo/upload_bundle_actions_bar', upload_bundle_connector_actions_bar(bundle)

    bundle = create_upload_bundle(project, type: ConnectorType::DATAVERSE)
    assert_equal '/connectors/dataverse/upload_bundle_info_bar', upload_bundle_connector_info_bar(bundle)
    assert_equal '/connectors/dataverse/upload_bundle_actions_bar', upload_bundle_connector_actions_bar(bundle)
  end

  test 'connector_icon renders svg image tag' do
    html = connector_icon(ConnectorType::DATAVERSE)
    assert_includes html, 'dataverse.svg'
    assert_includes html, 'aria-label'

    html = connector_icon(ConnectorType::ZENODO)
    assert_includes html, 'zenodo.svg'
    assert_includes html, 'aria-label'
  end

  test 'api_key_status_badge shows success or danger' do
    badge = api_key_status_badge(ConnectorType::DATAVERSE, true)
    assert_includes badge, 'badge-soft-success'
    assert_includes badge, I18n.t('helpers.dataverse.badge_key_present_text')

    badge = api_key_status_badge(ConnectorType::DATAVERSE, false)
    assert_includes badge, 'badge-soft-danger'
    assert_includes badge, I18n.t('helpers.dataverse.badge_key_missing_text')

    badge = api_key_status_badge(ConnectorType::ZENODO, true)
    assert_includes badge, 'badge-soft-success'
    assert_includes badge, I18n.t('helpers.zenodo.badge_key_present_text')

    badge = api_key_status_badge(ConnectorType::ZENODO, false)
    assert_includes badge, 'badge-soft-danger'
    assert_includes badge, I18n.t('helpers.zenodo.badge_key_missing_text')
  end
end
