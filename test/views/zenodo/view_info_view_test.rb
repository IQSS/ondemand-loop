# frozen_string_literal: true

require 'test_helper'

class ZenodoViewInfoViewTest < ActionView::TestCase
  test 'renders draft badge for draft dataset' do
    draft_dataset = Struct.new(:id, :title, :description, :publication_date, :files) do
      def draft?
        true
      end
    end.new('10', 'Title', '', '', [])

    html = render partial: 'connectors/zenodo/shared/zenodo_view_info', locals: { dataset: draft_dataset }

    assert_includes html, 'badge text-bg-info'
    assert_includes html, I18n.t('connectors.zenodo.shared.zenodo_view_info.badge_draft_text')
  end

  test 'renders published badge when not draft' do
    published_dataset = Struct.new(:id, :title, :description, :publication_date, :files) do
      def draft?
        false
      end
    end.new('10', 'Title', '', '', [])

    html = render partial: 'connectors/zenodo/shared/zenodo_view_info', locals: { dataset: published_dataset }

    assert_includes html, 'badge text-bg-info'
    assert_includes html, I18n.t('connectors.zenodo.shared.zenodo_view_info.badge_published_text')
  end
end
