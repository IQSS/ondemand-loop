# frozen_string_literal: true

require 'ostruct'

class HistoryService
  include DateTimeCommon

  # Returns repository items for the given project ordered by recency
  def project(project)
    return [] unless project

    files = Common::FileSorter.new.most_recent(project.download_files)

    files.map do |file|
      url = file.connector_metadata&.files_url
      next if url.nil? || url.empty?

      OpenStruct.new(
        type: file.type,
        date: file.creation_date,
        title: url,
        url: url,
        note: 'published'
      )
    end.compact.uniq { |item| item.url }
  end

  # Returns global repository items from the RepoHistory store
  def global
    RepoRegistry.repo_history.all.map do |entry|
      OpenStruct.new(
        type: entry.type,
        date: entry.last_added,
        title: entry.title || entry.repo_url,
        url: entry.repo_url,
        note: entry.note
      )
    end
  end
end
