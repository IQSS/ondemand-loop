# frozen_string_literal: true

module Repo
  class RepoActivityService

    # Returns global repository items from the RepoHistory store
    def global
      ::Configuration.repo_history.all.map do |entry|
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
end
