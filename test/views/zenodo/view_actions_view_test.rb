# frozen_string_literal: true

require 'test_helper'

class ZenodoViewActionsViewTest < ActionView::TestCase
  test 'renders dataset title and external link' do
    html = render partial: 'connectors/zenodo/shared/zenodo_view_actions', locals: {
      dataset_title: 'Dataset',
      external_zenodo_url: 'https://zenodo.org/records/1'
    }

    assert_includes html, 'Dataset'
    assert_includes html, 'https://zenodo.org/records/1'
  end
end
