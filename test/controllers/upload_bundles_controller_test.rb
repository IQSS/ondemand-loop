require 'test_helper'

class UploadBundlesControllerTest < ActionDispatch::IntegrationTest
  include ModelHelper

  test 'create resolves repo and delegates to processor' do
    project = create_project
    project.save
    Project.stubs(:find).with(project.id.to_s).returns(project)
    ApplicationController.any_instance.stubs(:load_user_settings)

    resolver = mock('resolver')
    url_res = OpenStruct.new(type: ConnectorType::ZENODO, object_url: 'u', unknown?: false)
    resolver.stubs(:resolve).with('u').returns(url_res)
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    processor = mock('proc')
    processor.stubs(:params_schema).returns([:remote_repo_url])
    processor.stubs(:create).returns(ConnectorResult.new(resource: UploadBundle.new, message: {notice: 'ok'}, success: true))
    ConnectorClassDispatcher.stubs(:upload_bundle_connector_processor).with(ConnectorType::ZENODO).returns(processor)

    post project_upload_bundles_url(project.id), params: { remote_repo_url: 'u' }
    assert_response :redirect
  end


  test 'create redirects on invalid project' do
    Project.stubs(:find).returns(nil)
    post project_upload_bundles_url('1'), params: { remote_repo_url: 'u' }
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'Invalid project id', flash[:alert]
  end

  test 'create handles unknown repo url' do
    project = create_project
    Project.stubs(:find).returns(project)
    resolver = mock('resolver')
    resolver.stubs(:resolve).with('u').returns(OpenStruct.new(unknown?: true))
    Repo::RepoResolverService.stubs(:new).returns(resolver)

    post project_upload_bundles_url(project.id), params: { remote_repo_url: 'u' }
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'URL not supported', flash[:alert]
  end

  test 'edit renders partial' do
    bundle = create_upload_bundle(create_project)
    UploadBundle.stubs(:find).returns(bundle)
    processor = mock('proc')
    processor.stubs(:params_schema).returns([])
    processor.stubs(:edit).returns(ConnectorResult.new(partial: '/p', locals: {}))
    ConnectorClassDispatcher.stubs(:upload_bundle_connector_processor).returns(processor)
    UploadBundlesController.any_instance.stubs(:render).returns(true)
    get edit_project_upload_bundle_url('p', bundle.id, format: :html)
    assert_response :not_acceptable
  end

  test 'update redirects with processor result' do
    bundle = create_upload_bundle(create_project)
    UploadBundle.stubs(:find).returns(bundle)
    processor = mock('proc')
    processor.stubs(:params_schema).returns([])
    processor.stubs(:update).returns(ConnectorResult.new(message: {notice: 'ok'}))
    ConnectorClassDispatcher.stubs(:upload_bundle_connector_processor).returns(processor)
    patch project_upload_bundle_url('p', bundle.id)
    assert_redirected_to root_path
  end

  test 'destroy removes upload bundle' do
    project = create_project
    bundle = create_upload_bundle(project)
    UploadBundle.stubs(:find).with(project.id, bundle.id).returns(bundle)
    bundle.expects(:destroy)

    delete project_upload_bundle_url(project.id, bundle.id)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'Upload bundle deleted', flash[:notice]
  end
end
