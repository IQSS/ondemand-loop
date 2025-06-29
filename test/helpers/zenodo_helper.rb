module ZenodoHelper
  def load_zenodo_fixture(name)
    File.read(File.join(__dir__, '..', 'fixtures', 'zenodo', name))
  end
end
