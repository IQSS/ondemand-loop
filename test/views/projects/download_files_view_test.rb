# frozen_string_literal: true

require 'test_helper'
require 'ostruct'

class DownloadFilesViewTest < ActionView::TestCase
  test 'passes from project to repo resolver bar' do
    project = Project.new(name: 'test_project')
    project.stubs(:download_files).returns([])

    view.stubs(:tab_id_for).with(project).returns('tab-id')
    view.stubs(:tab_label_for).with(project).returns('tab-label')

    original_render = view.method(:render)
    view.define_singleton_method(:render) do |*args, &block|
      if args.first.is_a?(Hash) && args.first[:partial] == '/projects/show/download_actions'
        project_local = args.first[:locals][:project]
        "<form action=\"#{repo_resolver_path(from_project: project_local.id)}\"></form>".html_safe
      else
        original_render.call(*args, &block)
      end
    end

    html = render partial: 'projects/show/download_files', locals: { project: project }

    expected_url = repo_resolver_path(from_project: project.id)
    assert_includes html, "action=\"#{expected_url}\""
  end

  test 'status badge links to events widget' do
    project = download_project(files: 1)
    file = project.download_files.first
    file.stubs(:connector_metadata).returns(OpenStruct.new(explore_url: '#', repo_name: 'Repo'))

    view.stubs(:tab_id_for).with(project).returns('tab-id')
    view.stubs(:tab_label_for).with(project).returns('tab-label')

    html = render partial: 'projects/show/download_files', locals: { project: project }

    expected_path = widgets_path('events', project_id: project.id, entity_type: 'download_file', entity_id: file.id)
    assert_includes html, "data-modal-url-value=\"#{ERB::Util.html_escape(expected_path)}\""
  end
end
