# frozen_string_literal: true

require 'test_helper'
require 'tempfile'

class Repo::RepoHistoryTest < ActiveSupport::TestCase
  def setup
    @tempfile = Tempfile.new('repo_history')
    @history = Repo::RepoHistory.new(db_path: @tempfile.path, max_entries: 2)
    @type = ConnectorType.get(:dataverse)
  end

  def teardown
    @tempfile.unlink
  end

  test 'add_repo stores entry and increments count' do
    @history.add_repo('https://demo.org', @type, title: 'One', note: 'v1')
    @history.add_repo('https://demo.org', @type, title: 'Two', note: 'v2')

    entry = @history.all.find { |e| e.repo_url == 'https://demo.org' }
    assert entry
    assert_equal 2, entry.count
    assert_equal 'Two', entry.title
    assert_equal 'v2', entry.note
  end

  test 'respects max_entries limit' do
    @history.add_repo('https://one.org', @type)
    @history.add_repo('https://two.org', @type)
    @history.add_repo('https://three.org', @type)

    assert_nil @history.all.find { |e| e.repo_url == 'https://one.org' }
    assert_equal 2, @history.size
  end

  test 'persists and reloads from file' do
    @history.add_repo('https://demo.org', @type, title: 'Demo', note: 'v1')

    reloaded = Repo::RepoHistory.new(db_path: @tempfile.path, max_entries: 2)
    entry = reloaded.all.find { |e| e.repo_url == 'https://demo.org' }

    assert entry
    assert_equal 'Demo', entry.title
    assert_equal 'v1', entry.note
    assert_equal 1, entry.count
  end

  test 'entries are sorted by last_added' do
    @history.add_repo('https://one.org', @type)
    sleep 1 # ensure timestamp ordering
    @history.add_repo('https://two.org', @type)

    assert_equal ['https://two.org', 'https://one.org'], @history.all.map(&:repo_url)
  end
end
