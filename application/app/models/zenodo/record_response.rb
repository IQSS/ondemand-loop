module Zenodo
  class RecordResponse
    FileItem = Struct.new(:id, :filename, :filesize, :download_url, keyword_init: true)

    attr_reader :id, :concept_id, :title, :files

    def initialize(json)
      data = JSON.parse(json)
      @id = data['id'].to_s
      @concept_id = data['conceptrecid']
      @title = data.dig('metadata', 'title')
      @files = Array(data['files']).map do |f|
        FileItem.new(
          id: f['id'].to_s,
          filename: f['key'],
          filesize: f['size'],
          download_url: f.dig('links', 'self')
        )
      end
    end
  end
end
