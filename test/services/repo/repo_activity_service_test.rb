# frozen_string_literal: true

require 'test_helper'

class Repo::RepoActivityServiceTest < ActiveSupport::TestCase
  test 'global returns entries from repo history' do
    entry1 = Repo::RepoHistory::Entry.new(repo_url: 'https://one', type: ConnectorType.get(:dataverse), title: 'One', note: 'v1', count: 1, last_added: '2024-01-02T00:00:00')
    entry2 = Repo::RepoHistory::Entry.new(repo_url: 'https://two', type: ConnectorType.get(:zenodo), title: 'Two', note: 'v2', count: 1, last_added: '2024-01-01T00:00:00')
    ::Configuration.stubs(:repo_history).returns(stub(all: [entry1, entry2]))

    result = Repo::RepoActivityService.new.global
    assert_equal ['https://one', 'https://two'], result.map(&:url)
    assert_equal 'One', result.first.title
    assert_equal 'v1', result.first.note
    assert_equal entry1.type, result.first.type
  end

  test 'project_downloads returns sorted project items' do
    project = OpenStruct.new(id: '123')
    
    old_summary = OpenStruct.new(type: 'old', date: Time.zone.now - 2.days, title: 'downloads', url: '/old', note: 'dataset')
    new_summary = OpenStruct.new(type: 'new', date: Time.zone.now, title: 'downloads', url: '/new', note: 'dataset')
    
    file_old = OpenStruct.new(type: 'old',
                              creation_date: Time.zone.now - 2.days,
                              connector_metadata: OpenStruct.new(repo_summary: old_summary))
    file_new = OpenStruct.new(type: 'new',
                              creation_date: Time.zone.now,
                              connector_metadata: OpenStruct.new(repo_summary: new_summary))
    
    project.stubs(:download_files).returns([file_old, file_new])
    Project.stubs(:find).with(project.id).returns(project)

    result = Repo::RepoActivityService.new.project_downloads(project.id)
    assert_equal ['/new', '/old'], result.map(&:url)
    assert_equal ['new', 'old'], result.map(&:type)
    assert_equal ['downloads', 'downloads'], result.map(&:title)
    assert_equal ['dataset', 'dataset'], result.map(&:note)
  end
end
