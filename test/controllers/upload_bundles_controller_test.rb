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
end
