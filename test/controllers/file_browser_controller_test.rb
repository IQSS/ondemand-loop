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

  test 'should sort entries with folders first' do
    get file_browser_url, params: { path: @tmp_dir }
    assert_response :success

    # Extract entry order from response (this assumes the partial renders entries in order)
    assert_match /subdir.*testfile\.txt/m, @response.body
  end
end

class DirectoryEntryTest < ActiveSupport::TestCase
  def setup
    @tmp_dir = Dir.mktmpdir
    @sub_dir = File.join(@tmp_dir, "subdir")
    Dir.mkdir(@sub_dir)
    @file = File.join(@tmp_dir, "testfile.txt")
    File.write(@file, "test content")
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir)
  end

  test 'should initialize with name and path' do
    entry = FileBrowserController.send(:const_get, :DirectoryEntry).new(name: "test.txt", path: @file)

    assert_equal "test.txt", entry.name
    assert_equal @file, entry.path
    assert_equal File.size(@file), entry.size
    assert_equal "file", entry.type
  end

  test 'should detect file type correctly' do
    file_entry = FileBrowserController.send(:const_get, :DirectoryEntry).new(name: "test.txt", path: @file)

    assert file_entry.file?
    assert_not file_entry.folder?
    assert file_entry.supported?
  end

  test 'should detect folder type correctly' do
    folder_entry = FileBrowserController.send(:const_get, :DirectoryEntry).new(name: "subdir", path: @sub_dir)

    assert folder_entry.folder?
    assert_not folder_entry.file?
    assert folder_entry.supported?
  end

  test 'should return correct type_order' do
    file_entry = FileBrowserController.send(:const_get, :DirectoryEntry).new(name: "test.txt", path: @file)
    folder_entry = FileBrowserController.send(:const_get, :DirectoryEntry).new(name: "subdir", path: @sub_dir)

    assert_equal 1, file_entry.type_order  # Files come after folders
    assert_equal 0, folder_entry.type_order  # Folders come first
  end

  test 'should handle unsupported file types' do
    # Create a mock entry that doesn't match file or directory
    entry = FileBrowserController.send(:const_get, :DirectoryEntry).new(name: "test.txt", path: @file)
    entry.instance_variable_set(:@type, 'link')  # Simulate unsupported type

    assert_not entry.file?
    assert_not entry.folder?
    assert_not entry.supported?
    assert_equal 2, entry.type_order  # Others go last
  end

  test 'should calculate size correctly' do
    content = "test content with more data"
    File.write(@file, content)

    entry = FileBrowserController.send(:const_get, :DirectoryEntry).new(name: "test.txt", path: @file)

    assert_equal content.bytesize, entry.size
  end
end
