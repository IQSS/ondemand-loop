# frozen_string_literal: true

require 'test_helper'

class Repo::RepoActivityServiceTest < ActiveSupport::TestCase

  test 'global returns entries from repo history' do
    entry1 = Repo::RepoHistory::Entry.new(repo_url: 'https://one', type: ConnectorType.get(:dataverse), title: 'One', note: 'v1', count: 1, last_added: '2024-01-02T00:00:00')
    entry2 = Repo::RepoHistory::Entry.new(repo_url: 'https://two', type: ConnectorType.get(:zenodo), title: 'Two', note: 'v2', count: 1, last_added: '2024-01-01T00:00:00')
    RepoRegistry.stubs(:repo_history).returns(stub(all: [entry1, entry2]))

      result = Repo::RepoActivityService.new.global
      assert_equal ['https://one', 'https://two'], result.map(&:url)
      assert_equal 'One', result.first.title
      assert_equal 'v1', result.first.note
      assert_equal entry1.type, result.first.type
    end
  end
