# frozen_string_literal: true
require 'test_helper'

class FileDropHelperTest < ActionView::TestCase
  include FileDropHelper

  test 'builds element ids from bundle' do
    bundle = create_upload_bundle(create_project)
    assert_equal "fbt-#{bundle.id}", file_drop_target_id(bundle)
    assert_equal "fb-#{bundle.id}", file_drop_browser_id(bundle)
  end
end
