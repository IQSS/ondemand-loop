# frozen_string_literal: true

require 'test_helper'

class HistoryServiceTest < ActiveSupport::TestCase
  include ModelHelper

  def setup
    @project = create_project

    @file1 = create_download_file(@project)
    @file1.creation_date = '2024-01-01T00:00:00'
    @file1.stubs(:connector_metadata).returns(OpenStruct.new(files_url: '/file1'))

    @file2 = create_download_file(@project)
    @file2.creation_date = '2024-01-02T00:00:00'
    @file2.stubs(:connector_metadata).returns(OpenStruct.new(files_url: '/file2'))

    @file3 = create_download_file(@project)
    @file3.creation_date = '2024-01-03T00:00:00'
    @file3.stubs(:connector_metadata).returns(OpenStruct.new(files_url: '/file2'))

    @project.stubs(:download_files).returns([@file1, @file2, @file3])
  end

  test 'project returns unique items ordered by recency' do
      result = HistoryService.new.project(@project)

      assert_equal ['/file2', '/file1'], result.map(&:url)

      first = result.first
      assert_equal '2024-01-03T00:00:00', first.date
      assert_equal 'published', first.note
      assert_equal '/file2', first.title
      assert_equal @file2.type, first.type
    end

  test 'global returns entries from repo history' do
    entry1 = Repo::RepoHistory::Entry.new(repo_url: 'https://one', type: ConnectorType.get(:dataverse), title: 'One', note: 'v1', count: 1, last_added: '2024-01-02T00:00:00')
    entry2 = Repo::RepoHistory::Entry.new(repo_url: 'https://two', type: ConnectorType.get(:zenodo), title: 'Two', note: 'v2', count: 1, last_added: '2024-01-01T00:00:00')
    RepoRegistry.stubs(:repo_history).returns(stub(all: [entry1, entry2]))

      result = HistoryService.new.global
      assert_equal ['https://one', 'https://two'], result.map(&:url)
      assert_equal 'One', result.first.title
      assert_equal 'v1', result.first.note
      assert_equal entry1.type, result.first.type
    end
  end
