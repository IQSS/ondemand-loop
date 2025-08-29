# frozen_string_literal: true

require 'test_helper'

class UploadActionsViewTest < ActionView::TestCase
  include ModelHelper

  test 'renders edit upload bundle name button' do
    project = create_project
    bundle = create_upload_bundle(project)

    html = render partial: 'projects/show/upload_actions', locals: { project: project, bundle: bundle, file_browser_id: 'fb', file_target_id: 'ft' }

    assert_includes html, t('projects.show.upload_actions.button_edit_bundle_name_title')
      assert_includes html, 'data-controller="update-inline-field"'
      assert_includes html, 'data-update-inline-field-field-name-value="name"'
      assert_includes html, 'data-update-inline-field-method-value="PUT"'
    end
  end
