# frozen_string_literal: true

class DownloadFilesProviderMock
  def initialize(files = [])
    @files = files
    @from = 0
  end

  def pending_files
    (@files[@from..-1] || []).tap { @from += 1 }
  end

  def processing_files
    []
  end
end
