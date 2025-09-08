# frozen_string_literal: true

require 'test_helper'

class RepositoryActivityViewTest < ActionView::TestCase

  test 'renders only global tab when project_id not provided' do
    service = mock('service')
    service.stubs(:global).returns([])
    service.stubs(:project_downloads).with(nil).returns([])
    Repo::RepoActivityService.stubs(:new).returns(service)
    view.stubs(:connector_icon).returns('')
    view.stubs(:params).returns(ActionController::Parameters.new)

    html = render partial: 'widgets/repository_activity'

    refute_includes html, I18n.t('widgets.repository_activity.tab_project_label')
    refute_includes html, connector_project_upload_bundles_path(project_id: '1')
  end

  test 'renders project download urls tab when project_id provided' do
    project_id = '123'

    service = mock('service')
    service.stubs(:global).returns([])
    downloads = [
      OpenStruct.new(url: '/new', type: 'new', date: Time.zone.now, title: 'downloads', note: 'dataset'),
      OpenStruct.new(url: '/old', type: 'old', date: Time.zone.now - 1.day, title: 'downloads', note: 'dataset')
    ]
    service.stubs(:project_downloads).with(project_id).returns(downloads)
    Repo::RepoActivityService.stubs(:new).returns(service)
    view.stubs(:connector_icon).returns('')
    view.stubs(:params).returns(ActionController::Parameters.new(project_id: project_id))

    html = render partial: 'widgets/repository_activity'

    assert_includes html, I18n.t('widgets.repository_activity.tab_project_label')
    assert_includes html, '/new'
    assert_includes html, '/old'
    assert_includes html, connector_project_upload_bundles_path(project_id: project_id)
  end
end
