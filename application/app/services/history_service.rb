# frozen_string_literal: true

class HistoryService

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
