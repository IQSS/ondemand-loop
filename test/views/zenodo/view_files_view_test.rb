# frozen_string_literal: true

require 'test_helper'

class ZenodoViewFilesViewTest < ActionView::TestCase
  test 'renders file list when dataset has files' do
    file = Struct.new(:id, :filename, :filesize).new('1', 'file1.txt', 1024)
    dataset = Struct.new(:files).new([file])

    html = render partial: 'connectors/zenodo/shared/zenodo_view_files',
                   locals: { post_url: '/post', dataset: dataset, dataset_id: '1', repo_url: nil }

    assert_includes html, 'file1.txt'
  end

  test 'renders empty message when dataset has no files' do
    dataset = Struct.new(:files).new([])

    html = render partial: 'connectors/zenodo/shared/zenodo_view_files',
                   locals: { post_url: '/post', dataset: dataset, dataset_id: '1', repo_url: nil }

    assert_includes html, I18n.t('connectors.zenodo.shared.zenodo_view_files.msg_empty_dataset_text')
  end
end

