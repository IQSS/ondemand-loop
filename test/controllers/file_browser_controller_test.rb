require "test_helper"

class FileBrowserControllerTest < ActionDispatch::IntegrationTest

  def setup
    @tmp_dir = Dir.mktmpdir
    @sub_dir = File.join(@tmp_dir, "subdir")
    Dir.mkdir(@sub_dir)
    @file = File.join(@tmp_dir, "testfile.txt")
    @sub_file = File.join(@sub_dir, "subfile.txt")
    File.write(@file, "test content")
    File.write(@sub_file, "test content")
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test "should get index with valid directory path" do
    get file_browser_url, params: { path: @tmp_dir }
    assert_response :success
    assert_includes @response.body, "subdir"
    assert_includes @response.body, "testfile.txt"
  end

  test "should not allow access to unauthorized path" do
    FileBrowserController.any_instance.stubs(:safe_path).returns(nil)

    get file_browser_url, params: { path: "/unauthorized/path" }
    assert_response :forbidden
    assert_includes @response.body, "You do not have permission"
  end

  test 'should render specific accessible directory listing' do
    get file_browser_url, params: { path: @sub_dir }
    assert_response :success
    assert_includes @response.body, 'subfile.txt'
  end
end
