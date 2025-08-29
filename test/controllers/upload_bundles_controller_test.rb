require 'test_helper'

class UploadBundlesControllerTest < ActionDispatch::IntegrationTest
  include ModelHelper

  test 'update changes name' do
    project = create_project
    bundle = create_upload_bundle(project)
    bundle.name = 'old'
    UploadBundle.stubs(:find).with(project.id, bundle.id).returns(bundle)
    bundle.expects(:update).with({'name' => 'new'}).returns(true)

    patch project_upload_bundle_url(project.id, bundle.id), params: { name: 'new', ignored: 'x' }
    assert_redirected_to root_path
  end

  test 'update handles not found bundle' do
    UploadBundle.stubs(:find).returns(nil)

    patch project_upload_bundle_url('p', 'b'), params: { name: 'new' }
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'Upload Bundle not found', flash[:alert]
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
