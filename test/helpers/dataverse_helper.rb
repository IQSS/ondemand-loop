module DataverseHelper
  def load_dataverse_fixture(*path)
    File.read(File.join(__dir__, '..', 'fixtures', 'dataverse', *path))
  end
end
