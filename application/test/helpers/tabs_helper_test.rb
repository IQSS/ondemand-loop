# frozen_string_literal: true
require 'test_helper'

class TabsHelperTest < ActionView::TestCase
  include TabsHelper

  test 'tab_label_for should return correct label ID for Project' do
    project = create_project
    assert_equal "tab-label-#{project.id}", tab_label_for(project)
  end

  test 'tab_anchor_for should return correct anchor ID for Project' do
    project = create_project
    assert_equal "tab-#{project.id}", tab_anchor_for(project)
  end

  test 'tab_href_for should return correct href for Project' do
    project = create_project
    assert_equal "#tab-#{project.id}", tab_href_for(project)
  end

  test 'tab_label_for should return correct label ID for UploadBatch' do
    batch = create_upload_bundle(create_project)
    assert_equal "tab-label-#{batch.id}", tab_label_for(batch)
  end

  test 'tab_anchor_for should return correct anchor ID for UploadBatch' do
    batch = create_upload_bundle(create_project)
    assert_equal "tab-#{batch.id}", tab_anchor_for(batch)
  end

  test 'tab_href_for should return correct href for UploadBatch' do
    batch = create_upload_bundle(create_project)
    assert_equal "#tab-#{batch.id}", tab_href_for(batch)
  end
end
