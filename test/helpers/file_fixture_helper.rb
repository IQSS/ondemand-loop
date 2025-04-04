module FileFixtureHelper
  def load_file_fixture(name)
    path = fixture_path(name)
    File.read(path)
  end

  def fixture_path(partial_path)
    File.join(__dir__, "..", "fixtures", partial_path)
  end

  def assert_files_content_equal(path1, path2)
    content1 = File.read(path1)
    content2 = File.read(path2)
    assert_equal content1, content2, "Files differ: #{path1} vs #{path2}"
  end
end
