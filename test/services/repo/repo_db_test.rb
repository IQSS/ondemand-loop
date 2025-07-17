# frozen_string_literal: true
require 'test_helper'
require 'tempfile'

class Repo::RepoDbTest < ActiveSupport::TestCase
  def setup
    @tempfile = Tempfile.new('repo_db_test')
    @db = Repo::RepoDb.new(db_path: @tempfile.path)
    @type = ConnectorType.get(:dataverse)
  end

  def teardown
    @tempfile.unlink
  end

  test 'should add and retrieve an entry' do
    @db.set('https://demo.org', type: @type, metadata: { token: 'abc123' })
    entry = @db.get('https://demo.org')

    assert entry
    assert_equal 'https://demo.org', entry.repo_url
    assert_equal @type, entry.type
    assert_equal 'abc123', entry.metadata.token
    assert_not_nil entry.creation_date
    assert_not_nil entry.last_updated
  end

  test 'should update metadata' do
    @db.set('https://demo.org', type: @type, metadata: { token: 'abc123' })
    original_created = @db.get('https://demo.org').creation_date
    @db.update('https://demo.org', metadata: { token: 'xyz789', user: 'alice' })

    entry = @db.get('https://demo.org')
    assert_equal 'https://demo.org', entry.repo_url
    assert_equal 'xyz789', entry.metadata.token
    assert_equal 'alice', entry.metadata.user
    assert_equal original_created, entry.creation_date
  end

  test 'should raise error when updating unknown domain' do
    assert_raises(ArgumentError, 'Unknown repo url: https://unknown.org') do
      @db.update('https://unknown.org', metadata: { token: 'xyz789' })
    end
  end

  test 'should delete an entry' do
    @db.set('https://demo.org', type: @type, metadata: { token: 'abc123' })
    @db.delete('https://demo.org')

    assert_nil @db.get('https://demo.org')
    assert_equal 0, @db.size
  end

  test 'should return correct size and all entries' do
    @db.set('https://demo.org', type: @type)
    @db.set('https://example.com', type: @type)

    assert_equal 2, @db.size
    all = @db.all
    assert_kind_of Hash, all
    assert_equal %w[https://demo.org https://example.com].sort, all.keys.sort
    all.each do |url, e|
      assert_equal url, e.repo_url
    end
  end

  test 'should persist and reload from file' do
    @db.set('https://demo.org', type: @type, metadata: { token: 'abc123' })
    created = @db.get('https://demo.org').creation_date

    reloaded = Repo::RepoDb.new(db_path: @tempfile.path)
    entry = reloaded.get('https://demo.org')

    assert entry
    assert_equal 'https://demo.org', entry.repo_url
    assert_equal 'abc123', entry.metadata.token
    assert_equal created, entry.creation_date
  end

  test 'should not persist invalid type' do
    assert_raises(ArgumentError) do
      @db.set('https://demo.org', type: 'invalid')
    end
  end
end
