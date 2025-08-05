# frozen_string_literal: true

require 'test_helper'

class ZenodoRecordInfoViewTest < ActionView::TestCase
  test 'renders draft badge for draft record' do
    draft_record = Struct.new(:id, :title, :description, :publication_date, :files) do
      def draft?
        true
      end
    end.new('10', 'Title', '', '', [])

    html = render partial: 'zenodo/records/record_info', locals: { record: draft_record }

    assert_includes html, 'badge text-bg-info'
    assert_includes html, I18n.t('zenodo.records.record_info.badge_draft_text')
  end

  test 'renders published badge when not draft' do
    published_record = Struct.new(:id, :title, :description, :publication_date, :files).new('10', 'Title', '', '', [])

    html = render partial: 'zenodo/records/record_info', locals: { record: published_record }

    assert_includes html, 'badge text-bg-info'
    assert_includes html, I18n.t('zenodo.records.record_info.badge_published_text')
  end
end
