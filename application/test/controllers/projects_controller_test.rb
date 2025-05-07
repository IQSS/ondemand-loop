require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tmp_dir = Dir.mktmpdir
    Project.stubs(:metadata_root_directory).returns(@tmp_dir)

    @project = Project.new(name: "test_project")
    @project.save

    @user_settings_mock = mock("UserSettings")
    @user_settings_mock.stubs(:user_settings).returns(OpenStruct.new({active_project: @project.name}))
    @user_settings_mock.stubs(:update_user_settings)

    Current.stubs(:settings).returns(@user_settings_mock)
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test "should get index and load active project" do
    get projects_url
    assert_response :success
  end

  test "should create project with generated name" do
    ProjectNameGenerator.stubs(:generate).returns("generated_project")
    post projects_url
    assert_redirected_to projects_url
    follow_redirect!
    assert_match "Project generated_project created", flash[:notice]
  end

  test "should create project with provided name" do
    post projects_url, params: { project_name: "manual_project" }
    assert_redirected_to projects_url
    follow_redirect!
    assert_match "Project manual_project created", flash[:notice]
  end

  test "should set active project" do
    @user_settings_mock.expects(:update_user_settings).with({active_project: @project.id.to_s})
    post project_set_active_url(id: @project.id)
    assert_redirected_to projects_url
    follow_redirect!
    assert_match "#{@project.name} is now the active project.", flash[:notice]
  end

  test "should not set active project if not found" do
    post project_set_active_url(id: "missing-id")
    assert_redirected_to projects_url
    follow_redirect!
    assert_match "Project missing-id not found", flash[:alert]
  end

  test "should destroy project" do
    delete project_url(id: @project.id)
    assert_redirected_to projects_url
    follow_redirect!
    assert_match "Project test_project deleted successfully", flash[:notice]
  end

  test "should not destroy missing project" do
    delete project_url(id: "missing-id")
    assert_redirected_to projects_url
    follow_redirect!
    assert_match "Project missing-id not found", flash[:alert]
  end

  test "should update project via HTML with name and download_dir" do
    put project_url(id: @project.id), params: {
      name: "Updated Name",
      download_dir: "/some/new/path"
    }

    assert_redirected_to projects_url
    follow_redirect!
    assert_match "Project updated successfully", flash[:notice]
  end

  test "should update project via JSON with name and download_dir" do
    put project_url(id: @project.id),
          params: {
            name: "Updated JSON Name",
            download_dir: "/some/json/path"
          }.to_json,
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json"
          }

    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal "Updated JSON Name", json["name"]
    assert_equal "/some/json/path", json["download_dir"]
  end

  test "should not update missing project via HTML" do
    put project_url(id: "missing-id"), params: {
      name: "Should Fail",
      download_dir: "/fail/path"
    }

    assert_redirected_to projects_url
    follow_redirect!
    assert_match "Project missing-id not found", flash[:alert]
  end

  test "should not update missing project via JSON" do
    put project_url(id: "missing-id"),
          params: {
            name: "Should Fail",
            download_dir: "/fail/path"
          }.to_json,
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json"
          }

    assert_response :not_found
    json = JSON.parse(@response.body)
    assert_match "missing-id", json["error"]
  end

  test "should handle update failure via HTML with both fields" do
    Project.any_instance.stubs(:update).returns(false)
    Project.any_instance.stubs(:errors).returns(stub(full_messages: ["Invalid update"]))

    put project_url(id: @project.id), params: {
      name: "Bad Name",
      download_dir: "/bad/path"
    }

    assert_redirected_to projects_url
    follow_redirect!
    assert_match "Failed to update project", flash[:alert]
  end

  test "should handle update failure via JSON with both fields" do
    Project.any_instance.stubs(:update).returns(false)
    Project.any_instance.stubs(:errors).returns(stub(full_messages: ["Invalid fields"]))

    put project_url(id: @project.id),
          params: {
            name: "Bad Name",
            download_dir: "/bad/path"
          }.to_json,
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json"
          }

    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_equal ["Invalid fields"], json["error"]
  end

end
