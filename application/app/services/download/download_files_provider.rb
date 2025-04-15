# frozen_string_literal: true
module Download
  class DownloadFilesProvider

    def pending_files
      DownloadCollection.all.flat_map(&:files).select{|f| f.status == 'ready'}
    end

    def processing_files
      DownloadCollection.all.flat_map(&:files).select{|f| f.status == 'downloading'}
    end
  end
end
