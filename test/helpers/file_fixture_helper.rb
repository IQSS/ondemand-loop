module FileFixtureHelper
  def load_file_fixture(name)
    path = File.join(__dir__, "..", "fixtures", name)
    File.read(path)
  end
end
